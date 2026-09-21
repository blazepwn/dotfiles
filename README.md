# Arch Linux Dotfiles — ROG Zephyrus G16 GA605KP

Uso Arch con **Hyprland Lua + Ambxst**, Kitty, Zsh, Powerlevel10k y LSD.
Este es mi respaldo y mi guía para reinstalar esta laptop. La referencia es
Hyprland **0.56.2**, Ambxst **1.3.7** y axctl **v0.0.26**.

La última revisión es del **21 de septiembre de 2026**. Distingo cuatro cosas:

| Tipo de información | Qué significa aquí |
|---|---|
| Estado comprobado | Archivos, paquetes, servicios y configuración cargada que pude inspeccionar |
| Política deseada | Lo que espero de idle, tapa, GPU y energía |
| Instalación/restauración | Pasos que ejecuto sobre un sistema nuevo |
| Warnings y pruebas pendientes | Límites reales; no doy una prueba sin ejecutar por aprobada |

Las correcciones y sus comprobaciones están en [docs/audit.md](docs/audit.md).
No uso el restaurador para particionar, cambiar firmware ni sustituir mis
configuraciones por otro conjunto de dotfiles.

## 1. Hardware

| Componente | Mi laptop |
|---|---|
| Modelo | ASUS ROG Zephyrus G16 GA605KP |
| CPU | AMD Ryzen AI 7 350 |
| GPU usada | Radeon 860M, PCI `1002:1114`, `amdgpu` |
| GPU dedicada física | RTX 5070 Laptop / Max-Q GB206M |
| Pantalla | Samsung ATNA60DL04-0 OLED, eDP-1, 2560×1600, 240 Hz |
| Escala observada | 1.6; VRR desactivado |
| Wi-Fi | MediaTek MT7925 / Filogic 360, `14c3:7925`, `mt7925e` |
| NVMe | Controlador `/dev/nvme0`, disco `/dev/nvme0n1`, unos 954 GiB |
| Suspend | `s2idle` |

Uso únicamente la Radeon. Dejo **GPU Mode = Integrated** en ROG Control Center.
No uso PRIME ni configuración Hybrid porque actualmente no necesito la RTX
para mi flujo de trabajo. Si la necesito más adelante, cambiaré el modo
explícitamente desde ROG Control Center.

Comprueba la GPU visible y el renderer dentro de la sesión gráfica:

```bash
lspci -nnk | grep -A3 -Ei 'VGA|3D|Display'
glxinfo -B | grep -E 'OpenGL vendor|OpenGL renderer'
```

Espero Radeon 860M con `amdgpu`, sin una GPU NVIDIA enumerada. Todavía hay
paquetes NVIDIA instalados en esta máquina; no los eliminé ni los añadí a la
selección de drivers para reinstalar. Tener esos paquetes no demuestra que
la RTX esté activa. No uso `nvidia-smi` como comprobación rutinaria aquí.

## 2. Para qué uso este entorno

Uso esta laptop para CPTS/HTB, pentesting, programación, navegadores, Obsidian
y terminal. Docker, Exegol y virtualización tienen una fase separada al final.
No es principalmente una instalación para gaming.

Prefiero estabilidad, temperaturas razonables, batería y suspend/resume fiable.
La placa ya tuvo problemas físicos, así que dejo las curvas del firmware ASUS.
No uso overclock, undervolt experimental, TDP manual ni hacks ACPI. Performance
queda para cuando lo active manualmente. No instalo TLP junto con esta pila.

## 3. Instalación base de Arch

Instalé originalmente con **archinstall**, UEFI, **systemd-boot**, **GDM** y
**GNOME como fallback**. No tengo Windows. Mi usuario es `nosfeik` y el hostname
es `Nightmare`; los scripts usan `$HOME` y no exigen esos nombres.

Desde una ISO oficial, comprueba UEFI, red y hora:

```bash
ls /sys/firmware/efi/efivars
ip link
timedatectl
# Si necesitas Wi-Fi en la ISO:
iwctl
# Dentro de iwctl: device list; station <interfaz> scan;
# station <interfaz> get-networks; station <interfaz> connect <SSID>; exit
archinstall
```

