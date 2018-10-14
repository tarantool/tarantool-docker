FROM alpine:3.4
MAINTAINER mail@racktear.com

RUN addgroup -S tarantool \
    && adduser -S -G tarantool tarantool \
    && apk add --no-cache 'su-exec>=0.2'

ENV TARANTOOL_VERSION=1.5.5.27 \
    TARANTOOL_DOWNLOAD_URL=https://github.com/tarantool/tarantool.git \
    TARANTOOL_COMMIT=1687c022e7aa93e9c118e1b80e1eac6c429b1010 \
    TARANTOOL_INSTALL_LUADIR=/usr/local/share/tarantool \
    LUAROCKS_URL=http://keplerproject.github.io/luarocks/releases/luarocks-2.3.0.tar.gz \
    TARANTOOL_SNAP_DIR=/var/lib/tarantool \
    TARANTOOL_WAL_DIR=/var/lib/tarantool \
    TARANTOOL_PORT=3301 \
    TARANTOOL_ADMIN_PORT=3302

RUN set -x \
    && apk add --no-cache --virtual .run-deps \
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
        mariadb-client-libs \
        libpq \
        mariadb-libs \
    && apk add --no-cache --virtual .build-deps \
        perl \
        gcc \
        g++ \
        cmake \
        readline-dev \
        openssl-dev \
        yaml-dev \
        lz4-dev \
        binutils-dev \
        ncurses-dev \
        lua-dev \
        musl-dev \
        make \
        git \
        postgresql-dev \
        lua-dev \
        mariadb-dev \
        wget \
    && : "---------- tarantool ----------" \
    && mkdir -p /usr/src/tarantool \
    && git clone "$TARANTOOL_DOWNLOAD_URL" /usr/src/tarantool \
    && git -C /usr/src/tarantool checkout "$TARANTOOL_COMMIT" \
    && git -C /usr/src/tarantool submodule init \
    && git -C /usr/src/tarantool submodule update \
    && echo "$TARANTOOL_VERSION" > /usr/src/tarantool/VERSION \
    && (cd /usr/src/tarantool; \
       cmake -DENABLE_CLIENT:BOOL=ON \
             -DWITH_MYSQL:BOOL=ON \
             -DWITH_POSTGRESQL:BOOL=ON \
             -DCMAKE_BUILD_TYPE=RelWithDebInfo \
             -DENABLE_BUNDLED_LIBYAML:BOOL=OFF \
             -DENABLE_BACKTRACE:BOOL=ON \
             .) \
    && make -C /usr/src/tarantool -j \
    && make -C /usr/src/tarantool install \
    && make -C /usr/src/tarantool clean \
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
    && : "---------- remove build deps ----------" \
    && apk del .build-deps

COPY luarocks-config.lua /usr/local/etc/luarocks/config-5.1.lua

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

COPY docker-entrypoint.sh /usr/local/bin/

RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3301
CMD [ "tarantool_box", "-c", "/etc/tarantool/tarantool.cfg" ]
