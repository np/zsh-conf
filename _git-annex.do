curl -sL https://github.com/esc/git-annex-zsh-completion/raw/master/_git-annex |
  sed -e 's/#compdef git-annex/& gan/' >"$3" \
      -e 's/python/python2/'
redo-stamp <"$3"
