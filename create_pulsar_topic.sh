#!/bin/bash

BINARY="pulsar-admin"
ADMIN_URL="http://10.0.2.100:8080"

validate_binary_path() {
    if [ -x $1/$BINARY ]; then
        return 0
    fi
    return 1
}

create_tenant() {
    echo "creating tenant..."

    # check if the tenant already exists.
    $1 --admin-url $ADMIN_URL tenants list | grep ^\"$2\"$
    if [ $? -eq 0 ]; then
        return 0
    fi
    
    $1 --admin-url $ADMIN_URL tenants create $2
    return $?
}

create_namespace() {
    echo "creating namespace..."

    # check if the namespace already exists.
    $1 --admin-url $ADMIN_URL namespaces list $2 | grep ^\"$2/$3\"$
    if [ $? -eq 0 ]; then
        return 0
    fi

    $1 --admin-url $ADMIN_URL namespaces create $2/$3
    return $?
}

create_partitioned_topic() {
    $1 --admin-url $ADMIN_URL topics create-partitioned-topic \
        persistent://$2/$3/$4 --partitions $5
}

create_non_partitioned_topic() {
    $1 --admin-url $ADMIN_URL topics create \
        persistent://$2/$3/$4
}

create_topic() {
    echo "creating topic..."
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

update_broker_configuration() {
    $1 --admin-url $ADMIN_URL brokers update-dynamic-config \
        --config $2 \
        --value $3
    
    return $?
}

set_retention_limit() {
    if [ $# -lt 5 ]; then
        usage "not enough arguments"
        return 1
    fi

    $1 --admin-url $ADMIN_URL namespaces set-retention \
        $2/$3 --size $4 --time $5
    
    return $?
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

# update_broker_configuration $cmd "brokerDeleteInactiveTopicsEnabled" "false"
# if [ ! $? -eq 0 ]; then
#     echo "error: failed to update broker configuration"
#     exit 1
# fi

create_tenant "$cmd" "$2"
if [ ! $? -eq 0 ]; then
    echo "error: failed to create tenant - $2"
    exit 1
fi

create_namespace "$cmd" "$2" "$3"
if [ ! $? -eq 0 ]; then
    echo "error: failed to create namespace - $2/$3"
    exit 1
fi

set_retention_limit "$cmd" "$2" "$3" -1 -1
if [ ! $? -eq 0 ]; then
    echo "error: failed to set retention limits on - $2/$3"
    exit 1
fi

create_topic "$cmd" ${@:2}
if [ ! $? -eq 0 ]; then
    echo "error: failed to create topic - $2/$3/$4"
    exit 1
fi

echo "topic created successfully!"