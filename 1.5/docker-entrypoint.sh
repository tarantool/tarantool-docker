#!/bin/sh

update_cfg()
{
    variable=$1
    varname=$2
    value=$(printenv $varname)
    CFG=/etc/tarantool/tarantool.cfg

    if printenv $varname > /dev/null
    then
        if grep "$variable=" $CFG
        then
            sed -i "s/$variable=.*/$variable=$value/g" $CFG
        else
            echo "$variable=$value" >> $CFG
        fi
    fi
}

try_init_db()
{
    if [ "$(find /var/lib/tarantool -maxdepth 1 -name '*.snap' -print)" = "" ]
    then
        echo "Initializing config:"

        CFG=/etc/tarantool/tarantool.cfg

        if [ ! -f $CFG ]
        then
            echo "work_dir=/opt/tarantool" > $CFG
            echo "memcached_port=11211" >> $CFG
            echo "primary_port=3301" >> $CFG
            echo "admin_port=3302" >> $CFG
            echo "replication_port=3310" >> $CFG
            echo "snap_dir=/var/lib/tarantool" >> $CFG
            echo "wal_dir=/var/lib/tarantool" >> $CFG
        fi

        update_cfg "replication_port" "TARANTOOL_REPLICATION_PORT"
        update_cfg "replication_source" "TARANTOOL_REPLICATION_SOURCE"
        update_cfg "slab_alloc_arena" "TARANTOOL_SLAB_ALLOC_ARENA"
        update_cfg "slab_alloc_factor" "TARANTOOL_SLAB_ALLOC_FACTOR"
        update_cfg "slab_alloc_minimal" "TARANTOOL_SLAB_ALLOC_MINIMAL"
        update_cfg "primary_port" "TARANTOOL_PORT"
        update_cfg "admin_port" "TARANTOOL_ADMIN_PORT"
        update_cfg "wal_mode" "TARANTOOL_WAL_MODE"
        update_cfg "snap_dir" "TARANTOOL_SNAP_DIR"
        update_cfg "wal_dir" "TARANTOOL_WAL_DIR"

        cat $CFG

        echo
        echo "Initializing database:"

        su-exec tarantool tarantool_box -c $CFG --init-storage

        echo
    fi
}

# entry point wraps the passed script to do basic setup
if [ "$1" = 'tarantool_box' ]; then
    shift
    try_init_db
    exec su-exec tarantool tarantool_box "$@"
fi

exec "$@"
