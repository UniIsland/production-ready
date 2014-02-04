[ -z $BASH_VERSION ] && return

_workon() {
	local cur
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD -eq 1 ] ; then
		COMPREPLY=( $( compgen -W "$( command cat /Users/tao/.virtualenvs/.envs.list | \
			awk '{print $1}' )" -- $cur ) )
	fi
}

workon() {
	test -z $1 && return 2
	local dir env
	dir=$( egrep "^$1 " /Users/tao/.virtualenvs/.envs.list | awk '{print $2}' )
	env=$( egrep "^$1 " /Users/tao/.virtualenvs/.envs.list | awk '{print $3}' )
    test -r "$env/bin/activate" || return 2
    test -d "$dir" || return 2
	source "$env/bin/activate"
	cd $dir
}

## ve() is an alias to workon()
ve() {
	workon $*
}

complete -F _workon workon
complete -F _workon ve

