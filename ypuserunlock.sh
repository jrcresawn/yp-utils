#!/bin/bash

function help {
    echo 'Usage: ypuserunlock -u user'
    echo 'Unlock a user account.'
    echo ''
    echo 'This argument is mandatory.'
    echo '  -u user'
    echo ''
}

if [ -z $1 ]; then
    help
    exit 1
fi

while getopts "u:" opt; do
  case $opt in
	  u)
      user=$OPTARG
      ;;
    *)
      help
      exit 1
      ;;
  esac
done

if egrep ^$user:\\*\\** /var/yp/src/shadow 2>&1 >/dev/null; then
  sed -i s/^$user:\\*\\**/$user:/ /var/yp/src/shadow
  ( cd /var/yp; make)
else
  echo "Nothing to do."
fi