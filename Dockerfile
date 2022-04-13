FROM alpine:3
LABEL maintainer="AskAnna"

RUN apk add --no-cache --update \
    bash \
    postgresql-client \
    python3 \
    && apk add --no-cache --update --virtual build-deps \
    curl \
    gcc \
    musl-dev \
    python3-dev \
    py3-setuptools \
    py3-pip \
    && pip3 install --no-cache-dir crcmod \
    && curl -qLs https://storage.googleapis.com/pub/gsutil.tar.gz | tar -C /opt -zxf - \
    && apk del --no-cache build-deps \
    && ln -s /opt/gsutil/gsutil /usr/local/bin/gsutil

COPY ./backup_scripts /usr/local/bin/backup_scripts
RUN chmod +x /usr/local/bin/backup_scripts/* \
    && mv /usr/local/bin/backup_scripts/* /usr/local/bin \
    && rmdir /usr/local/bin/backup_scripts

COPY ./cron_scripts/daily /etc/periodic/daily/cron_scripts
RUN chmod +x /etc/periodic/daily/cron_scripts/* \
    && mv /etc/periodic/daily/cron_scripts/* /etc/periodic/daily \
    && rmdir /etc/periodic/daily/cron_scripts
