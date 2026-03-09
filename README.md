<div align="center">
  <img src="./Pictures/Examples/preview-01.png" alt="blaze dotfiles preview" width="100%" />
  <h1>blaze dotfiles</h1>
  <p>Hyprland + Kitty + Zsh + Powerlevel10k + lsd + fonts, icons y wallpapers.</p>
  <p>Tambien estoy usando <a href="https://github.com/Axenide/Ambxst">Ambxst</a> como shell layer para barra, dock y extras de escritorio.</p>
</div>

## Preview

<p align="center">
  <img src="./Pictures/Examples/preview-01.png" alt="Preview 01" width="49%" />
  <img src="./Pictures/Examples/preview-02.png" alt="Preview 02" width="49%" />
</p>

<p align="center">
  <img src="./Pictures/Examples/preview-03.png" alt="Preview 03" width="49%" />
  <img src="./Pictures/Examples/preview-04.png" alt="Preview 04" width="49%" />
</p>

## Stack

- Hyprland con configuracion modular en `~/.config/hypr`
- Kitty con `Hack Nerd Font`
- Zsh + Powerlevel10k + `lsd`
- Ambxst para shell UI
- Fuentes, iconos y wallpapers locales

## Ambxst

Estoy usando [Ambxst](https://github.com/Axenide/Ambxst) junto con esta config. En mi arranque de Hyprland se ejecuta con `exec-once = ambxst`.

- Instalacion upstream: `curl -L get.axeni.de/ambxst | sh`
- README upstream: el prerequisito principal es tener `Hyprland`
- Ruta documentada upstream: `~/.config/Ambxst`
- Ruta encontrada en esta maquina: `~/.config/ambxst`

Rutas locales detectadas para Ambxst:

- `~/.config/ambxst/config/bar.json`
- `~/.config/ambxst/config/dock.json`
- `~/.config/ambxst/config/hyprland.json`
- `~/.config/ambxst/config/lockscreen.json`
- `~/.config/ambxst/config/notch.json`
- `~/.config/ambxst/config/theme.json`

## Repo Paths

Este directorio replica la estructura del `home` para que sea facil restaurar o versionar los archivos.

| Repo path | Ruta real | Uso |
| --- | --- | --- |
| `.config/hypr` | `~/.config/hypr` | Config principal de Hyprland |
| `.config/kitty` | `~/.config/kitty` | Terminal Kitty |
| `.config/lsd` | `~/.config/lsd` | Tema y opciones de `lsd` |
| `.zshrc` | `~/.zshrc` | Shell principal |
| `.p10k.zsh` | `~/.p10k.zsh` | Prompt de Powerlevel10k |
| `.icons` | `~/.icons` | Iconos y cursores |
| `.fonts` | `~/.fonts` | Nerd Fonts y fuentes extra |
| `Pictures/Wallpapers` | `~/Pictures/Wallpapers` | Wallpapers |
| `Pictures/Examples` | `~/Pictures/Examples` | Capturas para el README |

## Required Packages And Plugins

Los nombres pueden variar segun distro. Esta lista esta sacada de los archivos reales de este repo y de las rutas que tu setup referencia.

### Core

- `hyprland`
- `kitty`
- `zsh`
- `powerlevel10k`
- `lsd`
- `ambxst`

### Zsh And CLI

- `zsh-syntax-highlighting` -> `/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`
- `zsh-autosuggestions` -> `/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh`
- `sudo.plugin.zsh` -> `/usr/share/zsh/plugins/sudo.plugin.zsh`
- `fzf` -> `~/.fzf.zsh`
- `bat` -> usado por alias `cat='bat'`
- `highlight` -> fallback de preview en `fzf-lovely`
- `coderay` -> fallback de preview en `fzf-lovely`
- `rougify` -> fallback de preview en `fzf-lovely`

### Hyprland And Wayland Utilities

- `wl-clipboard` -> `wl-copy` para copiar screenshots
- `grim` -> captura de pantalla
- `slurp` -> seleccion de region
- `imagemagick` -> `magick` para post-proceso de screenshots
- `libnotify` -> `notify-send`
- `swww` -> cambio de wallpaper
- `hyprpicker` -> picker de color
- `brightnessctl` -> brillo de pantalla y teclado
- `playerctl` -> controles multimedia
- `nwg-look` -> aplicar look GTK
- `pactl` -> audio
- `dbus-update-activation-environment`
- `qt5ct`
- `qt6ct`
- un agente de `polkit`, por ejemplo `hyprpolkitagent`

### Fonts, Icons And Themes

- `Hack Nerd Font` -> usada por Kitty y por el script de screenshot
- `MesloLGS NF` -> util para Powerlevel10k
- `Montserrat` -> fuente adicional incluida
- `Kora Light` -> tema de iconos en `~/.icons/index.theme`
- `Bibata-Modern-Ice` -> cursor por defecto en `~/.icons/default/index.theme`
- `Qogir` -> cursor aplicado en `~/.config/hypr/conf/startup.conf`
- `Lavanda-Sea-Dark` -> tema GTK aplicado desde Hyprland

### Optional Apps Referenced By Startup Or Keybinds

- `firefox`
- `chromium`
- `brave`
- `nautilus`
- `code`
- `missioncenter`
- `scrcpy`
- `asusctl`
- `rog-control-center`
- `Telegram`
- `discord-canary`
- `flatpak` -> para `io.missioncenter.MissionCenter`

## Extra Runtime Paths

Estas rutas tambien aparecen en tu setup, aunque no todas estan versionadas en este repo:

- `~/.config/eww`
- `~/.powerlevel10k/powerlevel10k.zsh-theme`
- `~/Pictures/icon/final-nofondo.png`
- `~/Pictures/Screenshots`

## Restore

Restaurar una configuracion puntual:

```bash
cp -a ~/.dotfiles/.config/kitty ~/.config/
```

Restaurar shell:

```bash
cp -a ~/.dotfiles/.zshrc ~/
cp -a ~/.dotfiles/.p10k.zsh ~/
```

Restaurar recursos:

```bash
cp -a ~/.dotfiles/.icons ~/
cp -a ~/.dotfiles/.fonts ~/
cp -a ~/.dotfiles/Pictures/Wallpapers ~/Pictures/
```

## Note

Este respaldo incluye fuentes, iconos, wallpapers y capturas, asi que el directorio puede ocupar bastante espacio.
