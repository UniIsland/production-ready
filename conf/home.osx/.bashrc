# sourced by .profile if running bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# show full path in prompt
# also make it colorful
case "$TERM" in
	xterm-*color) color_prompt=yes;;
esac
if [ "$color_prompt" = yes ]; then
	PS1='\u@\h:\[\033[01;36m\]\w\[\033[00m\] \$ '
	export CLICOLOR=true
else
	PS1='\u@\h:\w \$ '
fi
unset color_prompt

if [ -f /opt/local/etc/bash_completion ]; then
	. /opt/local/etc/bash_completion
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


