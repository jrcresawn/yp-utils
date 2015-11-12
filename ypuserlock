#!/bin/bash

function help {
    echo 'Usage: ypuserlock -u user'
    echo 'Lock a user account.'
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

if [ ${#user} -gt 0 ]; then
  sed -i s/^$user:\\*\\**/$user:/ /var/yp/src/shadow
  sed -i s/^$user:/$user:*/ /var/yp/src/shadow
  ( cd /var/yp; make)
else
  help
  exit 1
fi