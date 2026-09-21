#!/usr/bin/env bash
# Instalación reanudable de los componentes manuales observados, sin actualizaciones implícitas.
set -euo pipefail
die() { printf '%s\n' "$*" >&2; exit 1; }
[[ $# -ge 1 && $# -le 2 ]] || die "Uso: $0 ambxst|p10k|colloid [--apply]"
case $1 in ambxst|p10k|colloid) ;; *) die 'Componente desconocido.' ;; esac
[[ ${2:-} == '' || ${2:-} == --apply ]] || die 'Opción desconocida.'
if [[ ${2:-} != --apply ]]; then
    echo "Plan: instalar/verificar $1 con versiones fijadas; conservar destinos existentes."
    exit 0
fi
(( EUID != 0 )) || die 'Ejecuta como usuario normal.'
source /etc/os-release
[[ $ID == arch ]] || die 'Se requiere Arch Linux.'
for cmd in pacman git curl sha256sum; do command -v "$cmd" >/dev/null || die "Falta $cmd"; done

checkout() {
    local url=$1 commit=$2 target=$3 staging
    if [[ -e $target || -L $target ]]; then
        [[ ! -L $target && -d $target/.git ]] || die "Revisa el destino existente: $target"
        [[ $(git -C "$target" remote get-url origin) == "$url" ]] || die "Origen inesperado: $target"
        [[ -z $(git -C "$target" status --porcelain) ]] || die "Hay cambios locales: $target"
        [[ $(git -C "$target" rev-parse HEAD) == "$commit" ]] || die "Versión distinta; no se cambia automáticamente: $target"
        echo "Checkout verificado: $target"
        return
    fi
    mkdir -p -- "$(dirname -- "$target")"
    staging=$(mktemp -d "$(dirname -- "$target")/.dotfiles-checkout.XXXXXXXX")
    echo "Staging privado de esta operación: $staging"
    git clone -- "$url" "$staging"
    git -C "$staging" checkout --detach "$commit"
    [[ ! -e $target && ! -L $target ]] || die "El destino apareció durante la operación: $target"
    mv -T -- "$staging" "$target"
}

binary() {
    local name=$1 url=$2 hash=$3 target=/usr/local/bin/$1 downloads answer actual
    if [[ -e $target || -L $target ]]; then
        [[ -f $target && ! -L $target && -x $target ]] || die "Revisa $target"
        actual=$(sha256sum "$target"); actual=${actual%% *}
        [[ $actual == "$hash" ]] || die "Binario distinto: $target; no se reemplaza."
        echo "Binario verificado: $target"
        return
    fi
    downloads=$(mktemp -d)
    curl -fL --retry 3 "$url" -o "$downloads/$name"
    printf '%s  %s\n' "$hash" "$downloads/$name" | sha256sum -c -
    read -r -p "Instalar $name en $target con sudo (escribe SI): " answer
    [[ $answer == SI ]] || die "Cancelado. Descarga conservada en $downloads"
    [[ ! -e $target && ! -L $target ]] || die "El destino apareció: $target"
    sudo install -Dm755 -- "$downloads/$name" "$target"
    echo "Descarga verificada conservada en $downloads"
}

if [[ $1 == colloid ]]; then
    checkout https://github.com/vinceliuice/Colloid-gtk-theme.git fe11342f37f124f1b29d44cf33e9a06053f4bba2 "$HOME/.local/src/Colloid-gtk-theme"
    echo 'Solo fuentes preparadas; no se reemplazó el tema activo.'
elif [[ $1 == p10k ]]; then
    checkout https://github.com/romkatv/powerlevel10k.git d05a1b00f9a61f9578bf9dc19b8451942dde8734 "$HOME/.powerlevel10k"
else
    [[ $(uname -m) == x86_64 ]] || die 'Estos binarios son para x86_64.'
    checkout https://github.com/Axenide/Ambxst.git 9a9026a4e6ac5431a68fa6928fd1af32918b98e3 "$HOME/.local/src/ambxst"
    binary ambxst https://github.com/Axenide/Ambxst/releases/download/1.3.7/ambxst-linux-amd64 \
        5ee696c741bf1d6ffd7ea3f93b67f79d61ac6a6aafb1fab0f8e4f709b5fc81cb
    binary axctl https://github.com/Axenide/axctl/releases/download/v0.0.26/axctl_linux_amd64 \
        53f1363387e61a6c69db4d5d8caab864aff255e2fe3f8d040fd0975c5e47fac7
    pointer=$HOME/.local/share/ambxst/shell_repo
    if [[ -e $pointer || -L $pointer ]]; then
        [[ -f $pointer && ! -L $pointer && $(cat "$pointer") == "$HOME/.local/src/ambxst" ]] || die 'Revisa shell_repo; no se reemplaza.'
    else
        mkdir -p -- "$(dirname -- "$pointer")"
        printf '%s\n' "$HOME/.local/src/ambxst" > "$pointer"
    fi
    echo 'Binarios/shell preparados. Restaura configs antes del primer arranque gráfico.'
fi
