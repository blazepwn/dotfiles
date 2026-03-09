<div align="center">
  <img src="./Pictures/Examples/preview-01.png" alt="blaze dotfiles preview" width="100%" />
  <h1>blaze dotfiles</h1>
  <p>Hyprland + Kitty + Zsh + Powerlevel10k + lsd + fonts, icons y wallpapers.</p>
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

## Incluye

- `~/.config/hypr`
- `~/.config/kitty`
- `~/.config/lsd`
- `~/.zshrc`
- `~/.p10k.zsh`
- `~/.icons`
- `~/.fonts`
- `~/Pictures/Wallpapers`
- `~/Pictures/Examples`

## Estructura

Este directorio replica la estructura del `home` para que sea facil restaurar o versionar los archivos.

```text
.dotfiles/
├── .config/
│   ├── hypr/
│   ├── kitty/
│   └── lsd/
├── .fonts/
├── .icons/
├── .p10k.zsh
├── .zshrc
└── Pictures/
    ├── Examples/
    └── Wallpapers/
```

## Restaurar

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

## Nota

Este respaldo incluye fuentes, iconos, wallpapers y capturas, asi que el directorio puede ocupar bastante espacio.
