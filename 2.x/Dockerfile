FROM alpine:3.5
MAINTAINER mail@racktear.com

RUN addgroup -S tarantool \
    && adduser -S -G tarantool tarantool \
    && apk add --no-cache 'su-exec>=0.2'

ENV TARANTOOL_VERSION=2.2.0-128-g7b56f1fef \
    TARANTOOL_DOWNLOAD_URL=https://github.com/tarantool/tarantool.git \
    TARANTOOL_INSTALL_LUADIR=/usr/local/share/tarantool \
    CURL_REPO=https://github.com/curl/curl.git \
    CURL_TAG=curl-7_59_0 \
    GPERFTOOLS_REPO=https://github.com/gperftools/gperftools.git \
    GPERFTOOLS_TAG=gperftools-2.5 \
    LUAROCKS_URL=https://github.com/tarantool/luarocks/archive/6e6fe62d9409fe2103c0fd091cccb3da0451faf5.tar.gz \
    LUAROCK_SHARD_REPO=https://github.com/tarantool/shard.git \
    LUAROCK_SHARD_TAG=8f8c5a7 \
    LUAROCK_AVRO_SCHEMA_VERSION=2.0.1 \
    LUAROCK_EXPERATIOND_VERSION=1.0.1 \
    LUAROCK_QUEUE_VERSION=1.0.2 \
    LUAROCK_CONNPOOL_VERSION=1.1.1 \
    LUAROCK_HTTP_VERSION=1.0.1 \
    LUAROCK_MEMCACHED_VERSION=1.0.0 \
    LUAROCK_TARANTOOL_PG_VERSION=2.0.1 \
    LUAROCK_TARANTOOL_MYSQL_VERSION=2.0.1 \
    LUAROCK_TARANTOOL_CURL_VERSION=2.3.1 \
    LUAROCK_TARANTOOL_MQTT_VERSION=1.2.1 \
    LUAROCK_TARANTOOL_GIS_VERSION=1.0.0 \
    LUAROCK_TARANTOOL_PROMETHEUS_VERSION=1.0.0 \
    LUAROCK_TARANTOOL_GPERFTOOLS_VERSION=1.0.1

COPY gperftools_alpine.diff /

RUN set -x \
    && apk add --no-cache --virtual .run-deps \
        libstdc++ \
        readline \
        libressl \
        yaml \
        lz4 \
        binutils \
        ncurses \
        libgomp \
        lua \
        tar \
        zip \
        libunwind \
        icu \
        ca-certificates \
    && apk add --no-cache --virtual .build-deps \
        perl \
        gcc \
        g++ \
        cmake \
        readline-dev \
        libressl-dev \
        yaml-dev \
        lz4-dev \
        binutils-dev \
        ncurses-dev \
        lua-dev \
        musl-dev \
        make \
        git \
        libunwind-dev \
        autoconf \
        automake \
        libtool \
        linux-headers \
        go \
        tcl \
        icu-dev \
        wget \
    && : "---------- curl ----------" \
    && mkdir -p /usr/src/curl \
    && git clone "$CURL_REPO" /usr/src/curl \
    && git -C /usr/src/curl checkout "$CURL_TAG" \
    && (cd /usr/src/curl \
        && ./buildconf \
        && ./configure --prefix "/usr/local" \
        && make -j \
        && make install) \
    && : "---------- gperftools ----------" \
    && mkdir -p /usr/src/gperftools \
    && git clone "$GPERFTOOLS_REPO" /usr/src/gperftools \
    && git -C /usr/src/gperftools checkout "$GPERFTOOLS_TAG" \
    && (cd /usr/src/gperftools; \
        patch -p1 < /gperftools_alpine.diff; \
        rm /gperftools_alpine.diff; \
        ./autogen.sh; \
        ./configure; \
        make; \
        cp .libs/libprofiler.so* /usr/local/lib;) \
    && (GOPATH=/usr/src/go go get github.com/google/pprof; \
        cp /usr/src/go/bin/pprof /usr/local/bin) \
    && : "---------- tarantool ----------" \
    && mkdir -p /usr/src/tarantool \
    && git clone "$TARANTOOL_DOWNLOAD_URL" /usr/src/tarantool \
    && git -C /usr/src/tarantool checkout "$TARANTOOL_VERSION" \
    && git -C /usr/src/tarantool submodule update --init --recursive \
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
    && rm -rf /usr/src/gperftools \
    && rm -rf /usr/src/go \
    && : "---------- remove build deps ----------" \
    && apk del .build-deps

