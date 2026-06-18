# ~/.bashrc

# Exit if not running interactively
case $- in
    *i*) ;;
      *) return;;
esac

# History -------------------------------------------------------------------

# Ignore duplicates and lines starting with space
HISTCONTROL=ignoreboth

# Append to history file instead of overwriting
shopt -s histappend

# Unlimited history size
HISTSIZE=
HISTFILESIZE=

# ISO-8601 timestamps in history output
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "

# Window --------------------------------------------------------------------

# Recheck window size after each command
shopt -s checkwinsize

# Less pipe for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Chroot --------------------------------------------------------------------

# Detect chroot for prompt decoration
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Prompt --------------------------------------------------------------------

# Detect terminal color support
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Uncomment to force color prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Set colored prompt with date, time, user, host, and working dir
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\D{%Y-%m-%d} \A\[\033[00m\] \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\D{%Y-%m-%d} \A \u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Set xterm title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# Color support -------------------------------------------------------------

# Enable color output for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Aliases -------------------------------------------------------------------

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Desktop notification for long-running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Source user aliases from separate file
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Completions ---------------------------------------------------------------

# Enable programmable bash completions
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Environment ---------------------------------------------------------------

# Local machine-specific env (not tracked in dotfiles)
. "$HOME/.local/bin/env"

# Go binaries
export PATH="$HOME/go/bin:$PATH"

# Vim jumps alias (dump jump list to file)
alias vimjumps='vim -c "redi @a | sil jumps | redi END | new | put a | 1put | w! /tmp/jlist.txt | qa!" && sed "s/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r//" /tmp/jlist.txt'

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# SSH agent ----------------------------------------------------------------

# Start SSH agent if not running, reconnect if orphaned, then load key
if ! { [[ -S "$SSH_AUTH_SOCK" ]] && ssh-add -l > /dev/null 2>&1; }; then
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        ssh-agent -s > ~/.ssh/agent.env
    fi
    if [[ -f ~/.ssh/agent.env ]]; then
        . ~/.ssh/agent.env > /dev/null
    fi
    if ! { [[ -S "$SSH_AUTH_SOCK" ]] && ssh-add -l > /dev/null 2>&1; }; then
        # Agent running but no valid socket — recreate env file
        sock=$(find /tmp -maxdepth 2 -path "*/agent.*" -user "$USER" 2>/dev/null | head -1)
        pid=$(pgrep -u "$USER" ssh-agent | head -1)
        if [[ -n "$sock" && -n "$pid" ]]; then
            cat > ~/.ssh/agent.env <<EOF
SSH_AUTH_SOCK=$sock; export SSH_AUTH_SOCK;
SSH_AGENT_PID=$pid; export SSH_AGENT_PID;
EOF
            . ~/.ssh/agent.env > /dev/null
        fi
    fi
fi
ssh-add ~/.ssh/id_ed25519 2>/dev/null

# Directory stack persistence -----------------------------------------------

# Save dirstack on exit so it can survive across sessions
mkdir -p ~/.cache/dirstack
trap 'dirs -l -p > ~/.cache/dirstack/$(basename $(tty)) 2>/dev/null' EXIT
# Uncomment to auto-restore dirstack on login:
#[[ -f ~/.cache/dirstack/$(basename $(tty)) ]] && mapfile -t _stack < ~/.cache/dirstack/$(basename $(tty)) && { for (( _i=${#_stack[@]}-1; _i>=0; _i-- )); do pushd -n "${_stack[_i]}" >/dev/null 2>&1; done; unset _i _stack; }
