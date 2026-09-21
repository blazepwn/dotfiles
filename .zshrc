
# Powerlevel10k is loaded below after plugins and keybindings.

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Manual configuration
typeset -U path PATH
path=("$HOME/.local/bin" $path)
# Conservo estas rutas históricas como opcionales: no está documentado si
# volveré a usar esas herramientas. No añado directorios inexistentes al PATH.
for dotfiles_optional_bin in "$HOME/.local/bin/ctgen" "$HOME/go/bin" \
                             "$HOME/.cargo/bin" /opt/android-studio/bin; do
    [[ -d $dotfiles_optional_bin ]] && path+=("$dotfiles_optional_bin")
done
unset dotfiles_optional_bin
export PATH

# Manual aliases
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='bat'
alias catn='/usr/bin/cat'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh

# fzf improvement
function fzf-lovely(){

  if [ "$1" = "h" ]; then
    fzf -m --reverse --preview-window down:20 --preview '[[ $(file --mime {}) =~ binary ]] &&
                echo {} is a binary file ||
                 (bat --style=numbers --color=always {} ||
                  highlight -O ansi -l {} ||
                  coderay {} ||
                  rougify {} ||
                  cat {}) 2> /dev/null | head -500'

  else
          fzf -m --preview '[[ $(file --mime {}) =~ binary ]] &&
                           echo {} is a binary file ||
                           (bat --style=numbers --color=always {} ||
                            highlight -O ansi -l {} ||
                            coderay {} ||
                            rougify {} ||
                            cat {}) 2> /dev/null | head -500'
  fi
}

# Finalize Powerlevel10k instant prompt. Should stay at the bottom of ~/.zshrc.
(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize

# Keybindings
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

source ~/.powerlevel10k/powerlevel10k.zsh-theme
