#!/bin/bash

BINARY="pulsar-admin"

validate_binary_path() {
    if [ -x $1/$BINARY ]; then
        return 0
    fi
    return 1
}

create_tenant() {
    echo "creating tenant..."
    $1 tenants create $2
    return $?
}

create_namespace() {
    echo "creating namespace..."
    $1 namespaces create $2/$3
}

create_partitioned_topic() {
    echo "create topic"
}

create_topic() {
    echo "creating topic"
}

usage() {
    echo "error: not enough arguments"
    echo "Usage: $0 binary-path tenant namespace topic [number-of-partitions]" >&2
}

# main
if [ $# -lt 4 ]; then
    usage
    exit 1
fi

# check whether the binary exists or not in the given path
validate_binary_path "$1"
if [ $? -eq 1 ]; then
    echo "error: binary does not exists"
    exit 1
fi

# pulsar-admin command
cmd="$1/$BINARY"

create_tenant "$cmd" "$2"
if [ ! $? -eq 0 ]; then
    echo "error: failed to create tenant"
    exit 1
fi

create_namespace "$2" "$3"
if [ ! $? -eq 0 ]; then
    echo "error: failed to create namespace"
    exit 1
fi

create_topic "$2" "$3" "$4" "$5"
if [ ! $? -eq 0 ]; then
    echo "error: failed to create topic"
    exit 1
fi