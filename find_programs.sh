#!/bin/bash

in_path() {
    cmd=$1
    path=$2
    res=1
    oldIFS=$IFS
    IFS=":"

for dir in "$path"
do
    if [ -x $dir/$cmd ]; then
        res=0
    fi
done

IFS=$oldIFS
return $result
}

checkForCmdInPath() {
    var=$1

    if [ "$var" != "" ]; then
        # using variable slicing to isolate the first character.
        if [ "${var:0:1}" = "/" ]; then
            if [ ! -x $var ]; then
                return 1
            fi
        elif ! in_path $var "$PATH"; then
            return 2
        fi
    fi
}

# main
if [ $# -ne 1 ]; then
    echo "Usage: $0 command" >&2
    exit 1
fi

checkForCmdInPath "$1"
case $? in
    0 ) echo "$1 found in PATH" ;;
    1 ) echo "$1 not found or not executable" ;;
    2 ) echo "$1 not found in PATH" ;;
esac

exit 0