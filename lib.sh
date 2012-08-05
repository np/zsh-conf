#!/bin/bash
# This file is required to work both with bash and zsh.

SHORT_HOSTNAME=$(hostname | cut -d. -f1)

# when_on host1 ... -- cmd arg1 ...
when_on() {
  while [ $# -gt 0 ]; do
    case "$1" in
      "$SHORT_HOSTNAME")
        until [ "$#" = 0 ] || [ "$1" = "--" ]; do shift; done
        if [ "$#" = 0 ]; then
          echo "Usage: when_on host1 ... -- cmd arg1 ..." >>/dev/stderr
          echo "expected --" >>/dev/stderr
          break
        fi
        shift
        "$@"
        break;;
      '--') shift; break;;
      *) shift
    esac
  done
}

titled() {
  figlet "$1"
  shift
  "$@"
}
