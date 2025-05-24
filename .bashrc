#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

fastfetch --logo small -s break:os:kernel:host:uptime:shell
printf "\n"

# env for go
export PATH=$PATH:$(go env GOPATH)/bin

