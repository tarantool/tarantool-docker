FROM centos:7
MAINTAINER mail@racktear.com

RUN groupadd tarantool \
    && adduser -g tarantool tarantool

ENV TARANTOOL_VERSION=2.1.2-52-g154345fc5 \
    TARANTOOL_DOWNLOAD_URL=https://github.com/tarantool/tarantool.git \
    TARANTOOL_INSTALL_LUADIR=/usr/local/share/tarantool \
    CURL_REPO=https://github.com/curl/curl.git \
    CURL_TAG=curl-7_64_0 \
    LUAROCKS_URL=https://github.com/tarantool/luarocks/archive/6e6fe62d9409fe2103c0fd091cccb3da0451faf5.tar.gz \
    LUAROCK_VSHARD_VERSION=0.1.8 \
    LUAROCK_CHECKS_VERSION=3.0.0 \
    LUAROCK_AVRO_SCHEMA_VERSION=3.0.3 \
    LUAROCK_EXPERATIOND_VERSION=1.0.1 \
    LUAROCK_QUEUE_VERSION=1.0.3 \
    LUAROCK_CONNPOOL_VERSION=1.1.1 \
    LUAROCK_HTTP_VERSION=1.0.5 \
    LUAROCK_MEMCACHED_VERSION=1.0.0 \
    LUAROCK_TARANTOOL_PG_VERSION=2.0.2 \
    LUAROCK_TARANTOOL_MYSQL_VERSION=2.0.1 \
    LUAROCK_TARANTOOL_GIS_VERSION=1.0.0 \
    LUAROCK_TARANTOOL_PROMETHEUS_VERSION=1.0.4 \
    LUAROCK_TARANTOOL_GPERFTOOLS_VERSION=1.0.1

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
        tar \
        zip \
        unzip \
        libunwind \
        ca-certificates \
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
    && : "---------- libicu ----------" \
    && wget http://download.icu-project.org/files/icu4c/63.1/icu4c-63_1-src.tgz \
    && mkdir -p /usr/src/icu \
        && tar -xzf icu4c-63_1-src.tgz -C /usr/src/icu --strip-components=1 \
        && rm icu4c-63_1-src.tgz \
    && (cd /usr/src/icu/source; \
        chmod +x runConfigureICU configure install-sh; \
        ./runConfigureICU Linux/gcc; \
        make; \
        make install; \
        echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf; \
        ldconfig ) \
    && : "---------- curl ----------" \
    && mkdir -p /usr/src/curl \
    && git clone "$CURL_REPO" /usr/src/curl \
    && (cd /usr/src/curl; \
        git checkout "$CURL_TAG"; \
        ./buildconf; \
        ./configure --with-ssl --prefix "/usr/local"; \
        make -j; \
        make install; \
        ldconfig ) \
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
    && rm -rf /usr/src/icu \
    && rm -rf /usr/src/curl \
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
    && rpm -qa | grep devel | xargs yum -y remove \
    && rm -rf /var/cache/yum


COPY luarocks-config.lua /usr/local/etc/luarocks/config-5.1.lua

RUN set -x \
    && yum -y install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm \
    && yum -y install \
        mariadb-libs \
        postgresql96-libs \
        cyrus-sasl \
        libev \
        proj \
        geos \
        unzip \
        openssl-libs \
    && yum -y install \
        git \
        cmake \
        make \
        gcc-c++ \
        postgresql96-devel \
        lua-devel \
        cyrus-sasl-devel \
        libev-devel \
        wget \
        proj-devel \
        geos-devel \
        openssl-devel \
    && mkdir -p /rocks \
    && : "---------- luarocks ----------" \
    && luarocks install lua-term \
    && luarocks install ldoc \
    && : "vshard" \
    && luarocks install vshard $LUAROCK_VSHARD_VERSION \
    && : "checks" \
    && luarocks install checks $LUAROCK_CHECKS_VERSION \
    && : "avro" \
    && luarocks install avro-schema $LUAROCK_AVRO_SCHEMA_VERSION \
    && : "expirationd" \
    && luarocks install expirationd $LUAROCK_EXPERATIOND_VERSION \
    && : "queue" \
    && luarocks install queue $LUAROCK_QUEUE_VERSION \
    && : "connpool" \
    && luarocks install connpool $LUAROCK_CONNPOOL_VERSION \
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
    && : "gis" \
    && luarocks install gis $LUAROCK_TARANTOOL_GIS_VERSION \
    && : "gperftools" \
    && luarocks install gperftools $LUAROCK_TARANTOOL_GPERFTOOLS_VERSION \
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