COPY luarocks-config.lua /usr/local/etc/luarocks/config-5.1.lua

RUN set -x \
    && apk add --no-cache --virtual .run-deps \
        mariadb-client-libs \
        libpq \
        cyrus-sasl \
        mosquitto-libs \
        libev \
    && apk add --no-cache --virtual .build-deps \
        git \
        cmake \
        make \
        coreutils \
        gcc \
        g++ \
        postgresql-dev \
        lua-dev \
        musl-dev \
        cyrus-sasl-dev \
        mosquitto-dev \
        libev-dev \
        libressl-dev \
    && mkdir -p /rocks \
    && : "---------- proj (for gis module) ----------" \
    && wget -O proj.tar.gz http://download.osgeo.org/proj/proj-4.9.3.tar.gz \
    && mkdir -p /usr/src/proj \
    && tar -xzf proj.tar.gz -C /usr/src/proj --strip-components=1 \
    && (cd /usr/src/proj; \
        ./configure; \
        make; \
        make install) \
    && rm -r /usr/src/proj \
    && rm -rf /usr/src/proj \
    && : "---------- geos (for gis module) ----------" \
    && wget -O geos.tar.bz2 http://download.osgeo.org/geos/geos-3.6.0.tar.bz2 \
    && mkdir -p /usr/src/geos \
    && tar -xjf geos.tar.bz2 -C /usr/src/geos --strip-components=1 \
    && (cd /usr/src/geos; \
        ./configure; \
        make; \
        make install) \
    && rm -r /usr/src/geos \
    && rm -rf /usr/src/geos \
    && : "---------- luarocks ----------" \
    && luarocks install lua-term \
    && luarocks install ldoc \
    && : "avro" \
    && luarocks install avro-schema $LUAROCK_AVRO_SCHEMA_VERSION \
    && : "expirationd" \
    && luarocks install expirationd $LUAROCK_EXPERATIOND_VERSION \
    && : "queue" \
    && luarocks install queue $LUAROCK_QUEUE_VERSION \
    && : "connpool" \
    && luarocks install connpool $LUAROCK_CONNPOOL_VERSION \
    && : "shard" \
    && git clone $LUAROCK_SHARD_REPO /rocks/shard \
    && git -C /rocks/shard checkout $LUAROCK_SHARD_TAG \
    && (cd /rocks/shard && luarocks make *rockspec) \
    && : "http" \
    && luarocks install http $LUAROCK_HTTP_VERSION \
    && : "pg" \
    && luarocks install pg $LUAROCK_TARANTOOL_PG_VERSION \
    && : "mysql" \
    && luarocks install mysql $LUAROCK_TARANTOOL_MYSQL_VERSION \
    && : "memcached" \
    && luarocks install memcached $LUAROCK_MEMCACHED_VERSION \
    && : "prometheus" \
    && luarocks install prometheus $LUAROCK_TARANTOOL_PROMETHEUS_VERSION \
    && : "curl" \
    && luarocks install tarantool-curl $LUAROCK_TARANTOOL_CURL_VERSION \
    && : "mqtt" \
    && luarocks install mqtt $LUAROCK_TARANTOOL_MQTT_VERSION \
    && : "gis" \
    && luarocks install gis $LUAROCK_TARANTOOL_GIS_VERSION \
    && : "gperftools" \
    && luarocks install gperftools $LUAROCK_TARANTOOL_GPERFTOOLS_VERSION \
    && : "---------- remove build deps ----------" \
    && apk del .build-deps \
    && rm -rf /rocks

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
