# Aliases -------------------------------------------------------------------

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# pushd shorthand (directory stack navigation)
alias cdp='pushd'

# Desktop notification for long-running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Vim jumps (dump jump list to file)
alias vimjumps='vim -c "redi @a | sil jumps | redi END | new | put a | 1put | w! /tmp/jlist.txt | qa!" && sed "s/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r//" /tmp/jlist.txt'