**Particionar/formatear destruye los datos del destino.** Haz un respaldo externo
y comprueba el disco antes de confirmar. Sigue la
[guía de Arch](https://wiki.archlinux.org/title/Installation_guide) y las opciones
de la versión de archinstall de la ISO.

Selecciona `linux`, NetworkManager, usuario normal con sudo, GNOME/GDM y
systemd-boot. Instala `amd-ucode` y gráficos AMD/Mesa. No selecciones NVIDIA para
esta instalación Integrated. Mi zona horaria es `America/Mexico_City`.

Tengo esta topología; no la trato como tamaños obligatorios para otra instalación:

- EFI FAT32 de 1 GiB en `/boot`.
- Segunda partición LVM; LV `ArchinstallVg-root` de unos 853 GiB con Btrfs.
- Subvolúmenes `@`, `@home`, `@pkg`, `@log`.
- Zram observada de 4 GiB, compresión zstd.
- Hooks de mkinitcpio con `microcode`, `kms` y `lvm2`, entre los de arranque.

Si eliges LVM, comprueba su soporte en initramfs. Genera fstab y entradas de boot
con los UUID nuevos; no copies los de esta laptop. No guardo fstab, initramfs
ni entradas de boot generadas en Git. La lectura detallada de `/boot` quedó
pendiente por permisos en la auditoría.

Después de instalar, entra primero en GNOME o una TTY:

```bash
sudo pacman -Syu --needed git base-devel
bootctl status
findmnt /
findmnt /boot
lsblk -f
```

## 4. Paquetes

Las listas de [packages/](packages/README.md) salen de pacman en esta máquina.
Separo paquetes oficiales, AUR, dependencias opcionales e instalaciones manuales.
[versions.tsv](packages/versions.tsv) registra versiones observadas; no es un lockfile.

```bash
./scripts/install.sh packages
./scripts/install.sh packages --apply
```

La segunda orden pide confirmación y ejecuta `pacman -Syu --needed`.
**Actualiza Arch completo**, incluidos kernel, firmware y paquetes ya instalados;
los hooks pueden regenerar initramfs. No hago actualizaciones parciales para
mantener solo una versión antigua de Hyprland con bibliotecas nuevas.

Si falta yay, revisa su PKGBUILD y compílalo como usuario:

```bash
(
    set -eu
    build_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
    cd "$build_dir/yay"
    less PKGBUILD
    makepkg -si
)
./scripts/install.sh aur
./scripts/install.sh aur --apply
```

No ejecutes yay ni makepkg como root. `asusctl`, `rog-control-center` y Quickshell
son oficiales en la base consultada. Murrine y VS Code están en la lista AUR.
`qt6ct` es necesario para reproducir el platform theme que Ambxst establece.

Instalo manualmente Ambxst/axctl y P10k; el plugin sudo y el snapshot de Colloid
se incluyen en el repo. Sigue [manual-installs.md](docs/manual-installs.md).
No instalo Telegram por conservar su antigua entrada de startup: ahora es condicional.

Los cinco idiomas OCR desactivados están en `packages/optional/ocr-extra.txt`.
Solo uso inglés/español en las preferencias actuales. `sassc` está en
`packages/optional/theme-build.txt`: hace falta para reconstruir Colloid,
no para copiar el tema ya instalado. Los scripts normales no consumen esas listas.

## 5. ASUS y energía

Tengo `asusctl`, `rog-control-center` y `power-profiles-daemon`. Los archivos
vivos de asusd confirman esta política:

| Ajuste | Valor |
|---|---|
| Charge limit | 80 % |
| Batería | Quiet / EPP Power, cambio automático activado |
| AC | Balanced / EPP BalancePower, cambio automático activado |
| EPP vinculado al perfil | Activado |
| Performance | Disponible para activarlo manualmente |
| Tunings y curvas personalizadas | Desactivados; curvas del firmware ASUS |

Abre `rog-control-center` y reproduce esos valores al reinstalar. Deja Integrated.
Si la aplicación exige un ciclo de apagado, guarda el trabajo y complétalo cuando
corresponda. El restaurador no cambia el modo de GPU ni escribe ajustes ASUS.
No importo todo `/etc/asusd`: contiene estado y opciones ligados a esa versión
del daemon y al hardware.

```bash
systemctl is-enabled asusd.service
systemctl status asusd.service power-profiles-daemon.service --no-pager
systemctl cat asusd.service
cat /sys/class/power_supply/BAT*/charge_control_end_threshold
powerprofilesctl get
powerprofilesctl list
```

`asusd` es **static**, sin `[Install]`; el paquete lo activa mediante udev.
No ejecutes `systemctl enable asusd`. PPD usa `amd_pstate` y `platform_profile`.
En la lectura inicial con AC el perfil era `balanced`. Al cerrar la revisión,
en batería, estaba en `power-saver`; no cambié el perfil para validar.

## 6. Hyprland Lua y overrides

Uso configuración Lua modular. NO edito el archivo generado
`~/.local/share/ambxst/hyprland.lua` porque Ambxst lo regenera.
Mi principal lo carga primero y después importa, en este orden:

```text
~/.config/hypr/
├── hyprland.lua
├── hypridle.conf
└── user/
    ├── env.lua
    ├── binds.lua
    ├── windowrules.lua
    ├── startup.lua
    ├── input.lua
    ├── gestures.lua
    └── lid.lua
```

| Módulo | Qué tengo configurado |
|---|---|
| env | GoogleDot-Black, tamaño 24 |
| binds | Unbinds explícitos, aplicaciones, ventanas, workspaces, ratón y multimedia |
| windowrules | No initial focus, flotantes, tamaños y asignaciones |
| startup | hypridle, Kitty, apps, nwg-look, polkit, cursor, audio y D-Bus |
| input | Repetición 30/400 ms, follow_mouse 1, sensibilidad 0 y touchpad |
| gestures | Tres dedos horizontal para cambiar workspace |
| lid | Solo los eventos on/off que llaman a lid-power.sh |

Tengo tap, tap-and-drag, disable-while-typing, natural-scroll y clickfinger;
scroll factor 1.0. Conservo las reglas de ventanas existentes:

| Aplicación / clase | Workspace |
|---|---|
| Kitty | 1 |
| Chromium, Brave, Firefox | 2 |
| code, Burp | 3 |
| VMware, Obsidian | 4 |
| Spotify | 5 |
| discord | 6 |
| Telegram | 7 |

Elecwhat → 8 y ROG Control → 9 se asignan en startup. Discord Canary arranca
silenciosamente en 6, pero la regla persistente solo coincide con `discord`.
No doy por instalada una aplicación por tener una regla para ella.

Los atajos principales siguen siendo SUPER+Return, SUPER+E, SUPER+T, SUPER+Q,
SUPER+F, flechas y workspaces 1–10. SHIFT mueve ventanas entre workspaces.
Mantengo volumen a pasos de 5 %, playerctl y brightnessctl.

Corregí los conflictos cargados con unbinds antes de mis overrides:

- Ratón, volumen, mute, brillo y multimedia tienen una sola asignación por tecla.
- SUPER+SHIFT+B solo muestra/oculta la barra. Para reiniciar la shell ejecuto
  `ambxst reload` deliberadamente.
- SUPER+ALT+Down/j y Up/k redimensionan ±50 mediante
  `hl.dsp.window.resize({ x = 0, y = 50, relative = true })` y su variante negativa.
- `lid.lua` retira los binds genérico/on/off de Ambxst y define solo mis dos eventos.

La API de resize corresponde a la [documentación Lua de Hyprland](https://wiki.hypr.land/Configuring/Basics/Binds/).
El generado de Ambxst todavía puede contener `exec_cmd("resizeactive ...")`;
mis overrides lo sustituyen al cargar. No creo un ejecutable ficticio ni edito
el generado. Tras recargar se comprobaron cero grupos duplicados y cero configerrors.

No tengo una regla propia de monitor. Comprueba 2560×1600@240 y escala 1.6 tras
reinstalar; ajusta Ambxst si cambia la autodetección.

## 7. Ambxst y primer arranque

Uso una shell Ambxst con axctl daemon, axctl subscribe y Quickshell. Esos procesos
no son varias instancias de Ambxst. `startup.lua` no vuelve a lanzarlo.

Instala los componentes fijados:

```bash
./scripts/manual-components.sh ambxst --apply
./scripts/manual-components.sh p10k --apply
```

El script verifica commits/hashes y reutiliza componentes completos. Si encuentra
otra versión o cambios locales, se detiene; no actualiza ni sobreescribe a ciegas.
Los binarios se instalan con confirmación individual de sudo.

**Un HOME nuevo todavía no tiene el Lua generado.** `ambxst install hyprland`
solo añade el import al principal, no genera ese archivo. El repo ya restaura
el principal correcto: no ejecutes ese subcomando encima.

Después de restaurar assets/system/configs, cierra GNOME y ejecuta desde una
TTY local:

```bash
./scripts/bootstrap-ambxst.sh
./scripts/bootstrap-ambxst.sh --apply
```

Abre un Hyprland temporal con Kitty y Ambxst, sin importar el Lua ausente.
El daemon arranca axctl y la shell alimenta su generador. En ese Kitty, comprueba:

```bash
test -s "$HOME/.local/share/ambxst/hyprland.lua"
luac -p "$HOME/.local/share/ambxst/hyprland.lua"
```

Si no existe, revisa el arranque; no fabriques un archivo para pasar la comprobación.
Cuando pase, cierra la sesión temporal:

```bash
ambxst quit
hyprctl dispatch 'hl.dsp.exit()'
```

Entra normalmente por GDM. El bootstrap no es parte del startup diario.
La secuencia está basada en el código local y validada sintácticamente; una
reinstalación gráfica completa en HOME vacío sigue pendiente de prueba.

Estos comandos **sí cambian la sesión**. Ejecútalos individualmente cuando quieras
esa acción; no son un bloque de diagnóstico:

```bash
ambxst lock
ambxst screen on
ambxst screen off
ambxst suspend
```

## 8. Tema, cursor, iconos y fuentes

Tengo los archivos GTK configurados con **Colloid-Dark**, iconos **kora** y cursor
**GoogleDot-Black 24**. Kitty usa Hack Nerd Font. También respaldo MesloLGS NF y
Montserrat. Las fuentes de `.fonts` se restauran en `~/.local/share/fonts/dotfiles`.

Conservo el tema instalado, incluida la paleta recoloreada por Ambxst. Recompilar
Colloid puede cambiar esos colores. Para hacerlo explícitamente, sigue la sección
Colloid de [instalaciones manuales](docs/manual-installs.md), incluida `sassc` y
la opción GTK4/libadwaita. No copio bibliotecas del sistema.

```bash
fc-cache -f "$HOME/.local/share/fonts/dotfiles"
fc-match 'Hack Nerd Font'
fc-match 'MesloLGS NF'
fc-match Montserrat
```

Ambxst solicita Iosevka Nerd Font Mono, pero no está instalada: Fontconfig usa
Noto Sans Mono. No invento una instalación que no tengo.

Respaldo `~/.local/share/nwg-look/gsettings` porque `nwg-look -a` lo necesita;
`.config/nwg-look/config` por sí solo no contiene las preferencias del tema.
`-a` aplica ese estado guardado; `-x` exporta archivos GTK. Son operaciones distintas.

**Diferencia comprobada:** los archivos GTK y el estado guardado de nwg-look dicen
Colloid-Dark, mientras GSettings tenía `adw-gtk3`. La auditoría no cambió GSettings.
Para aplicar mi selección guardada tras restaurar, desde GNOME con el bus del usuario:

```bash
nwg-look -a
gsettings get org.gnome.desktop.interface gtk-theme
gsettings get org.gnome.desktop.interface icon-theme
gsettings get org.gnome.desktop.interface cursor-theme
```

Si necesitas regenerar `.gtkrc-2.0` para el HOME nuevo, ejecuta `nwg-look -x`
**después** de aplicar las preferencias. Exporta también los otros archivos
habilitados en su configuración: revisa las diferencias con el snapshot si buscas
conservarlo exactamente. La distinción se comprobó en
[nwg-look 1.1.1](https://raw.githubusercontent.com/nwg-piotr/nwg-look/v1.1.1/main.go).

Ya dentro de Hyprland, si necesitas reaplicar el cursor:

```bash
hyprctl setcursor GoogleDot-Black 24
```

No ejecutes ese comando desde GNOME/TTY. Los enlaces GTK4 del repo son relativos;
apuntan al snapshot Colloid bajo `$HOME/.themes`.

## 9. Kitty, Zsh, Powerlevel10k y LSD

Conservo `kitty.conf`, `color.ini`, `.p10k.zsh` y los YAML de LSD. Kitty usa
Hack Nerd Font a 23 y Zsh. Mantengo aliases `ls`, `l`, `ll`, `la`, `lla`, `cat`
con bat y `catn` con `/usr/bin/cat`. No tenía alias `tree`; uso `lsd --tree`.

Uso syntax-highlighting, autosuggestions y el plugin sudo de
`/usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh`. La acción `system` instala
la copia revisada del plugin; no necesito todo Oh My Zsh. Esc Esc antepone sudo.

En el respaldo cargo P10k una sola vez y uso rutas portables. Conservo como
opcionales ctgen, Go, Cargo y Android Studio: no está documentado si volveré
a usarlos. Solo añado sus directorios al PATH cuando existen.

```bash
zsh -n "$HOME/.zshrc"
getent passwd "$USER" | cut -d: -f7
# Si todavía no es la shell de login:
chsh -s /usr/bin/zsh
```

## 10. Idle, OLED y suspend

**Política deseada y configuración actual:** hypridle es el único componente con
acciones temporizadas de inactividad. Dejé `idle.listeners = []` en Ambxst;
su validador acepta la lista vacía. No desactivé la shell ni el lockscreen.
Ambxst mantiene su monitor interno de actividad y sus hooks de lock/sleep,
pero no tiene listeners que ejecuten acciones por timeout.

| Inactividad / evento | Acción de hypridle |
|---|---|
| 300 s / 5 min | `ambxst lock` |
| 600 s / 10 min | DPMS disable |
| Actividad tras DPMS off | DPMS enable |
| 1800 s / 30 min | `ambxst suspend` |
| Antes de suspend | `ambxst lock` |
| Después de resume | DPMS enable |

Respeto los inhibidores D-Bus, systemd y Wayland y conservo `inhibit_sleep = 2`.
Hypridle arranca desde `startup.lua`; no habilites además `hypridle.service`.
El restaurador rechaza ese conflicto antes de copiar configs.

```bash
./scripts/check-session.py
cat /sys/power/mem_sleep
pgrep -ax hypridle
systemctl --user is-enabled hypridle.service
systemd-inhibit --list
```

El servicio de usuario está disabled/inactive y hay un proceso de startup.
La sintaxis que uso para DPMS es Lua, no el dispatcher antiguo `dpms off`.
Las órdenes manuales de prueba están en la sección 15. Los tiempos completos
5/10/30 no se volvieron a cronometrar después de retirar los listeners de Ambxst.

## 11. Tapa

| Alimentación / evento | Política |
|---|---|
| Batería, cerrar, sin dock/monitor externo | **POWER OFF completo por logind** |
| AC, cerrar | **Ambxst lock + OLED off** |
| AC, abrir | **OLED on; sigo en lockscreen** |

En batería apago completamente al cerrar porque normalmente guardo la laptop
en la mochila y no quiero depender de s2idle mientras está guardada.

El drop-in real se guarda en `system/etc/systemd/logind.conf.d/20-lid.conf`:

```ini
[Login]
HandleLidSwitch=poweroff
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
LidSwitchIgnoreInhibited=yes
```

Logind gestiona el apagado aunque no haya sesión gráfica. Hyprland llama a
`~/.local/bin/lid-power.sh`: en AC bloquea, espera 0.5 s y apaga DPMS; en batería
el script no hace nada; al abrir activa DPMS. Los binds de tapa de Ambxst se
retiran antes de registrar estos dos eventos. No cambié el drop-in ni el helper.

Hay límites que no oculto:

- `HandleLidSwitchDocked=ignore` tiene precedencia en dock/varios monitores.
- Un inhibidor de bajo nivel `handle-lid-switch` puede hacerse cargo de la tapa;
  GNOME fallback puede hacerlo y allí no se ejecuta mi módulo Lua.
- El timeout de 30 minutos sigue activo en AC. Cerrar no pide suspend, pero eso
  no significa mantenerse despierta indefinidamente.
- Quitar el cargador con la tapa ya cerrada no garantiza otro evento de cierre.
  Para la mochila, apaga explícitamente o abre/cierra ya en batería.

```bash
cat /proc/acpi/button/lid/*/state
hyprctl devices
systemd-analyze cat-config systemd/logind.conf
systemd-inhibit --list
journalctl -b -u systemd-logind --no-pager
```

No reinicies logind dentro de la sesión para probarlo. El restaurador deja su
aplicación para un reboot manual planificado. Las pruebas físicas de tapa
posteriores a los unbinds están pendientes.

## 12. Portales Wayland

Mantengo xdg-desktop-portal y sus backends Hyprland, GTK y GNOME. El paquete
proporciona `/usr/share/xdg-desktop-portal/hyprland-portals.conf` con
`default=hyprland;gtk`. No necesito copiarlo ni crear un override.

```bash
cat /usr/share/xdg-desktop-portal/hyprland-portals.conf
systemctl --user status xdg-desktop-portal.service \
  xdg-desktop-portal-hyprland.service xdg-desktop-portal-gtk.service --no-pager
systemctl --user is-active xdg-desktop-portal-gnome.service
journalctl --user -b -u xdg-desktop-portal-hyprland --no-pager
systemctl --user show-environment | grep -E 'WAYLAND_DISPLAY|XDG_CURRENT_DESKTOP'
```

En mi sesión están activos broker, XDPH y GTK; GNOME puede estar inactivo.
No habilites estos servicios estáticos. D-Bus los activa según la sesión.

Ya había probado file picker y screen sharing. Para revalidarlos, abre/sube un
archivo desde una app que use portales y comparte pantalla en una llamada o
prueba WebRTC. Comprueba el selector y la imagen recibida. Un servicio activo
no basta como prueba funcional. En XDPH busco `PipeWire connected` y
`screencopy init successful`; este último se corroboró en los logs auditados.

## 13. Audio y firewall

Uso PipeWire, pipewire-pulse, pipewire-alsa, pipewire-jack y WirePlumber. RTKit
está instalado y activo por D-Bus aunque su unidad figure como disabled.
Antes apareció `RTKit ServiceUnknown`; no añado ajustes de scheduling para
compensar que falte ese paquete. Startup desmutea el sink por defecto.

```bash
systemctl --user status pipewire.service pipewire-pulse.service wireplumber.service --no-pager
systemctl --user is-enabled pipewire.socket pipewire-pulse.socket wireplumber.service
systemctl status rtkit-daemon.service --no-pager
wpctl status
journalctl --user -b -u pipewire -u pipewire-pulse -u wireplumber --no-pager
```

Tengo UFW habilitado y activo. La baseline en sus archivos es deny incoming,
allow outgoing, deny routed, IPv6 y logging low, sin aperturas de usuario.
La restauración de paquetes/servicios no lo activa automáticamente.
Sigue [docs/firewall.md](docs/firewall.md): `scripts/firewall.sh --apply` es un
paso separado desde TTY local, con confirmación. `ufw enable` aplica el filtrado
inmediatamente. No guardo rulesets runtime ni reglas temporales de Docker/VPN.

## 14. Comprobaciones de hardware y sesión

Ejecuta dentro de Hyprland:

```bash
hyprctl version
hyprctl configerrors
hyprctl monitors
./scripts/check-session.py
lspci -nnk | grep -A3 -Ei 'VGA|3D|Display'
glxinfo -B | grep -E 'OpenGL vendor|OpenGL renderer'
powerprofilesctl get
powerprofilesctl list
sensors
pgrep -af 'ambxst|axctl|hypridle'
nmcli device status
sudo nvme log smart /dev/nvme0
```

Si `hyprctl configerrors` no imprime nada, la configuración cargó sin errores
reportados. Eso no prueba cada atajo ni cada ciclo de suspend.
Espero AMD/amdgpu, pantalla 240 Hz, escala 1.6, un hypridle y Wi-Fi conectado.
`p2p-dev-*` desconectado no equivale a perder la conexión Wi-Fi normal.

Mi SMART comprobado anteriormente tenía critical_warning 0, available_spare
100 %, percentage_used 2 %, media_errors 0 y unos 33 °C. No se repitió una
lectura privilegiada durante esta corrección. Uso `nvme log smart` como comando
actual. CPU ~51 °C, GPU ~48 °C y fans ~2200/1800/3700 RPM son referencias de
pruebas anteriores, no límites fijos ni una razón para cambiar curvas.

## 15. Pruebas funcionales pendientes

Estas pruebas cambian la sesión. Guarda el trabajo y ejecútalas una por una.
No se hicieron suspend, reboot, cierre de tapa ni cambio de GPU durante las
correcciones del repo.

Para comprobar lock y que puedes desbloquear:

```bash
ambxst lock
```

Para probar DPMS con encendido automático cinco segundos después, en un terminal
local (mantén la tapa abierta):

```bash
sh -c 'sleep 5; hyprctl dispatch '\''hl.dsp.dpms({ action = "enable" })'\''' &
hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'
```

Para probar los tiempos, revisa primero `systemd-inhibit --list` y deja la laptop
abierta sin actividad: lock a 5 min, OLED off a 10 y suspend a 30. Los inhibidores
pueden impedir esas acciones deliberadamente; no los desactivo para forzar la prueba.

Para un ciclo explícito de suspend/resume:

```bash
ambxst suspend
# Tras despertar:
nmcli device status
hyprctl monitors
journalctl -b -k --no-pager | grep -Ei 'suspend|resume|amdgpu|WLAN|mt7925|timeout|reset'
journalctl -b -u NetworkManager --no-pager
```

Espero `PM: suspend entry (s2idle)`, `SMU is resumed successfully` y
`PM: suspend exit`, imagen restaurada y Wi-Fi reconectado. Hay tres ciclos
correctos corroborados en un boot anterior. Para consultar otro boot:

```bash
journalctl --list-boots
# Sustituye -1 por el boot que quieras revisar:
journalctl -k -b -1 --no-pager | grep -Ei 'suspend|resumed|WLAN|amdgpu'
```

Prueba físicamente la tapa primero con AC: cerrar bloquea y apaga OLED; abrir
enciende OLED manteniendo lockscreen. Después, sin trabajo abierto, sin dock ni
monitor externo, prueba en batería y espera el apagado completo. No simulo esos
eventos con un comando que oculte si el switch real funciona.

Prueba también volumen, mute, brillo, multimedia, drag/resize y los cuatro atajos
de resize. Ya se validó que no hay bindings duplicados cargados; falta confirmar
sus efectos al usarlos.

## 16. Warnings conocidos

He visto estos mensajes junto a ciclos de suspend que terminaron correctamente:

- ACPI BIOS Error en `\_SB.PCI0.GPP5.WLAN._PS3` y `_PS0`.
- `No UUID available providing old NGUID` del NVMe.
- Warnings p2p-dev sin pérdida funcional en pruebas anteriores.

Los considero benignos mientras resume funcione, Wi-Fi reconecte y no haya GPU
resets/timeouts ni errores de I/O. Si aparece alguno de esos fallos, reviso la
regresión y SMART. No añado parámetros de kernel para silenciar un warning
ni invento warnings XKB que no haya corroborado.

## 17. Restauración completa

En la instalación nueva, entra en GNOME/TTY con red y sudo. Clona mi repo una vez:

```bash
mkdir -p "$HOME/Dev"
git clone https://github.com/blazepwn/dotfiles "$HOME/Dev/dotfiles"
cd "$HOME/Dev/dotfiles"
```

Si ya existe el checkout, entra y revisa `git status`; no clones encima.
Los cambios locales sin publicar todavía no estarán en un clon remoto.

Ejecuta en este orden, revisando los planes antes de `--apply`:

```bash
./scripts/install.sh packages
./scripts/install.sh packages --apply
# Prepara yay si falta, según sección 4.
./scripts/install.sh aur
./scripts/install.sh aur --apply
./scripts/manual-components.sh ambxst --apply
./scripts/manual-components.sh p10k --apply
./scripts/install.sh assets
./scripts/install.sh assets --apply
./scripts/install.sh system
./scripts/install.sh system --apply
./scripts/install.sh configs
./scripts/install.sh configs --apply
./scripts/install.sh services --apply
```

Configura ASUS según sección 5. Aplica nwg-look desde GNOME si quieres alinear
GSettings con las preferencias guardadas. Selecciona Zsh como shell si hace falta.
Después cierra GNOME: desde una TTY local, completa UFW y, si falta el generado,
el bootstrap de Ambxst:

```bash
./scripts/firewall.sh --apply
./scripts/bootstrap-ambxst.sh --apply
```

El bootstrap solo hace falta la primera vez; si ya existe el generado, lo indica.
Antes de dar la restauración por terminada, comprueba sintaxis y servicios:

```bash
bash -n scripts/install.sh
sh -n .local/bin/lid-power.sh
zsh -n .zshrc
find .config/hypr -name '*.lua' -exec luac -p {} \;
git diff --check
systemctl is-enabled gdm NetworkManager bluetooth power-profiles-daemon ufw
```

El drop-in de logind se aplica en el próximo arranque. **Cuando hayas guardado
el trabajo y revisado esos ajustes**, ejecuta manualmente:

```bash
systemctl reboot
```

En GDM selecciona Hyprland. GNOME sigue disponible. Ejecuta las comprobaciones
14–15 y la prueba real de portales. No confundas esa validación con el bootstrap.

### Qué hace el restaurador

- Copia los archivos enumerados en [manifests/](manifests/README.md); no descubre
  archivos futuros recorriendo carpetas ni confía en gitignore como filtro de copia.
- Ambos puntos de entrada, `install.sh` y `restore.py`, usan las mismas comprobaciones
  para configs. Rechazan Hyprland/Ambxst/hypridle activos, un servicio hypridle
  habilitado/activo y destinos XDG distintos a los documentados.
- Revisa destinos y padres symlink antes de escribir. Conserva archivos ajenos,
  hace backup y reemplaza por archivo mediante una copia temporal.
- Archiva un `hyprland.conf` antiguo para evitar el punto de entrada alternativo.
- Una segunda copia idéntica no crea otro backup. Un fallo de disco puede dejar
  una aplicación parcial; no prometo una transacción completa del HOME.
- `system` confirma por separado logind, plugin sudo y zram. No reinicia logind
  ni swap. La configuración zram solo fija zstd; no fuerza un tamaño nuevo.
- `services` habilita GDM, NetworkManager, Bluetooth, PPD, sockets PipeWire y
  WirePlumber. No inicia GDM encima de la sesión ni habilita asusd/portales estáticos.
- La acción `packages` sí actualiza el sistema. Las acciones de copia no cambian
  GPU, fan curves, ASUS, shell de login ni GSettings. No hacen commit ni push.

Mis backups de usuario quedan en `~/.local/state/dotfiles-backups/restore-*`,
con manifiesto y permisos privados. Los root están en `/var/backups/dotfiles.*`;
UFW usa `/var/backups/dotfiles-ufw.*`.
Para deshacer, cierra Hyprland, consulta el manifiesto y restaura solo la ruta
necesaria. Por ejemplo, sustituyendo BACKUP por el directorio real:

```bash
cp -a --remove-destination BACKUP/.zshrc "$HOME/.zshrc"
```

Las entradas `created` no tenían archivo anterior. Revísalas antes de retirarlas;
no vuelques todo un backup encima del HOME.

## 18. Troubleshooting

| Problema | Qué compruebo |
|---|---|
| Errores Lua | `hyprctl configerrors`, versión y orden de carga. `luac -p` no valida la API `hl` |
| Ambxst no inicia | Binarios, shell_repo, shell.qml, generado; completar bootstrap si es un HOME nuevo |
| Ambxst duplicado | `pgrep -af 'ambxst|axctl|qs'`; no agregar otro autostart |
| Doble acción de tecla/tapa | `scripts/check-session.py`; comprobar unbinds después de actualizar Ambxst |
| Pantalla se apaga antes de 10 min | Revisar que `idle.listeners` siga vacío y que no haya otro gestor |
| File picker / screen sharing | Portales, entorno D-Bus, logs XDPH y una prueba funcional |
| Cursor | Assets, env.lua, GSettings y setcursor dentro de Hyprland |
| GTK | Archivo persistente de nwg-look, diferencia entre `-a` y `-x`, enlaces GTK4 y paleta |
| Suspend/Wi-Fi | Logs del ciclo, amdgpu, mt7925e, NetworkManager, firmware y wireless-regdb |
| NVIDIA aparece | Revisar Integrated y el ciclo pedido por firmware; no activar PRIME |
| Tapa en batería no apaga | Alimentación online, dock, drop-ins e inhibidores handle-lid-switch |
| OLED no vuelve | Switch real, permisos del helper, módulo lid cargado y dispatcher Lua |
| RTKit ServiceUnknown | Paquete rtkit, activación D-Bus y logs de PipeWire |
| Telegram no arranca | El ejecutable no está instalado; startup lo omite deliberadamente |
| Restore se detiene | Leer el conflicto; no saltarse las comprobaciones invocando Python directamente |
| UFW ya tenía reglas | Revisarlas por separado; no usar reset para forzar la baseline |

Si corriges el entorno de portales y no hay una llamada/screencast activo, puedes
reiniciar sus backends. Esto interrumpe solicitudes en curso:

```bash
systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal-gtk.service
systemctl --user restart xdg-desktop-portal.service
```

Si el entorno viene de otra sesión, sal y vuelve a entrar a Hyprland. No elimino
GNOME para solucionar un problema de portales.

## 19. Pentesting layer — Next phase

La auditoría inicial no encontró Docker, Exegol, qemu-desktop, virt-manager,
Burp Suite, wireshark-qt, Nmap, OpenVPN ni wireguard-tools. Las reglas de ventanas
no significan que ya haya configurado esas herramientas.

Dejo para una fase separada:

- Docker/Exegol: imágenes, almacenamiento, permisos y efecto sobre el firewall.
- QEMU/KVM/virt-manager: redes y snapshots de laboratorios.
- Burp, Wireshark y Nmap: herramientas y permisos necesarios.
- OpenVPN/WireGuard: CPTS/HTB con credenciales fuera de Git.
- Python offensive tooling: entornos separados por proyecto.
- Obsidian, navegador y terminal: notas y flujo de trabajo del laboratorio.

## Referencias y contenido anterior

Mantengo los iconos Kora, fuentes y wallpapers incluidos en mi repo original.
Las capturas en [Pictures/Examples](Pictures/Examples) son históricas; no las
presento como una comprobación del escritorio actual. La shell es
[Ambxst](https://github.com/Axenide/Ambxst), el tema es
[Colloid](https://github.com/vinceliuice/Colloid-gtk-theme) y el prompt es
[Powerlevel10k](https://github.com/romkatv/powerlevel10k).
Los assets conservan su autoría; las licencias añadidas están bajo `vendor/`.
