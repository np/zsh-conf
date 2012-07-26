PATH=/bin:/usr/bin
new_path=
extpath(){
  if [ -z "$new_path" ]; then
    new_path="$1"
  else
    new_path="$new_path:$1"
  fi
}
for p in \
  $HOME/bin \
  $HOME/tools \
  $HOME/tools/vendor/bin \
  $HOME/private/bin \
  $HOME/.cabal/bin \
  $HOME/.gem/ruby/1.9.1/bin \
  $HOME/.gem/ruby/1.8/bin \
  /opt/ruby1.8/bin \
  /usr/local/bin \
  /usr/local/sbin \
  /usr/lib/git-core
do
  if [ -d "$p" ]; then
    extpath "$p"
  fi
done
extpath "/sbin:/bin:/usr/bin:/usr/sbin"
export PATH="$new_path"
