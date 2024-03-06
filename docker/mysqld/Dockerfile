#syntax=docker/dockerfile:1.3

FROM mysql:8.3.0 as base

RUN addgroup mysql tty

# Switch to root for the ability to perform install

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/mysqld/access.log \
    && ln -sf /dev/stderr /var/log/mysqld/error.log
