
# Source Powerlevel10k theme for both users
if [[ -r /root/.powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /root/.powerlevel10k/powerlevel10k.zsh-theme
elif [[ -r /home/blaze/.powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /home/blaze/.powerlevel10k/powerlevel10k.zsh-theme
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Manual configuration
PATH=/root/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/blaze/.local/bin/ctgen:/home/blaze/go/bin:/home/blaze/.cargo/bin:/opt/android-studio/bin

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
source /usr/share/zsh/plugins/sudo.plugin.zsh

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
