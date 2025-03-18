FROM docker.io/python:3.12-slim AS python
LABEL maintainer="AskAnna"

RUN apt update && apt install --no-install-recommends --assume-yes \
        curl \
        lsb-release \
        wget \
        gnupg \
    && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt update && apt install --no-install-recommends --assume-yes \
        postgresql-client \
        cron \
        gcc \
    && pip install --no-cache-dir --upgrade crcmod \
    && curl -qLs https://storage.googleapis.com/pub/gsutil.tar.gz | tar -C /opt -zxf - \
    && ln -s /opt/gsutil/gsutil /usr/local/bin/gsutil \
    && apt remove --assume-yes \
        curl \
        lsb-release \
        wget \
        gnupg \
    && apt purge --assume-yes --auto-remove --option APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

COPY ./backup_scripts /usr/local/bin/backup_scripts
RUN chmod +x /usr/local/bin/backup_scripts/* \
    && mv /usr/local/bin/backup_scripts/* /usr/local/bin \
    && rmdir /usr/local/bin/backup_scripts

COPY cron/crontab /etc/cron.d/crontab
RUN chmod +x /etc/cron.d/crontab \
    && crontab /etc/cron.d/crontab
