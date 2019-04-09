# What is Tarantool

Tarantool is a Lua application server integrated with a database
management system. It has a "fiber" model which means that many
Tarantool applications can run simultaneously on a single thread,
while the Tarantool server itself can run multiple threads for
input-output and background maintenance. It incorporates the LuaJIT --
"Just In Time" -- Lua compiler, Lua libraries for most common
applications, and the Tarantool Database Server which is an
established NoSQL DBMS. Thus Tarantool serves all the purposes that
have made node.js and Twisted popular, plus it supports data
persistence.

The database API allows for permanently storing Lua objects, managing
object collections, creating or dropping secondary keys, making
changes atomically, configuring and monitoring replication, performing
controlled fail-over, and executing Lua code triggered by database
events. Remote database instances are accessible transparently via a
remote-procedure-invocation API.

For more information, visit [tarantool.io](https://tarantool.io).

# Quickstart

If you just want to quickly try out tarantool, run this command:

```console
$ docker run --rm -t -i tarantool/tarantool
```

This will create a one-off Tarantool instance and open an interactive
console. From there you can either type `tutorial()` or follow
[official documentation](https://tarantool.io/en/doc/1.10/).


# About this image

This image is a bundle containing Tarantool itself, and a combination
of lua modules and utilities often used in production. It is designed
to be a building block for modern services, and as such has made a few
design choices that set it apart from the systemd-controlled Tarantool.

First, if you take this image and pin a version, you may rely on the
fact that you won't get updates with incompatible modules. We only do
major module updates while changing the image version.

Entry-point script provided by this image uses environment variables
to configure various "external" aspects of configuration, such as
replication sources, memory limits, etc... If specified, they override
settings provided in your code. This way you can use docker-compose or
other orchestration and deployment tools to set those options.

There are a few convenience tools that make use of the fact that there
is only one Tarantool instance running in the container.


# What's on board

- [avro-schema](https://github.com/tarantool/avro-schema): Apache Avro scheme for your data
- [expirationd](https://github.com/tarantool/expirationd): Automatically delete tuples based on expiration time
- [queue](https://github.com/tarantool/queue): Priority queues with TTL and confirmations
- [connpool](https://github.com/tarantool/connpool): Keep a pool of connections to other Tarantool instances
- [shard](https://github.com/tarantool/shard): Automatically distribute data across multiple instances
- [http](https://github.com/tarantool/http): Embedded HTTP server with flask-style routing support
- [curl](https://github.com/tarantool/curl): HTTP client based on libcurl
- [pg](https://github.com/tarantool/pg): Query PostgreSQL right from Tarantool
- [mysql](https://github.com/tarantool/mysql): Query MySql right from Tarantool
- [memcached](https://github.com/tarantool/memcached): Access Tarantool as if it was a Memcached instance
- [prometheus](https://github.com/tarantool/prometheus): Instrument code and export metrics to Prometheus monitoring
- [mqtt](https://github.com/tarantool/mqtt): Client for MQTT message brokers
- [gis](https://github.com/tarantool/gis): store and query geospatial data
- [gperftools](https://github.com/tarantool/gperftools): collect CPU profile to find bottlenecks in your code

If the module you need is not listed here, there is a good chance we may add it. Open an issue [on our GitHub](https://github.com/tarantool/docker).

# Data directories

- `/var/lib/tarantool` is a volume containing operational data
  (snapshots, xlogs and vinyl runs)

- `/opt/tarantool` is a place where users should put their lua
  application code

# Convenience utilities

- `console`: execute it without any arguments to open administrative
  console to a running Tarantool instance

- `tarantool_is_up`: returns 0 if Tarantool has been initialized and
  is operating normally

- `tarantool_set_config.lua`: allows you to dynamically change certain
  settings without the need to recreate containers.

# How to use this image

## Start a Tarantool instance

```console
$ docker run --name mytarantool -p3301:3301 -d tarantool/tarantool
```

This will start an instance of Tarantool and expose it on
port 3301. Note, that by default there is no password protection,
so don't expose this instance to the outside world.

In this case, when there is no lua code provided, the entry point
script initializes database using a sane set of defaults. Some of them
can be tuned with environment variables (see below).

## Start a secure Tarantool instance

```console
$ docker run --name mytarantool -p3301:3301 -e TARANTOOL_USER_NAME=myusername -e TARANTOOL_USER_PASSWORD=mysecretpassword -d tarantool/tarantool
```

This starts an instance of Tarantool, disables guest login and
creates user named `myusername` with admin privileges and password
`mysecretpassword`.

As with the previous example, database is initialized automatically.

## Connect to a running Tarantool instance

```console
$ docker exec -t -i mytarantool console
```

This will open an interactive admin console on the running instance
named `mytarantool`. You may safely detach from it anytime, the server
will continue running.

This `console` doesn't require authentication, because it uses a local
unix socket in the container to connect to Tarantool. But it requires
you to have direct access to the container.

If you need a remote console via TCP/IP, use `tarantoolctl` utility
as explained [here](https://tarantool.org/doc/book/administration.html#administration-tarantoolctl-connect).

## Start a master-master replica set

You may start a replica set with docker alone, but it's more
convenient to use [docker-compose](https://docs.docker.com/compose/).
Here's a simplified `docker-compose.yml` for starting a master-master
replica set:

``` yaml
version: '2'

services:
  tarantool1:
    image: tarantool/tarantool:1.10.2
    environment:
      TARANTOOL_REPLICATION: "tarantool1,tarantool2"
    networks:
      - mynet
    ports:
      - "3301:3301"

  tarantool2:
    image: tarantool/tarantool:1.10.2
    environment:
      TARANTOOL_REPLICATION: "tarantool1,tarantool2"
    networks:
      - mynet
    ports:
      - "3302:3301"

networks:
  mynet:
    driver: bridge
```

Start it like this:

``` console
$ docker-compose up
```

## Adding application code with a volume mount

The simplest way to provide application code is to mount your code
directory to `/opt/tarantool`:

```console
$ docker run --name mytarantool -p3301:3301 -d -v /path/to/my/app:/opt/tarantool tarantool/tarantool tarantool /opt/tarantool/app.lua
```

Where `/path/to/my/app` is a host directory containing lua code. Note
that for your code to be actually run, you must execute the main script
explicitly. Hence `tarantool /opt/tarantool/app.lua`, assuming that your
app entry point is called `app.lua`.


## Adding application code using container inheritance

If you want to pack and distribute an image with your code, you may
create your own Dockerfile as follows:

```bash
FROM tarantool/tarantool:1.10.2
COPY app.lua /opt/tarantool
CMD ["tarantool", "/opt/tarantool/app.lua"]
```

Please pay attention to the format of `CMD`: unless it is specified in
square brackets, the "wrapper" entry point that our Docker image
provides will not be called. It will lead to inability to configure
your instance using environment variables.

## Environment Variables

When you run this image, you can adjust some of Tarantool settings.
Most of them either control memory/disk limits or specify external
connectivity parameters.

If you need to fine-tune specific settings not described here, you can
always inherit this container and call `box.cfg{}` yourself.
See
[official documentation on box.cfg](https://tarantool.org/doc/reference/configuration/index.html#box-cfg-params) for
details.

### `TARANTOOL_USER_NAME`

Setting this variable allows you to pick the name of the user that is
utilized for remote connections. By default, it is 'guest'. Please
note that since guest user in Tarantool can't have a password, it is
highly recommended that you change it.

### `TARANTOOL_USER_PASSWORD`

For security reasons, it is recommended that you never leave this
variable unset. This environment variable sets the user's password for
Tarantool. In the above example, it is set to "mysecretpassword".

### `TARANTOOL_PORT`

Optional. Specifying this variable will tell Tarantool to listen for
incoming connections on a specific port. Default is 3301.

### `TARANTOOL_REPLICATION`

Optional. Comma-separated list of URIs to treat as replication
sources. Upon the start, Tarantool will attempt to connect to
those instances, fetch the data snapshot and start replicating
transaction logs. In other words, it will become a slave. For the
multi-master configuration, other participating instances of
Tarantool should be started with the same TARANTOOL_REPLICATION.
(NB: applicable only to >=1.7)

Example:

`user1:pass@host1:3301,user2:pass@host2:3301`

### `TARANTOOL_MEMTX_MEMORY`

Optional. Specifies how much memory Tarantool allocates to
actually store tuples, in bytes. When the limit is reached, INSERT
or UPDATE requests begin failing. Default is 268435456 (256
megabytes).

### `TARANTOOL_SLAB_ALLOC_FACTOR`

Optional. Used as the multiplier for computing the sizes of memory
chunks that tuples are stored in. A lower value may result in less
wasted memory depending on the total amount of memory available
and the distribution of item sizes. Default is 1.05.

### `TARANTOOL_MEMTX_MAX_TUPLE_SIZE`

Optional. Size of the largest allocation unit in bytes. It can be
increased if it is necessary to store large tuples. Default is
1048576.

### `TARANTOOL_MEMTX_MIN_TUPLE_SIZE`

Optional. Size of the smallest allocation unit, in bytes. It can be
decreased if most of the tuples are very small. Default is 16.

### `TARANTOOL_CHECKPOINT_INTERVAL`

Optional. Specifies how often snapshots will be made, in seconds.
Default is 3600 (every 1 hour).

# Reporting problems and getting help

You can report problems and request
features [on our GitHub](https://github.com/tarantool/docker).

Alternatively you may get help on our [Telegram channel](https://t.me/tarantool).

# Contributing

## How to contribute

Open a pull request to the master branch. A maintaner is responsible for
updating all relevant branches when merging the PR.

## How to check

Say, we have updated 1.x/Dockerfile and want to check it:

```sh
$ docker build 1.x/ -t t1.x
$ docker run -it t1.x
...perform a test...
```

## Build pipelines

Fixed versions:

| Branch | Dockerfile     | Docker tag |
| ------ | ----------     | ---------- |
| 1.7.3  | 1.7/Dockerfile | 1.7.3      |
| 1.7.4  | 1.7/Dockerfile | 1.7.4      |
| 1.7.5  | 1.7/Dockerfile | 1.7.5      |
| 1.7.6  | 1.7/Dockerfile | 1.7.6      |
| 1.8.1  | 1.8/Dockerfile | 1.8.1      |
| 1.9.1  | 1.x/Dockerfile | 1.9.1      |
| 1.9.2  | 1.x/Dockerfile | 1.9.2      |
| 1.10.0 | 1.x/Dockerfile | 1.10.0     |
| 1.10.2 | 1.x/Dockerfile | 1.10.2     |
| 1.10.3 | 1.x/Dockerfile | 1.10.3     |
| 2.1.1  | 2.x/Dockerfile | 2.1.1      |
| 2.1.2  | 2.x/Dockerfile | 2.1.2      |
| 2.2.0  | 2.x/Dockerfile | 2.2.0      |

Rolling versions:

| Branch | Dockerfile     | Docker tag |
| ------ | ----------     | ---------- |
| master | 1.5/Dockerfile | 1.5        |
| master | 1.6/Dockerfile | 1.6        |
| master | 1.7/Dockerfile | 1.7        |
| master | 1.9/Dockerfile | 1.9        |
| master | 1.x/Dockerfile | 1          |
| master | 1.x/Dockerfile | latest     |
| master | 2.1/Dockerfile | 2.1        |
| master | 2.x/Dockerfile | 2          |

Special builds:

| Branch | Dockerfile             | Docker tag  |
| ------ | ----------             | ----------  |
| master | 1.x-centos7/Dockerfile | 1.x-centos7 |
| master | 2.x-centos7/Dockerfile | 2.x-centos7 |

## How to push changes (for maintainers)

When the change is about specific tarantool version or versions range, update
all relevant fixed versions & rolling versions in all relevant branches
according to the pipelines listed above.

When the change is about the environment at all, all versions need to be
updated in all relevent branches.

Add a new release (say, `x.y.z`). Create / update rolling versions `x` and
`x.y` in master, create fixed version `x.y.z` on the corresponding branch, add
corresponding build pipeline on Docker Hub. ([Related][1].)

A maintainer is responsible to check updated images.

[1]: https://tarantool.io/en/doc/1.9/dev_guide/release_management/#how-to-make-a-minor-release
