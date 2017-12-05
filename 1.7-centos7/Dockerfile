FROM centos:7
MAINTAINER mail@racktear.com

RUN groupadd tarantool \
    && adduser -g tarantool tarantool

ENV TARANTOOL_VERSION=1.7.6-0-g7b2945d6c \
    TARANTOOL_DOWNLOAD_URL=https://github.com/tarantool/tarantool.git \
    TARANTOOL_INSTALL_LUADIR=/usr/local/share/tarantool \
    LUAROCKS_URL=http://keplerproject.github.io/luarocks/releases/luarocks-2.3.0.tar.gz \
    LUAROCK_AVRO_SCHEMA_REPO=https://github.com/tarantool/avro-schema.git \
    LUAROCK_AVRO_SCHEMA_TAG=b49efa8 \
    LUAROCK_EXPIRATIOND_REPO=https://github.com/tarantool/expirationd.git \
    LUAROCK_EXPIRATIOND_TAG=9ec22b6 \
    LUAROCK_QUEUE_REPO=https://github.com/tarantool/queue.git \
    LUAROCK_QUEUE_TAG=24d730c \
    LUAROCK_CONNPOOL_REPO=https://github.com/tarantool/connpool.git \
    LUAROCK_CONNPOOL_TAG=89c2fe4 \
    LUAROCK_SHARD_REPO=https://github.com/tarantool/shard.git \
    LUAROCK_SHARD_TAG=8f8c5a7 \
    LUAROCK_HTTP_REPO=https://github.com/tarantool/http.git \
    LUAROCK_HTTP_TAG=67d8a9b \
    LUAROCK_PG_REPO=https://github.com/tarantool/pg.git \
    LUAROCK_PG_TAG=8bb4164 \
    LUAROCK_MYSQL_REPO=https://github.com/tarantool/mysql.git \
    LUAROCK_MYSQL_TAG=3203633 \
    LUAROCK_MEMCACHED_REPO=https://github.com/tarantool/memcached.git \
    LUAROCK_MEMCACHED_TAG=7aa78b2 \
    LUAROCK_TARANTOOL_PROMETHEUS_REPO=https://github.com/tarantool/prometheus.git \
    LUAROCK_TARANTOOL_PROMETHEUS_TAG=0654304 \
    LUAROCK_TARANTOOL_CURL_REPO=https://github.com/tarantool/curl.git \
    LUAROCK_TARANTOOL_CURL_TAG=2.2.7 \
    LUAROCK_MQTT_REPO=https://github.com/tarantool/mqtt.git \
    LUAROCK_MQTT_TAG=238fd2e \
    LUAROCK_TARANTOOL_GIS_REPO=https://github.com/tarantool/gis.git \
    LUAROCK_TARANTOOL_GIS_TAG=25209fc \
    LUAROCK_GPERFTOOLS_REPO=https://github.com/tarantool/gperftools.git \
    LUAROCK_GPERFTOOLS_TAG=12a7ac2

RUN yum -y install epel-release && \
    yum -y update && \
    yum -y clean all

