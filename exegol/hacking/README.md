# Zsh de Exegol `hacking`

Powerlevel10k con caja verde ` hacking`, directorio azul, estado de Git y
prompt compacto. Conserva los plugins de Exegol y su indicador de usuario,
dominio y grabación. Kitty ya tiene configurada Hack Nerd Font.

## Archivos instalados

- `/opt/my-resources/setup/zsh/hacking/`: estos archivos y Powerlevel10k.
- `/opt/my-resources/setup/zsh/zshrc`: carga este perfil solo en `exegol-hacking`.
- `/root/.p10k.zsh`: enlace a la configuración persistente de Powerlevel10k.
- `/opt/my-resources/backups/hacking-*`: copia previa de `.zshrc` y del perfil compartido.

Los recursos persisten en `~/.exegol/my-resources` del host. El perfil se carga
desde el punto de personalización de Exegol en `/root/.zshrc`.
Powerlevel10k se copió de la instalación local del host.

## Restaurar el perfil

El restore general del repo solo configura el host. Para un contenedor `hacking`
ya creado, copia estos archivos a los recursos persistentes del host, conservando
antes una copia de los destinos existentes:

| Origen en el repo | Destino bajo `~/.exegol/my-resources/setup/zsh/` |
|---|---|
| `exegol/hacking/zshrc` | `hacking/zshrc` |
| `exegol/hacking/p10k.zsh` | `hacking/p10k.zsh` |
| `exegol/hacking/burpsuite` | `hacking/burpsuite` (ejecutable) |
| `exegol/hacking/install-burp-runtime.sh` | `hacking/install-burp-runtime.sh` (ejecutable) |
| `.config/bat/config` | `hacking/config/bat/config` |
| `.config/nvim/init.lua` | `hacking/config/nvim/init.lua` |
| `exegol/hacking/config/lsd/config.yaml` | `hacking/config/lsd/config.yaml` |

Los enlaces de Bat y Neovim bajo `exegol/hacking/config/` apuntan a las copias
canónicas del repo. Al copiarlos fuera del checkout, usa `cp -L` o copia
directamente los orígenes de la tabla para que los destinos sean archivos normales.

Copia también el checkout de Powerlevel10k de `~/.powerlevel10k` a
`hacking/powerlevel10k`; se prepara con `scripts/manual-components.sh p10k`.
Añade una sola vez el bloque de [../zshrc](../zshrc) al archivo compartido
`setup/zsh/zshrc`, conservando cualquier configuración de otros contenedores.

Dentro del contenedor, guarda los destinos existentes y enlaza `/root/.p10k.zsh`
a `/opt/my-resources/setup/zsh/hacking/p10k.zsh`, y los directorios
`/root/.config/{bat,nvim,lsd}` a sus correspondientes directorios bajo
`/opt/my-resources/setup/zsh/hacking/config/`. Se requieren `bat` (comando
`batcat`), `neovim` y `lsd` dentro del contenedor. Después ejecuta el instalador
del runtime de Burp y abre otra sesión Zsh. La imagen y el contenedor se preparan
por separado; este respaldo no los crea ni incluye su estado.

## Uso

Abre otra sesión o ejecuta `exec zsh` dentro del contenedor.
Alt+izquierda y Alt+derecha mueven el cursor por palabras; Alt+B y Alt+F
ofrecen la misma función. Inicio, Fin y Suprimir también quedan configurados.

Para cambiar el estilo, edita `/root/.p10k.zsh` dentro del contenedor.
Para desactivar este perfil, elimina del archivo compartido el bloque
marcado `dotfiles: hacking` y abre una nueva sesión.

## Herramientas y transparencia

`ls`, `l`, `ll`, `la` y `lla` usan `lsd`; `cat` y `bat` usan `batcat`.
`catn` conserva el comando original. `vim`, `EDITOR` y `VISUAL` usan Neovim.
Los paquetes del contenedor se instalaron desde Debian Bookworm.

Los directorios `/root/.config/nvim`, `/root/.config/bat` y `/root/.config/lsd`
enlazan a `config/` dentro del perfil persistente `hacking`.
Neovim y bat usan el fondo de la terminal. La configuración de Kitty del host
usa opacidad `0.90`; abre una instancia nueva de Kitty para aplicarla.

En Arch, `batcat` es un wrapper de `bat` en `~/.local/bin`.
La configuración compartida de Neovim está en `.config/nvim/init.lua` del repo.

## Inicio sin contraseña y aplicaciones gráficas

El alias `xxx='exegol start hacking'` abre el contenedor. `exegol` apunta al
ejecutable de pipx en `~/.local/bin/exegol`, ejecutado como el usuario del host.
Ese usuario ya pertenece al grupo `docker`.

Exegol debe iniciarse desde la terminal de la sesión gráfica. Así puede ejecutar
`xhost` con acceso a Xwayland y autorizar las aplicaciones del contenedor.
El contenedor ya comparte el directorio de sockets X11 y el socket Wayland.
Usar `sudo` en este alias provoca que `xhost` pierda el acceso a la sesión gráfica.

Tras recargar Zsh, ejecuta `xxx` y luego `burpsuite` dentro del contenedor.
Para diagnosticar una aplicación, ejecútala primero sin redirigir su salida
a `/dev/null`.

## Burp nítido con escala fraccionaria

El lanzador `burpsuite` usa JetBrains Runtime 21.0.11 con
`-Dawt.toolkit.name=WLToolkit` cuando existe el socket Wayland. Burp pasa a ser
una aplicación Wayland y sigue la escala del monitor (160 % en eDP-1).
La pantalla conserva 2560×1600 y su relación 16:10. No se modifica el escalado
global de Xwayland. La regla de Hyprland reconoce también el identificador
Wayland de Burp y lo asigna al espacio 3.

El runtime está en `hacking/jbr-21` dentro de los recursos persistentes; no se
incluye en Git. Para reinstalarlo, ejecuta `install-burp-runtime.sh` dentro del
contenedor. El script fija la versión y verifica su SHA-512 oficial.

En Burp, deja desactivado **Configure scaling settings** para que use la escala
de Wayland. El runtime es distinto del OpenJDK incluido en Exegol: Burp avisa
que JetBrains no es una plataforma probada por PortSwigger. Se confirmó ese
aviso una vez durante la configuración. Si una extensión o un diálogo presenta
incompatibilidades, puedes arrancar con el Java original:

```sh
BURP_DISPLAY_BACKEND=x11 burpsuite
```

Referencias: [runtime oficial](https://github.com/JetBrains/JetBrainsRuntime/releases/tag/jbr-release-21.0.11b1163.116),
[Wayland en Java](https://youtrack.jetbrains.com/projects/WI/articles/JBR-A-43/Wayland-Is-Coming),
[escalado de Burp](https://portswigger.net/burp/documentation/desktop/settings/ui/display).
