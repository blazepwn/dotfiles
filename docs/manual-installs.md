# Componentes instalados manualmente

Instala primero los paquetes. Uso `scripts/manual-components.sh` para preparar
Ambxst/axctl y P10k con versiones fijadas. Sin `--apply` muestra el plan.
Al repetir, verifica y conserva cada componente ya completo. Un binario o
checkout distinto detiene la operación: no hace reset, pull ni sobrescritura.
Una descarga fallida no obliga a borrar un checkout válido ni el otro binario.
Los clones incompletos quedan en un staging `.dotfiles-checkout.*` identificado
por el script; revisa ese directorio antes de retirarlo manualmente.

## Ambxst y axctl

Inspección local: `/usr/local/bin/ambxst` (1.3.7), `/usr/local/bin/axctl`
(v0.0.26), shell en `~/.local/src/ambxst`, Quickshell `/usr/bin/qs`.
Ninguno de los dos binarios pertenece a pacman. El checkout de shell estaba
limpio en `9a9026a4e6ac5431a68fa6928fd1af32918b98e3`.

El [instalador de Ambxst](https://github.com/Axenide/Ambxst/blob/9a9026a4e6ac5431a68fa6928fd1af32918b98e3/install.sh)
explica las rutas observadas: instala dependencias, descarga binarios,
instala axctl, clona la shell y configura servicios. También actualiza el
checkout y utiliza releases `latest`; por eso no se ejecuta automáticamente
desde el restaurador. La siguiente instalación usa los artefactos exactos
comprobados contra los binarios locales. Es específica de x86_64.

```bash
./scripts/manual-components.sh ambxst
./scripts/manual-components.sh ambxst --apply
```

Los hashes se verificaron con el [release 1.3.7](https://github.com/Axenide/Ambxst/releases/tag/1.3.7)
y el [release axctl v0.0.26](https://github.com/Axenide/axctl/releases/tag/v0.0.26).
El tag de Ambxst **no** lleva prefijo `v`. No se guardan binarios en Git.

Comprueba los binarios desde GNOME/TTY:

```bash
ambxst version
axctl --version
```

`ambxst install hyprland` solo añade el import al principal; NO genera el Lua
que ese import necesita. El principal ya lo restaura este repo: no hace falta
ejecutar ese subcomando encima. Primero restaura assets, system y configs.

Si falta `~/.local/share/ambxst/hyprland.lua`, cierra GNOME y ejecuta desde una
TTY local `./scripts/bootstrap-ambxst.sh --apply`. Abre una sesión temporal
de Hyprland con Kitty y una instancia de Ambxst. No carga el principal normal
ni importa un generado que todavía no existe. Ambxst arranca axctl y la shell
escribe la configuración que axctl convierte a Lua.

En el Kitty temporal, espera a que aparezca el archivo y compruébalo:

```bash
test -s "$HOME/.local/share/ambxst/hyprland.lua"
luac -p "$HOME/.local/share/ambxst/hyprland.lua"
```

Cuando ambas comprobaciones pasen, sal de esa sesión temporal:

```bash
ambxst quit
hyprctl dispatch 'hl.dsp.exit()'
```

Entra en Hyprland normalmente desde GDM. El principal carga Ambxst y después
mis overrides. El bootstrap no escribe el archivo generado; tampoco lo guardo
en Git. Si falla su generación, revisa Ambxst/axctl antes de entrar a la sesión
normal. La secuencia se dedujo del código local; la reinstalación gráfica
completa en un HOME vacío sigue pendiente de una prueba separada.

## Powerlevel10k

Se usa un checkout manual en `~/.powerlevel10k`, sin cambios locales conocidos
en los archivos del prompt respaldados. Instalar como usuario:

```bash
./scripts/manual-components.sh p10k
./scripts/manual-components.sh p10k --apply
```

`.p10k.zsh` conserva exactamente el prompt actual. `.zshrc` mantiene aliases,
plugins, fzf-lovely y teclas; adapta las rutas de usuario a `$HOME`, conserva
el PATH heredado e incluye `~/.local/bin`. Se elimina la carga duplicada del
tema y la búsqueda del tema de root. No se agrega un alias `tree` inventado:
el archivo vivo no lo tiene; se puede ejecutar `lsd --tree`.

## Plugin sudo de Zsh

Ruta real: `/usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh`.
Es una instalación manual del plugin de Oh My Zsh (Esc, Esc antepone `sudo`).
La copia en `vendor/zsh-sudo` coincide byte a byte con
[upstream](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/sudo/sudo.plugin.zsh)
consultado durante la auditoría. Se incluye su licencia MIT.
La acción `scripts/install.sh system --apply` lo instala con confirmación y
backup. No hace falta instalar todo Oh My Zsh.

## Colloid

El checkout encontrado en `~/Downloads/Colloid-gtk-theme` estaba limpio en
`fe11342f37f124f1b29d44cf33e9a06053f4bba2`. Tiene las dependencias GTK >= 3.20,
gnome-themes-extra, Murrine y sassc descritas por
[Colloid](https://github.com/vinceliuice/Colloid-gtk-theme).
También se comprobaron gtk3, gtk4, libadwaita y fontconfig instalados.

La restauración normal copia el **tema instalado** en `.themes/Colloid-Dark`,
con su paleta actual, y evita recompilar. Si se quiere reconstruir desde fuente,
en una instalación nueva y antes de restaurar los assets/configs:

```bash
sudo pacman -Syu --needed sassc
./scripts/manual-components.sh colloid --apply
(
    set -eu
    build_output=$(mktemp -d)
    cd "$HOME/.local/src/Colloid-gtk-theme"
    ./install.sh -d "$build_output" -c dark
    printf 'Tema reconstruido para comparar, sin sustituir el activo: %s\n' "$build_output"
)
```

`-l` es la opción upstream para integrar GTK4/libadwaita. No la ejecuto en
ese bloque de comparación porque enlazaría archivos del HOME activo: el restore
ya recupera la integración mediante sus enlaces GTK4 revisados. No afirmo que
conozca los argumentos exactos usados originalmente (no leí el historial privado). El CSS activo ya fue recoloreado por Ambxst: reinstalar
Colloid desde fuente puede cambiarlo, de ahí el snapshot del tema funcional.
La licencia GPL-3.0 está en `vendor/Colloid-LICENSE`; copyright de los autores
de Colloid. Los iconos/fuentes/wallpapers históricos conservan su autoría y
no se relicencian por estar en este repositorio.
