
# MacPorts Installer addition on 2011-07-30_at_09:03:17: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

if [ "${BASH-no}" != "no" ]; then
	[ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi


