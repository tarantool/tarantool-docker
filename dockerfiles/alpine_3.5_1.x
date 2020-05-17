FROM alpine:3.5
MAINTAINER mail@racktear.com

RUN addgroup -S tarantool \
    && adduser -S -G tarantool tarantool \
    && apk add --no-cache 'su-exec>=0.2'

# An ARG instruction goes out of scope at the end of the build
# stage where it was defined. To use an arg in multiple stages,
# each stage must include the ARG instruction
ARG TNT_VER
ENV TARANTOOL_VERSION=${TNT_VER} \
    TARANTOOL_DOWNLOAD_URL=https://github.com/tarantool/tarantool.git \
    GPERFTOOLS_REPO=https://github.com/gperftools/gperftools.git \
    GPERFTOOLS_TAG=gperftools-2.5 \
    LUAROCKS_URL=https://github.com/tarantool/luarocks/archive/6e6fe62d9409fe2103c0fd091cccb3da0451faf5.tar.gz \
    LUAROCK_VSHARD_VERSION=0.1.14 \
    LUAROCK_AVRO_SCHEMA_VERSION=3.0.3 \
    LUAROCK_EXPERATIOND_VERSION=1.0.1 \
    LUAROCK_QUEUE_VERSION=1.0.6 \
    LUAROCK_CONNPOOL_VERSION=1.1.1 \
    LUAROCK_HTTP_VERSION=1.1.0 \
    LUAROCK_MEMCACHED_VERSION=1.0.0 \
    LUAROCK_METRICS_VERSION=0.2.0 \
    LUAROCK_TARANTOOL_PG_VERSION=2.0.2 \
    LUAROCK_TARANTOOL_MYSQL_VERSION=2.0.1 \
    LUAROCK_TARANTOOL_MQTT_VERSION=1.2.1 \
    LUAROCK_TARANTOOL_GIS_VERSION=1.0.0 \
    LUAROCK_TARANTOOL_PROMETHEUS_VERSION=1.0.4 \
    LUAROCK_TARANTOOL_GPERFTOOLS_VERSION=1.0.1

COPY files/gperftools_alpine.diff /

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
        zlib \
        libunwind \
        icu \
        ca-certificates \
    && apk add --no-cache --virtual .build-deps \
        perl \
        gcc \
        g++ \
        cmake \
        file \
        readline-dev \
        libressl-dev \
        yaml-dev \
        lz4-dev \
        zlib-dev \
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
        icu-dev \
        wget \
    && : "---------- gperftools ----------" \
    && mkdir -p /usr/src/gperftools \
    && git clone "$GPERFTOOLS_REPO" /usr/src/gperftools \
    && git -C /usr/src/gperftools checkout "$GPERFTOOLS_TAG" \
    && (cd /usr/src/gperftools; \
        patch -p1 < /gperftools_alpine.diff; \
        rm /gperftools_alpine.diff; \
        ./autogen.sh; \
        ./configure; \
        make -j ; \
        cp .libs/libprofiler.so* /usr/local/lib;) \
    && (GOPATH=/usr/src/go go get github.com/google/pprof && \
        cp /usr/src/go/bin/pprof /usr/local/bin || true ) \
    && : "---------- tarantool ----------" \
    && mkdir -p /usr/src/tarantool \
    && git clone "$TARANTOOL_DOWNLOAD_URL" /usr/src/tarantool \
    && git -C /usr/src/tarantool checkout "$TARANTOOL_VERSION" \
    && git -C /usr/src/tarantool submodule update --init --recursive \
    && (cd /usr/src/tarantool; \
       echo "WARNING: Temporary fix for test/unit/cbus_hang test" ; \
       git cherry-pick d7fa6d34ab4e0956fe8a80966ba628e0e3f81067 2>/dev/null || \
           git cherry-pick --abort ; \
       cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo\
             -DENABLE_BUNDLED_LIBYAML:BOOL=OFF\
             -DENABLE_BACKTRACE:BOOL=ON\
             -DENABLE_DIST:BOOL=ON\
             .) \
    && make -C /usr/src/tarantool -j\
    && make -C /usr/src/tarantool install \
    && make -C /usr/src/tarantool clean \
    && : "---------- luarocks ----------" \
    && wget -O luarocks.tar.gz "$LUAROCKS_URL" \
    && mkdir -p /usr/src/luarocks \
    && tar -xzf luarocks.tar.gz -C /usr/src/luarocks --strip-components=1 \
    && (cd /usr/src/luarocks; \
        ./configure; \
        make -j build; \
        make install) \
    && rm -r /usr/src/luarocks \
    && rm -rf /usr/src/tarantool \
    && rm -rf /usr/src/gperftools \
    && rm -rf /usr/src/go \
    && : "---------- remove build deps ----------" \
    && apk del .build-deps

COPY files/luarocks-config.lua /usr/local/etc/luarocks/config-5.1.lua

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
        wget \
    && mkdir -p /rocks \
    && : "---------- proj (for gis module) ----------" \
    && wget -O proj.tar.gz http://download.osgeo.org/proj/proj-4.9.3.tar.gz \
    && mkdir -p /usr/src/proj \
    && tar -xzf proj.tar.gz -C /usr/src/proj --strip-components=1 \
    && (cd /usr/src/proj; \
        ./configure; \
        make -j ; \
        make install) \
    && rm -r /usr/src/proj \
    && rm -rf /usr/src/proj \
    && rm -rf /proj.tar.gz \
    && : "---------- geos (for gis module) ----------" \
    && wget -O geos.tar.bz2 http://download.osgeo.org/geos/geos-3.6.0.tar.bz2 \
    && mkdir -p /usr/src/geos \
    && tar -xjf geos.tar.bz2 -C /usr/src/geos --strip-components=1 \
    && (cd /usr/src/geos; \
        ./configure; \
        make -j ; \
        make install) \
    && rm -r /usr/src/geos \
    && rm -rf /usr/src/geos \
    && rm -rf /geos.tar.bz2 \
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
    && : "vshard" \
    && luarocks install vshard $LUAROCK_VSHARD_VERSION \
    && : "http" \
    && luarocks install http $LUAROCK_HTTP_VERSION \
    && : "pg" \
    && luarocks install pg $LUAROCK_TARANTOOL_PG_VERSION \
    && : "mysql" \
    && luarocks install mysql $LUAROCK_TARANTOOL_MYSQL_VERSION \
    && : "memcached" \
    && luarocks install memcached $LUAROCK_MEMCACHED_VERSION \
    && : "metrics" \
    && luarocks install metrics $LUAROCK_METRICS_VERSION \
    && : "prometheus" \
    && luarocks install prometheus $LUAROCK_TARANTOOL_PROMETHEUS_VERSION \
    && : "mqtt" \
    && luarocks install mqtt $LUAROCK_TARANTOOL_MQTT_VERSION \
    && : "gis" \
    && luarocks install gis $LUAROCK_TARANTOOL_GIS_VERSION \
    && : "gperftools" \
    && luarocks install gperftools $LUAROCK_TARANTOOL_GPERFTOOLS_VERSION \
    && : "---------- remove build deps ----------" \
    && apk del .build-deps

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

COPY files/tarantool-entrypoint.lua /usr/local/bin/
COPY files/tarantool_set_config.lua /usr/local/bin/
COPY files/docker-entrypoint.sh /usr/local/bin/
COPY files/console /usr/local/bin/
COPY files/tarantool_is_up /usr/local/bin/
COPY files/tarantool.default /usr/local/etc/default/tarantool

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

HEALTHCHECK CMD tarantool_is_up

EXPOSE 3301
CMD [ "tarantool" ]