RUN set -x \
    && yum -y install \
        libstdc++ \
        readline \
        openssl \
        yaml \
        lz4 \
        binutils \
        ncurses \
        libgomp \
        lua \
        curl \
        tar \
        zip \
        libunwind \
        libcurl \
        libicu \
    && yum -y install \
        perl \
        gcc-c++ \
        cmake \
        readline-devel \
        openssl-devel \
        libyaml-devel \
        lz4-devel \
        binutils-devel \
        ncurses-devel \
        lua-devel \
        make \
        git \
        libunwind-devel \
        autoconf \
        automake \
        libtool \
        go \
        wget \
        curl-devel \
        libicu-devel \
    && : "---------- gperftools ----------" \
    && yum install -y gperftools-libs \
    && (GOPATH=/usr/src/go go get github.com/google/pprof; \
        cp /usr/src/go/bin/pprof /usr/local/bin) \
    && : "---------- tarantool ----------" \
    && mkdir -p /usr/src/tarantool \
    && git clone "$TARANTOOL_DOWNLOAD_URL" /usr/src/tarantool \
    && (cd /usr/src/tarantool; git checkout "$TARANTOOL_VERSION";) \
    && (cd /usr/src/tarantool; git submodule update --init --recursive;) \
    && (cd /usr/src/tarantool; \
       cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo\
             -DENABLE_BUNDLED_LIBYAML:BOOL=OFF\
             -DENABLE_BACKTRACE:BOOL=ON\
             -DENABLE_DIST:BOOL=ON\
             .) \
    && make -C /usr/src/tarantool -j\
    && make -C /usr/src/tarantool install \
    && make -C /usr/src/tarantool clean \
    && : "---------- small ----------" \
    && (cd /usr/src/tarantool/src/lib/small; \
        cmake -DCMAKE_INSTALL_PREFIX=/usr \
              -DCMAKE_INSTALL_LIBDIR=lib \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              .) \
    && make -C /usr/src/tarantool/src/lib/small \
    && make -C /usr/src/tarantool/src/lib/small install \
    && make -C /usr/src/tarantool/src/lib/small clean \
    && : "---------- msgpuck ----------" \
    && (cd /usr/src/tarantool/src/lib/msgpuck; \
        cmake -DCMAKE_INSTALL_PREFIX=/usr \
              -DCMAKE_INSTALL_LIBDIR=lib \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              .) \
    && make -C /usr/src/tarantool/src/lib/msgpuck \
    && make -C /usr/src/tarantool/src/lib/msgpuck install \
    && make -C /usr/src/tarantool/src/lib/msgpuck clean \
    && : "---------- luarocks ----------" \
    && wget -O luarocks.tar.gz "$LUAROCKS_URL" \
    && mkdir -p /usr/src/luarocks \
    && tar -xzf luarocks.tar.gz -C /usr/src/luarocks --strip-components=1 \
    && (cd /usr/src/luarocks; \
        ./configure; \
        make build; \
        make install) \
    && rm -r /usr/src/luarocks \
    && rm -rf /usr/src/tarantool \
    && rm -rf /usr/src/go \
    && : "---------- remove build deps ----------" \
    && yum -y remove \
        perl \
        gcc-c++ \
        cmake \
        readline-devel \
        openssl-devel \
        libyaml-devel \
        lz4-devel \
        binutils-devel \
        ncurses-devel \
        lua-devel \
        make \
        git \
        libunwind-devel \
        autoconf \
        automake \
        libtool \
        go \
        wget \
        perl \
        kernel-headers \
        golang-src \
        curl-devel \
        libicu-devel \
    && rpm -qa | grep devel | xargs yum -y remove \
    && rm -rf /var/cache/yum


COPY luarocks-config.lua /usr/local/etc/luarocks/config-5.1.lua
COPY mosquitto.repo /etc/yum.repos.d/

