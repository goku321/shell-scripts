#!/bin/bash

in_path() {
    cmd=$1
    path=$2
    res=1
    oldIFS=$IFS
    IFS=":"

for dir in "$path"
do
    if [ -x $directory/$cmd ]; then
        res=0
    fi
done

IFS=$oldIFS
return $result
}

checkForCmdInPath() {
    var=$1

    if [ "$var" != "" ]; then
        if [ "${var:0:1}" = "/" ]; then
            if [ ! -x $var ]; then
                return 1
            fi
        elif ! in_path $var "$PATH"; then
            return 2
        fi
    fi
}
