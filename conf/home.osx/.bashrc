# sourced by .profile if running bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# show full path in prompt
# also make it colorful
case "$TERM" in
	xterm-*color) color_prompt=yes;;
esac
if [ "$color_prompt" = yes ]; then
	#PS1='\[\e]0;\u@\h: \w\a\\u@\h:\[\e[0;36m\]\w\[\e[0m\] \$ '
	PS1='\[\e]0;\u: \w\a\]\u@\h:\[\e[0;36m\]\w\[\e[0m\] \$ '
	export CLICOLOR=true
else
	PS1='\[\e]0;\u@\h: \w\a\]\u@\h:\w \$ '
fi
unset color_prompt

if [ -f /opt/local/etc/bash_completion ]; then
	. /opt/local/etc/bash_completion
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

## mysql2 gem missing the dynamic library from MySQL.
## refs: http://stackoverflow.com/questions/4512362/rails-server-fails-to-start-with-mysql2-using-rvm-ruby-1-9-2-p0-on-osx-10-6-5
#export DYLD_LIBRARY_PATH="/usr/local/mysql/lib:$DYLD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="/usr/local/mysql/lib"