RUN set -x \
    && yum -y install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm \
    && yum -y install \
        mariadb-libs \
        postgresql96-libs \
        cyrus-sasl \
        libcurl \
        libmosquitto1 \
        libev \
        proj \
        geos \
        unzip \
    && yum -y install \
        git \
        cmake \
        make \
        gcc-c++ \
        postgresql96-devel \
        lua-devel \
        cyrus-sasl-devel \
        curl-devel \
        libmosquitto-devel \
        libev-devel \
        wget \
        proj-devel \
        geos-devel \
        openssl-devel \
    && mkdir -p /rocks \
    && : "---------- luarocks ----------" \
    && luarocks install lua-term \
    && luarocks install ldoc \
    && : "avro" \
    && git clone $LUAROCK_AVRO_SCHEMA_REPO /rocks/avro \
    && (cd /rocks/avro; git checkout $LUAROCK_AVRO_SCHEMA_TAG) \
    && (cd /rocks/avro && luarocks make *rockspec) \
    && : "expirationd" \
    && git clone $LUAROCK_EXPIRATIOND_REPO /rocks/expirationd \
    && (cd /rocks/expirationd; git checkout $LUAROCK_EXPIRATIOND_TAG) \
    && (cd /rocks/expirationd && luarocks make *rockspec) \
    && : "queue" \
    && git clone $LUAROCK_QUEUE_REPO /rocks/queue \
    && (cd /rocks/queue; git checkout $LUAROCK_QUEUE_TAG) \
    && (cd /rocks/queue && luarocks make *rockspec) \
    && : "connpool" \
    && git clone $LUAROCK_CONNPOOL_REPO /rocks/connpool \
    && (cd /rocks/connpool; git checkout $LUAROCK_CONNPOOL_TAG) \
    && (cd /rocks/connpool && luarocks make *rockspec) \
    && : "shard" \
    && git clone $LUAROCK_SHARD_REPO /rocks/shard \
    && (cd /rocks/shard; git checkout $LUAROCK_SHARD_TAG) \
    && (cd /rocks/shard && luarocks make *rockspec) \
    && : "http" \
    && git clone $LUAROCK_HTTP_REPO /rocks/http \
    && (cd /rocks/http; git checkout $LUAROCK_HTTP_TAG) \
    && (cd /rocks/http && luarocks make *rockspec) \
    && : "pg" \
    && git clone $LUAROCK_PG_REPO /rocks/pg \
    && (cd /rocks/pg; git checkout $LUAROCK_PG_TAG) \
    && (cd /rocks/pg && luarocks make *rockspec) \
    && : "mysql" \
    && git clone $LUAROCK_MYSQL_REPO /rocks/mysql \
    && (cd /rocks/mysql; git checkout $LUAROCK_MYSQL_TAG) \
    && (cd /rocks/mysql && luarocks make *rockspec) \
    && : "memcached" \
    && git clone $LUAROCK_MEMCACHED_REPO /rocks/memcached \
    && (cd /rocks/memcached; git checkout $LUAROCK_MEMCACHED_TAG) \
    && (cd /rocks/memcached && luarocks make *rockspec) \
    && : "prometheus" \
    && git clone $LUAROCK_TARANTOOL_PROMETHEUS_REPO /rocks/prometheus \
    && (cd /rocks/prometheus; git checkout $LUAROCK_TARANTOOL_PROMETHEUS_TAG) \
    && (cd /rocks/prometheus && luarocks make *rockspec) \
    && : "curl" \
    && git clone $LUAROCK_TARANTOOL_CURL_REPO /rocks/curl \
    && (cd /rocks/curl; git checkout $LUAROCK_TARANTOOL_CURL_TAG) \
    && (cd /rocks/curl && luarocks make *rockspec) \
    && : "mqtt" \
    && git clone $LUAROCK_MQTT_REPO /rocks/mqtt \
    && (cd /rocks/mqtt; git checkout $LUAROCK_MQTT_TAG) \
    && (cd /rocks/mqtt && luarocks make *rockspec) \
    && : "gis" \
    && git clone $LUAROCK_TARANTOOL_GIS_REPO /rocks/gis \
    && (cd /rocks/gis; git checkout $LUAROCK_TARANTOOL_GIS_TAG) \
    && (cd /rocks/gis && luarocks make *rockspec) \
    && : "gperftools" \
    && git clone $LUAROCK_GPERFTOOLS_REPO /rocks/gperftools \
    && (cd /rocks/gperftools; git checkout $LUAROCK_GPERFTOOLS_TAG) \
    && (cd /rocks/gperftools && luarocks make *rockspec) \
    && : "---------- remove build deps ----------" \
    && rm -rf /rocks \
    && yum -y remove \
        git \
        cmake \
        make \
        gcc-c++ \
        postgresql96-devel \
        lua-devel \
        cyrus-sasl-devel \
        curl-devel \
        libmosquitto-devel \
        libev-devel \
        wget \
        proj-devel \
        geos-devel \
        openssl-devel \
        perl \
        kernel-headers \
        golang-src \
    && rpm -qa | grep devel | xargs yum -y remove \
    && rm -rf /var/cache/yum


RUN set -x \
    && : "---------- gosu ----------" \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys \
       B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL \
       "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL \
       "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu


RUN mkdir -p /var/lib/tarantool \
    && chown tarantool:tarantool /var/lib/tarantool \
    && mkdir -p /opt/tarantool \
    && chown tarantool:tarantool /opt/tarantool \
    && mkdir -p /var/run/tarantool \
    && chown tarantool:tarantool /var/run/tarantool \
    && mkdir /etc/tarantool \
    && chown tarantool:tarantool /etc/tarantool

VOLUME /var/lib/tarantool
WORKDIR /opt/tarantool

COPY tarantool-entrypoint.lua /usr/local/bin/
COPY tarantool_set_config.lua /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/
COPY console /usr/local/bin/
COPY tarantool_is_up /usr/local/bin/
COPY tarantool.default /usr/local/etc/default/tarantool

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

HEALTHCHECK CMD tarantool_is_up

EXPOSE 3301
CMD [ "tarantool" ]
