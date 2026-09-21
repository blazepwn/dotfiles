# Auditoría del sistema y decisiones

## Correcciones aprobadas por etapas — 2026-09-21

El informe original quedó seguido de una auditoría de solo lectura y de una
autorización explícita para corregir P01–P22 por etapas. El estado y límites
actuales se recogen en [staged-fixes.md](staged-fixes.md). Esa sección sustituye
las conclusiones iniciales sobre idle y bindings: los conflictos ya existían,
no eran solo un riesgo después de actualizar.

## Histórico: primera sincronización


Fecha: 2026-09-21, zona America/Mexico_City. Directorio de trabajo:
`/home/nosfeik/Dev/dotfiles`. HEAD inicial `80d0a91`, `git status --short` vacío.
En esa primera sincronización no se hicieron commit/push, instalación de paquetes, cambios de servicios,
reinicios, suspend, cambios de GPU ni escrituras al HOME de configuración o `/etc`.

## Comparación previa

| Área | Repo inicial frente al sistema |
|---|---|
| Hyprland | 12 archivos antiguos; sistema con principal Lua, 7 módulos y hypridle, más un .bak excluido |
| Kitty | 2 archivos idénticos; no se modifican |
| LSD | 2 archivos idénticos; no se modifican |
| P10k usuario | Idéntico; no se modifica |
| Zsh | Otro usuario hardcodeado y ruta incorrecta del plugin sudo en el repo |
| Fuentes | 34 archivos idénticos en `.fonts`; `.local/share/fonts` no existía |
| Iconos | 117264 archivos comparados; solo difería default/index.theme |
| Wallpapers | 4 existentes idénticos; se agrega 1348334.jpg, revisado visualmente |
| GTK/nwg-look/xsettingsd | Faltaban en el repo |
| logind + lid-power | Faltaban en el repo |
| Ambxst preferencias | Faltaban; se guardan 12 JSON revisados |

Se leyó la configuración antigua de Hyprland antes de retirarla. Sus referencias
a NVIDIA/NVD_BACKEND/AQ_DRM_DEVICES, temas obsoletos, eww y monitores no actuales
no aparecen en los overrides vivos. No se llevan al nuevo árbol activo.
El script de captura y prompt root se conservan en `legacy/`; las configuraciones
antiguas completas se pueden consultar en el historial inicial.

[source-manifest.json](source-manifest.json) registra procedencia y SHA256 de
39 archivos revisados del sistema/recursos locales en la primera sincronización. En ese manifiesto **el hash
es del origen**, no una garantía de que el destino transformado sea idéntico:
El snapshot inicial tenía estas diferencias intencionales: `.zshrc` y una línea vacía final retirada de
`gtk-3.0/gtk.css` para pasar la comprobación de whitespace. En el snapshot de
Colloid-Dark solo se retira esa misma línea vacía final de `gtk-4.0/gtk.css`;
no se cambia ninguna regla ni color. Los enlaces
GTK4 son equivalentes pero relativos. No se copiaron enlaces absolutos al HOME.

## Estado observado

- Hyprland 0.56.2-3, kernel 7.2.6-arch2-1, sin configerrors.
- Radeon 860M / amdgpu y renderer AMD; NVIDIA no enumerada como GPU.
- eDP-1, Samsung ATNA60DL04-0, 2560×1600@240, escala 1.6, VRR false.
- Wi-Fi MT7925/mt7925e conectado, wireless-regdb instalado.
- PPD balanced, CpuDriver amd_pstate y PlatformDriver platform_profile.
- Carga 80%; Quiet/Power en batería, Balanced/BalancePower en AC, cambios
  automáticos y EPP vinculados activados. Ninguna curva personalizada activa.
- GDM, NetworkManager, Bluetooth, PPD habilitados; asusd estático y activo
  mediante reglas udev. RTKit activo, unidad disabled con activación D-Bus.
- Portales broker/Hyprland/GTK activos; GNOME inactivo en esta sesión.
- PipeWire y pipewire-pulse por sockets, WirePlumber habilitado. hypridle
  como proceso de startup, su servicio de usuario deshabilitado.
- Un proceso Ambxst, un hypridle, hyprpolkitagent, axctl daemon/subscriber y qs.
- systemd-boot 261.3-1-arch detectado por bootctl; lectura detallada de `/boot`
  denegada al usuario. No se elevó privilegio para inspeccionarlo.
- Tres ciclos de suspend/resume en boot entonces `-3`: 23:19, 23:22 y 23:31
  del 20 de septiembre, con s2idle, SMU resumed y suspend exit. Se observaron
  warnings ACPI WLAN _PS3/_PS0 y NGUID NVMe; no se aplicaron workarounds.

