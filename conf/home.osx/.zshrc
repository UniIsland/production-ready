ZSH=$HOME/.oh-my-zsh
#ZSH_THEME="robbyrussell"
ZSH_THEME="t1"
CASE_SENSITIVE="true"
DISABLE_CORRECTION="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(brew colored-man colorize command-not-found osx pyenv python rbenv vagrant)
#plugins=(debian osx vagrant)

source $ZSH/oh-my-zsh.sh

# User configuration

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

export PATH

## shadowsocks proxy helper functions
if [ -x ~/bin/lib/shadowsocks_helper.sh ]; then
    eval "$(~/bin/lib/shadowsocks_helper.sh)"
fi

# zhihu boxen
#[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh

