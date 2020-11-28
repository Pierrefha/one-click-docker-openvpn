# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# set your home directory. useful if you want to use these files for root and
# perhaps other users.
export DOT_RC_HOME_DIRECTORY="/home/xddq"
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# keep this uncommented to store duplicates
# HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history

# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -lhaF'
alias py='python3'
# use trash-cli to delete etc.
alias rm='printf "Stop being stupid. Use trash-put (alias tp) to delete stuff.\n" ; false'
alias tp='trash-put'
alias logout='i3-msg exit'
# config files we might want to adapt
alias cvim='vim $DOT_RC_HOME_DIRECTORY/.vim/vimrc'
alias ci3='vim $DOT_RC_HOME_DIRECTORY/.config/i3/config'
alias cbash='vim $DOT_RC_HOME_DIRECTORY/.bashrc'
# git alias
alias gs='git status'
alias gc='git commit'
alias gcn='git clean --dry-run'
alias gcf='git clean --force'
alias ga='git add'
alias gas='git add ./source/.'
alias gp='git push'
alias gd='git diff'
alias gl='git log'
alias glo='git log --oneline'
# 1)push directory from navigation stack onto navigation stack
alias pd='pushd'
alias pd.='pushd . && dirs -v -l'
alias pd0='pushd +0 && dirs -v -l'
alias pd1='pushd +1 && dirs -v -l'
alias pd2='pushd +2 && dirs -v -l'
alias pd3='pushd +3 && dirs -v -l'
alias pd4='pushd +4 && dirs -v -l'
alias pd5='pushd +5 && dirs -v -l'
# 2)pop directory from navigation stack
alias popd='popd'
alias popd1='popd +1 && dirs -v -l'
alias popd2='popd +2 && dirs -v -l'
alias popd3='popd +3 && dirs -v -l'
alias popd4='popd +4 && dirs -v -l'
alias popd5='popd +5 && dirs -v -l'
# 3)list directory stack
alias ld='dirs -v -l'
# 4) TODO build std directory stack for shell login

# docker alias
alias dcup='docker-compose up -d'
alias dcc='docker-compose config'
alias dc='docker container'
alias dcr='docker container run'
alias dcls='docker container ls'
alias dcll='docker container ls -a'
alias dci='docker container inspect'
alias dcrm='docker container rm'
alias di='docker image'
alias dils='docker image ls'
alias dill='docker image ls -a'
alias dirm='docker image rm'
alias dcprune='docker container ls -aq | xargs docker container rm -f'
alias diprune='docker image ls -aq | xargs docker image rm -f'
# exam preparation
alias currd='cd ~/Documents/current_semester/AI/recordings-lecture'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# set editor to vim
export EDITOR=vim
