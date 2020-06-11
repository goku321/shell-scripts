#!/bin/bash
# Validates user input to allow only Alphanumberic characters.

validAlphaNum() {
    # Remove all unacceptable chars.
    validchars="$(echo $1 | sed -e 's/[^[:alnum:]]//g')"

    if [ "$validchars" = "$1" ]; then
        return 0
    else
        return 1
    fi
}