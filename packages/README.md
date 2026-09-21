# Dependencias auditadas

Fuente: base local de pacman el 2026-09-21, `pacman -Q`, `-Qqe`,
`-Qqn`, `-Qqm`, `-Qqen` y `-Qqem`. Las listas contienen únicamente paquetes
instalados. No son un volcado de las más de mil dependencias del sistema.

| Lista | Propósito |
|---|---|
| base.txt | Kernel, firmware, AMD, arranque, Btrfs/LVM, red y herramientas de instalación |
| desktop.txt | GNOME/GDM fallback, Nautilus, Bluetooth y audio |
| hyprland.txt | Hyprland Lua, hypridle, Mesa, portales y agente polkit |
| asus.txt | asusctl, rog-control-center, power-profiles-daemon |
| terminal.txt | Kitty, Zsh, LSD y plugins empaquetados |
| fonts-theme.txt | GTK y fuentes del sistema |
| utilities.txt | Diagnóstico, editores y herramientas de administración instaladas |
| ambxst.txt | Dependencias del instalador local de Ambxst, sin repetir las anteriores |
| apps.txt | Firefox y Obsidian instalados; VS Code está en aur.txt |
| optional/ocr-extra.txt | Idiomas OCR instalados pero desactivados; no se instalan por defecto |
| optional/theme-build.txt | sassc para reconstruir Colloid; no hace falta para copiar el snapshot |
| aur.txt | Ocho paquetes externos seleccionados; instalar con yay como usuario |
| versions.tsv | Versiones y razón de instalación observadas; referencia, no un lockfile |

`asusctl` y `rog-control-center` son **oficiales** en esta máquina (6.5.0-1).
`quickshell`, `awww` y `matugen` también están empaquetados; awww está instalado
pero no se necesita para restaurar el wallpaper de Ambxst y se omite.
El agente que corre realmente es `/usr/lib/hyprpolkitagent/hyprpolkitagent`.
`pactl`, utilizado en startup, viene de `libpulse`.

En AUR se incluyen Brave Origin Nightly, Discord Canary, elecwhat, Spotify,
VS Code, Murrine y las fuentes Phosphor/League Gothic que pidió Ambxst. `gtk2` es una
dependencia externa instalada de Murrine; yay debe resolverla. No se incluye
ningún paquete `-debug`. `yay` está instalado (13.0.1-1); su bootstrap es manual.
`pacman -Qm` solo significa «ajeno a las bases sync locales», no demuestra por
sí mismo que un paquete proceda de AUR. Los nombres seleccionados corresponden
a las aplicaciones y dependencias AUR utilizadas aquí.

Ambxst/axctl y Powerlevel10k **no son paquetes pacman**. El plugin sudo tampoco
tiene propietario pacman. Véase [instalaciones manuales](../docs/manual-installs.md).
Colloid-Dark, Kora, GoogleDot-Black, Hack, MesloLGS y Montserrat se restauran desde
los assets revisados; no hace falta instalar otros dotfiles.

No se incluyen NVIDIA, PRIME, TLP ni utilidades para alterar voltajes/TDP.
La máquina aún tiene `nvidia-open`, `nvidia-utils`, `libva-nvidia-driver` y
`switcheroo-control`; no se desinstalaron durante esta auditoría. GNOME se
conserva y no se realiza ninguna limpieza de paquetes.

Telegram no tiene ejecutable `Telegram` en PATH ni paquete `telegram-desktop`.
Startup comprueba el ejecutable antes de lanzarlo: no instalo Telegram por una
línea histórica. VS Code sí está instalado actualmente (`visual-studio-code-bin`)
y queda incluido en AUR; se añadió después del inventario inicial. Chromium,
Burp y VMware no se deducen de sus reglas de ventanas.

`qt6ct` reproduce el platform theme que Ambxst exporta a Quickshell. Los paquetes
OCR de idiomas desactivados y `sassc` se separan bajo `optional/`; no se eliminan
del sistema actual. Para reconstruir Colloid, instala `sassc` además de los
requisitos GTK/Murrine ya documentados.

Arch es rolling: instalar estas listas obtiene las versiones disponibles en ese
momento y sus dependencias. Evitar actualizaciones parciales. No forzar únicamente
Hyprland 0.56.2 sobre bibliotecas más recientes. Las versiones sirven para comparar
y, si fuese necesario, reconstruir un conjunto coherente desde Arch Linux Archive.

```bash
./scripts/install.sh packages           # ver selección oficial
./scripts/install.sh packages --apply   # confirmación + pacman -Syu --needed
./scripts/install.sh aur                # ver selección AUR
./scripts/install.sh aur --apply        # comprobar yay, revisar PKGBUILDs
```

Las aplicaciones GNOME adicionales que no hacen falta para entrar al fallback
(Maps, Music, Weather, Tour, etc.) permanecen instaladas en el sistema actual;
no se exige reinstalar todo el grupo `gnome` para reproducir esta sesión.
El grupo completo es una elección válida en archinstall si se quiere recuperar
también esas aplicaciones.
