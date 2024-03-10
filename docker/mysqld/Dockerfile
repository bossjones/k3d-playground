#syntax=docker/dockerfile:1.3

# FROM mysql:8.0.36-bookworm as base

# RUN addgroup mysql tty

# ENV DEBIAN_FRONTEND=noninteractive
# RUN echo "US/Eastern" | tee /etc/timezone && \
#     dpkg-reconfigure tzdata && \
#     cp /usr/share/zoneinfo/US/Eastern /etc/localtime

# # Switch to root for the ability to perform install

# # forward request and error logs to docker log collector
# # RUN ln -sf /dev/stdout /var/log/mysqld/access.log \
# #     && ln -sf /dev/stderr /var/log/mysqld/error.log




FROM mariadb:10.4 as base
# FROM docker.io/arm64v8/mariadb:10.4 as base

# SOURCE: https://raw.githubusercontent.com/jakubboucek/docker-lamp-devstack/master/mysql/mysql-unicode.cnf
# LABEL maintainer="Jakub Bouček <pan@jakubboucek.cz>"
# LABEL org.label-schema.name="MariaDB 11.4 (Release Candidate)"
# LABEL org.label-schema.vcs-url="https://github.com/jakubboucek/docker-lamp-devstack"

# Workdir during installation
WORKDIR /tmp

# OS binaries install && update critical binaries
RUN set -eux; \
    DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        nano \
        openssl \
        tzdata; \
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*;

# Workdir after installation
WORKDIR /

COPY mysql-unicode.cnf /etc/mysql/conf.d/mysql-unicode.cnf
COPY mysql-max-packet.cnf /etc/mysql/conf.d/mysql-max-packet.cnf
