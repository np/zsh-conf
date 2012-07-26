# Based on http://aperiodic.net/phil/prompt/

ZSH_LIGHT_REPO_PROMPT=1

function precmd {

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))

    local pr_dtach
    if [ -z "$DTACH_NAME" ]; then
      pr_dtach=''
    else
      pr_dtach="/$DTACH_NAME"
    fi

    ###
    # Truncate the path if it's too long.

    PR_FILLBAR=""
    PR_PWDLEN=""

    local promptsize=${#${(%):---(%n@%m$pr_dtach)---()--}}
    local pwdsize=${#${(%):-%~}}

    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
      ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
      PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize - 2)))..${PR_HBAR}.)}"
    fi
}

if which git-prompt >/dev/null 2>/dev/null; then
  # adapted from oh-my-zsh
  function repo_info() {
    [ -e .nice ] && echo 'ø' && return
    git branch >/dev/null 2>/dev/null && git-prompt --zsh-no-length && return
    hg root >/dev/null 2>/dev/null && hg_prompt_info && return
    darcs show repo >/dev/null 2>/dev/null && darcs_prompt_info && return
    echo '○'
  }
else
  cat >>/dev/stderr <<EOF
You don't have git-prompt installed (packaged in nptools on hackage.haskell.org).
Defaulting to a simpler prompt.
EOF
  # adapted from oh-my-zsh
  function repo_info() {
    [ -e .nice ] && echo 'ø' && return
    git branch >/dev/null 2>/dev/null && echo "±$PR_BLUE:${PR_LIGHT_RED}missing git-prompt" && return
    hg root >/dev/null 2>/dev/null && hg_prompt_info && return
    darcs show repo >/dev/null 2>/dev/null && darcs_prompt_info && return
    echo '○'
  }
fi


if [[ "$ZSH_LIGHT_REPO_PROMPT" == 1 ]]; then
  function darcs_prompt_info() {
    echo "↔"
  }

  function hg_prompt_info() {
    echo "☿"
  }

else
  function darcs_prompt_info() {
    echo "↔$PR_BLUE:$PR_GREEN$(darcs whatsnew -ls | grep '^[a-zA-Z]' | sed -e 's/^\(.\).*$/\1/' -e 's/a/?/' | sort -u | concat)"
  }

  function hg_prompt_info() {
    echo "☿$PR_BLUE:$PR_MAGENTA$(hg branch)$PR_GREEN$(hg status | sed -e 's/^\(.\).*$/\1/' | sort -u | concat)"
  }
fi

setopt extended_glob
preexec () {
    if [[ "$TERM" == "screen" ]]; then
      local CMD=${1[(wr)^(*=*|sudo|-*)]}
      echo -n "\ek$CMD\e\\"
    fi
}


setprompt () {
    ###
    # Need this so the prompt will work.

    setopt prompt_subst


    ###
    # See if we can use colors.

    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
      colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
      eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
      eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
      (( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"

    ZSH_THEME_GIT_PROMPT_DIRTY="$PR_GREEN!"
    ZSH_THEME_GIT_PROMPT_UNTRACKED="$PR_GREEN?"
    ZSH_THEME_GIT_PROMPT_CLEAN=""

    ###
    # See if we can use extended characters to look nicer.

    if (( NCURSES_NO_UTF8_ACS )); then # suppose its mosh
      :
    else
      typeset -A altchar
      set -A altchar ${(s..)terminfo[acsc]}
    fi
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    #FALLBACKDASH=-
    FALLBACKDASH=—
    PR_HBAR=${altchar[q]:-$FALLBACKDASH}


    ###
    # Decide if we need to set titlebar text.

    case $TERM in
    xterm*|rxvt*)
      PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~\a%}'
      ;;
    *)
      PR_TITLEBAR=''
      ;;
    esac

    if [ -z "$DTACH_NAME" ]; then
      PR_DTACH=''
    else
      PR_DTACH="$PR_BLUE/$PR_YELLOW$DTACH_NAME"
    fi

    ###
    # Finally, the prompt.

    PROMPT='$PR_SET_CHARSET${(e)PR_TITLEBAR}\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%$PR_PWDLEN<...<%~%<<\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR${(e)PR_FILLBAR}$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_CYAN%(!.%SROOT%s.%n)$PR_BLUE@$PR_YELLOW%m$PR_DTACH$PR_BLUE)\

%(?..$PR_LIGHT_RED%?$PR_BLUE:)\
$PR_NO_COLOUR$(repo_info)$PR_BLUE ⊢$PR_NO_COLOUR '

    RPROMPT=''

    PS2='$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_LIGHT_GREEN%_$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
}

setprompt

