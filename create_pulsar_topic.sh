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
    echo $1 $2 $3 $4 $5
    $1 topics create-partitioned-topic \
    persistent://$2/$3/$4 --partitions $5 \
    --brokerDeleteInactiveTopicsEnabled false
}

create_non_partitioned_topic() {
    echo $1 $2 $3 $4
}

create_topic() {
    echo "creating topic"
    if [ $# -eq 5 ]; then
        if [[ $5 =~ ^[0-9]+$ ]]; then
            create_partitioned_topic "$@"
            return $?
        else
            usage "invalid argument - $5"
            return 2
        fi
    else
        create_non_partitioned_topic "$@"
        return $?
    fi

}

usage() {
    echo "error: $1"
    echo "Usage: $0 binary-path tenant namespace topic [number-of-partitions]" >&2
    echo "Optons: \

            binary-path           - path to pulsar directory that contains the binaries.
            tenant                - valid tenant name.
            namespace             - valid namespace name.
            topic                 - valid topic name.
            number-of-partitions  - number of partitions (integer)
        "
}

# main
if [ $# -lt 4 ]; then
    usage "not enough arguments"
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

# create_tenant "$cmd" "$2"
# if [ ! $? -eq 0 ]; then
#     echo "error: failed to create tenant"
#     exit 1
# fi

# create_namespace "$cmd" "$2" "$3"
# if [ ! $? -eq 0 ]; then
#     echo "error: failed to create namespace"
#     exit 1
# fi

create_topic "$cmd" ${@:2}
if [ ! $? -eq 0 ]; then
    echo "error: failed to create topic"
    exit 1
fi