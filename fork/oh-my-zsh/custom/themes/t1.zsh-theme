## based on robbyrussell theme
## colors: Red, Blue, Green, Cyan, Yellow, Magenta, Black & White

## return status of last command
PROMPT_RET_STATUS="%(?:%{$fg_bold[green]%}➜:%{$fg_bold[red]%}%?
➜)"

## show user@hostname if connected with ssh
if [ $SSH_CONNECTION ]; then
  local PROMPT_SSH_USER="%{$fg[white]%}%n@%m "
fi

## show git info if in a git repo
_prompt_git_repo() {
  local ref repo
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  repo="$(command git rev-parse --show-toplevel)"
  echo "%{$fg_bold[blue]%}$(basename $repo)"
}
_prompt_git_status() {
  local ref git_branch
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  git_branch="%{$fg[red]%}${ref#refs/heads/}"
  echo " %{$fg_bold[blue]%}±($git_branch$(_prompt_git_work_status)%{$fg_bold[blue]%}) $(parse_git_dirty)"
}
_prompt_git_work_status() {
  local remote
  typeset -i ahead=0 behind=0 uncommitted=0 untracked=0
  remote=${$(command git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
  if [[ -n ${remote} ]]; then
    ahead=${#$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null)}
    behind=${#$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null)}
  fi
  uncommitted=$(command git status --porcelain | wc -l)
  if [ $uncommitted -gt 0 ]; then
    untracked=$(command git status --porcelain | egrep -c '^\?')
    (( uncommitted = uncommitted - untracked))
  fi
  if [ $behind -gt 0 ] || [ $ahead -gt 0 ] || [ $uncommitted -gt 0 ] || [ $untracked -gt 0 ]; then
    echo -n " "
    [ $behind -gt 0 ] && echo -n "%{$fg[yellow]%}↓$behind"
    [ $ahead -gt 0 ] && echo -n "%{$fg[green]%}↑$ahead"
    [ $uncommitted -gt 0 ] && echo -n "%{$fg[red]%}⁕$uncommitted"
    [ $untracked -gt 0 ] && echo -n "%{$fg[magenta]%}+$untracked"
  fi
}

# PROMPT
PROMPT='${PROMPT_RET_STATUS} ${PROMPT_SSH_USER}%{$fg[cyan]%}%c$(_prompt_git_status) %{$reset_color%}'
RPROMPT='$(_prompt_git_repo) %{$fg[white]%}%! %{$fg[cyan]%}%T%{$reset_color%}'

## theme strings
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[yellow]%}✗ "
ZSH_THEME_GIT_PROMPT_CLEAN=""