SMART y el resultado funcional de file picker/screen sharing se documentan
como pruebas previas reportadas por el usuario. No se simulan como verificaciones
nuevas. En logs del boot actual se confirmó screencopy init successful.

## Divergencias revisadas tras la aprobación

1. Telegram sigue sin instalarse; el autostart ya comprueba el ejecutable.
2. GSettings tenía adw-gtk3; los archivos GTK y nwg-look dicen Colloid-Dark.
   No se aplicó GSettings durante estas correcciones.
3. Ambxst solicita Iosevka Nerd Font Mono, resuelta a Noto Sans Mono. Se conserva.
4. Los 13 grupos de bindings duplicados se resolvieron con overrides Lua;
   la acción genérica de tapa también se retiró. Quedan solo on/off propios.
5. Ambxst conserva lockscreen y hooks de sleep, con `idle.listeners=[]`.
   Hypridle es el único componente con acciones temporizadas 5/10/30.
6. La excepción de dock, inhibidores de bajo nivel y el timeout en AC permanecen.
7. No se desinstalaron paquetes NVIDIA ni switcheroo-control; no se cambió GPU.
8. No se inventó una regla de monitor propia.
9. La barra y la paleta GTK cambiaron en el sistema vivo durante el trabajo;
   se actualizaron sus snapshots en el repo, sin sobrescribir el sistema vivo.

El archivo zram de dos líneas también se conserva bajo `system/etc/systemd`;
la acción system lo instala con confirmación separada, sin reiniciar swap.

## Exclusiones deliberadas

- `.cache` completa, cookies, claves SSH/GPG, historiales, perfiles de navegador,
  Discord, datos Telegram, tokens, keyrings y perfiles privados de red.
- Bases de clipboard Ambxst (incluidos elementos fijados), notificaciones,
  uso de aplicaciones, thumbs y selección de wallpapers en caché.
- Generados de Ambxst `.local/share/ambxst/*`, incluido hyprland.lua. Se vuelven
  a generar con la shell y sus preferencias.
- Bookmarks GTK con rutas personales y `.gtkrc-2.0` generado con include absoluto.
- `hyprland.lua.bak`, zsh caches, builds y archivos temporales.
- Estado ASUS (aura, slash, tablas de curvas inactivas y tunings): se transcribe
  la política comprobada, sin importar ajustes de firmware/versiones.
- fstab, UUID, initramfs y boot entries generados. El esquema se documenta;
  archinstall genera lo correspondiente a los discos de la instalación nueva.
- Paquetes adicionales ajenos al entorno (incluido el agente de desarrollo),
  paquetes debug y aplicaciones GNOME opcionales; no se elimina ninguno.

No se detectaron secretos obvios en los archivos nuevos/modificados. El escaneo
es de patrones y revisión de configuraciones: no acredita la inexistencia de
todo dato sensible en cualquier archivo histórico del repositorio.

## Validación de la primera sincronización (histórica)

- `bash -n` del instalador y captura histórica; `sh -n` del script de tapa;
  `zsh -n` para Zsh/P10k/plugin sudo.
- `luac -p` de los ocho archivos Lua sin ejecutarlos; `hyprctl configerrors`
  de la sesión viva vacío. No se recargó ni reemplazó la sesión.
- Siete pruebas en directorios temporales: dry-run sin escrituras, backup,
  idempotencia, archivos ajenos conservados, symlink de destino sin atravesar,
  padre symlink rechazado antes de escribir, origen ausente, archivo antiguo
  archivado y enlaces relativos restaurados (algunos casos comparten prueba).
- Simulación de configs, assets, root y servicios. En el HOME real propone
  Zsh portable, tres enlaces GTK4 relativos, los dos finales de CSS
  normalizados y 34 fuentes en el destino moderno. No se ejecutó `--apply` sobre ese HOME.
- Todos los paquetes seleccionados existen en la base local, con clasificación
  native/foreign comprobada. No se hizo `pacman -Sy` ni modificación de bases.
- Enlaces de `.config`, `.themes` e `.icons` sin roturas ni destinos externos
  al repositorio; permisos ejecutables del instalador y script de tapa.
- `git diff --check`, escaneo de secretos sin imprimir valores y comprobación
  de enlaces Markdown locales. ShellCheck no está instalado; no se afirmó usarlo.

Las pruebas no cubren un borrado/reinstalación real ni una descarga e instalación
completa de todos los paquetes. Las versiones disponibles en Arch cambiarán.
