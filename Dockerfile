FROM php:7.4.33-fpm-bullseye

# 安装基本依赖
RUN apt-get update && \
    apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libicu-dev \
        libxml2-dev \
        libzip-dev \
        libonig-dev \
        libssl-dev \
        libpq-dev \
        libbz2-dev \
        libgmp-dev \
        libpspell-dev \
        librecode-dev \
        libsqlite3-dev \
        libcurl4-openssl-dev \
        libreadline-dev \
        libedit-dev \
        libxslt-dev \
        libyaml-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libgd-dev \
        libgmp-dev \
        libzip-dev \
        libxmlrpc-core-c3-dev \
        libsoap-lite-perl \
        libssl-dev \
        libnghttp2-dev \
        libpcre3-dev && \
    rm -rf /var/lib/apt/lists/*

# 安装 SourceGuardian
RUN cd /tmp && \
    curl -LO https://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz && \
    tar zxvf loaders.linux-x86_64.tar.gz && \
    mkdir -p /usr/local/sourceguardian && \
    cp ixed.7.4.lin /usr/local/sourceguardian/ && \
    echo 'zend_extension=/usr/local/sourceguardian/ixed.7.4.lin' > /usr/local/etc/php/conf.d/sourceguardian.ini && \
    rm -rf /tmp/*

# 安装其他扩展
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    gd \
    gettext \
    intl \
    mysqli \
    pcntl \
    pdo_mysql \
    shmop \
    soap \
    sockets \
    sysvsem \
    xmlrpc \
    zip

# 安装 Redis 扩展
RUN pecl install redis && \
    docker-php-ext-enable redis

# 安装 Swoole 扩展
RUN pecl install  swoole-4.5.11 && \
    docker-php-ext-enable swoole

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    nginx supervisor \
    && rm -r /var/lib/apt/lists/*

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
RUN apt-get update && \
    apt-get install -y --no-install-recommends neovim net-tools iputils-ping telnet zip unzip wget tzdata curl ca-certificates fontconfig locales && \
    locale-gen -a && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

# 设置工作目录
WORKDIR /var/www/html

# 配置 supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 启动 PHP-FPM 和 Nginx 服务
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
