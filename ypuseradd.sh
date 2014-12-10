#!/bin/bash

function help {
    echo 'Usage: ypuseradd [OPTION] USER'
    echo ''
    echo 'Options:'
    echo '  -g                            gid, where gid > 999'
    echo '  -n                            full name of account owner'
    echo ''
    exit 1
}

while getopts "g:n:" opt; do
  case $opt in
    g)
      gid=$OPTARG
      ;;
    n)
      name=$OPTARG
      ;;
    *)
      help
      ;;
  esac
done

for arg in "$@"; do
  user=$arg   # overwrite $user to get last argument
done

# echo "user = $user"
if getent passwd $user 2>&1 >/dev/null; then
  echo "$0: user exists -- $user"
  exit 1
fi

if [ "$gid" -lt "1000" ]; then
  echo "$0: gid must be greater than 999 -- $gid"
  exit 1
fi

# return 1 if the uid is used, else return 0
function usedUid() {
  [ -z "$1" ] && return

  for i in ${uids[@]} ; do
    [ $i == $1 ] && return 1
  done
  return 0
}

uids=( $( getent passwd | cut -d: -f3 | sort -n ) )
uid=999   # end of system uids

# search for a free uid greater than 999 (default behaviour of adduser)
found=1

while [ $found -eq 1 ] ; do
  uid=$(( $uid + 1))
  usedUid $uid
  found=$?
done

# function addToGroup() {
#   [ -z "$1" ] && return 1

#   if getent group $1 2>&1 >/dev/null; then
#     # modify group entry with sed
#     if getent group $gid 2>&1 >/dev/null; then
#       # group exists; insert with sed
#       sed -e 's/^[a-zA-Z0-9]:'
#     else
#       # group does not exist; append to file with echo
      
#     return 0
#   else
#     # append to group
#     return 0
#   fi
# }

# echo echo "/var/yp/src/passwd: $user:x:$uid:$gid:$name:/home/$user:/bin/bash" > /var/yp/src/passwd
# echo echo "/var/yp/src/shadow: $user:*:::::::" > /var/yp/src/shadow
passwd=`pwgen -s 8 1`
crypt=`mkpasswd --method=sha-512 $passwd`
echo "/var/yp/src/passwd: $user:x:$uid:$gid:$name:/home/$user:/bin/bash"
echo "/var/yp/src/shadow: $user:$crypt:::::::"
echo "add $user to group $gid in /var/yp/src/group using addToGroup()"
echo '(cd /var/yp; make)'
echo "passwd = $passwd"
#echo "yppasswd $user"
echo "mkdir /home/$user"
echo "cp /etc/skel/.??* /home/$user"
echo "chown -R $uid:$gid /home/$user"
