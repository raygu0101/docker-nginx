FROM alpine:latest
MAINTAINER Raygu raygu@tencent.com

# menshen only support nginx below 1.8.0
ENV NGINX_VERSION 1.8.0

ENV GPG_KEYS B0F4253373F8F6F510D42178520A9993A1C052F8

# nginx config
ENV CONFIG "\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/data/logs/nginx-error.log \
    --http-log-path=/data/logs/nginx-access.log \
    --user=www-data \
    --group=www-data \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    "

# add group && user
# 82 is the standard uid/gid for "www-data" in Alpine
RUN \
  addgroup -g 82 www-data \
  && adduser -u 82 -D -G www-data www-data

# set apk repositories
RUN \
  mkdir -p /etc/apk \
  && echo 'http://mirrors.aliyun.com/alpine/v3.4/main' > /etc/apk/repositories \
  && cat /etc/apk/repositories

RUN \
  # install basic lib
  apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg \

  # download nginx
  && gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEYS" \
  && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
  && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
  && gpg --verify nginx.tar.gz.asc \
  && mkdir -p /usr/src \
  && tar -zxC /usr/src -f nginx.tar.gz \
  && rm nginx.tar.gz* \
  && rm -r /root/.gnupg \

  # install nginx
  && cd /usr/src/nginx-$NGINX_VERSION \
  && ./configure $CONFIG \
  && make \
  && make install \

  # clean basic libs
  && strip /usr/sbin/nginx* \
  && runDeps="$( \
      scanelf --needed --nobanner /usr/sbin/nginx \
        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
        | sort -u \
        | xargs -r apk info --installed \
        | sort -u \
    )" \
  && apk add --virtual .nginx-rundeps $runDeps \
  && apk del .build-deps \
  && rm -rf /usr/src/nginx-*

RUN apk add --no-cache \
  bash \
  supervisor \
  tzdata \
  inotify-tools

# sync time
RUN echo "Asia/shanghai" > /etc/timezone && \
    cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ADD container-files /

RUN chmod -R 711 /config

VOLUME ["/data"]

EXPOSE 80 443

ENTRYPOINT ["/config/bootstrap.sh"]
