#!/bin/bash

function help {
    echo 'Usage: ypdeluser [OPTION] USER'
    echo ''
    echo 'Options:'
    echo '  -a                            archive home directory'
    echo '  -r                            remove home directory'
    echo ''
    exit 1
}

while getopts "ar" opt; do
  case $opt in
    a)
      archive='y'
      ;;
    r)
      remove='y'
      ;;
    *)
      help
      ;;
  esac
done

for arg in "$@"; do
  user=$arg   # overwrite $user to get last argument
done

if egrep ^$user: /var/yp/src/passwd 2>&1 >/dev/null; then
  HOME=`ypmatch $user passwd | awk -F: '{ print $6 }'`
  
  [ -n "$archive" ] && tar czf $HOME.tar.gz $HOME
  [ -n "$remove" ] && rm -rf $HOME

  sed -i /^$user:/d /var/yp/src/passwd
  sed -i /^$user:/d /var/yp/src/shadow
  sed -i s/$user,\\?//g /var/yp/src/group
  sed -i s/$user,\\?//g /var/yp/src/aliases
  (cd /var/yp; make)
else
  echo "$0: invalid user -- $user"
  help
fi