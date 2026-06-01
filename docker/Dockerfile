FROM docker.io/python:3.13-slim

LABEL maintainer="AskAnna"

# renovate: datasource=github-releases depName=aptible/supercronic
ARG SUPERCRONIC_VERSION=v0.2.46
ARG TARGETARCH
ARG SUPERCRONIC_SHA256_AMD64=5adff01c5a797663948e656d2b61d10932369ee437eb5cb54fa872b2960f222b
ARG SUPERCRONIC_SHA256_ARM64=c0576a8eb092e3f79108ed0a2155a25c7766af78456e5a6070e54757ef513bfe

COPY docker/requirements.txt /tmp/requirements.txt

RUN apt-get update && apt-get install --no-install-recommends --assume-yes \
        curl \
        lsb-release \
        wget \
        gnupg \
        gcc \
        python3-dev \
        python3-setuptools \
    && sh -c 'echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg \
    && apt-get update && apt-get install --no-install-recommends --assume-yes \
        postgresql-client \
    && pip install --no-cache-dir -r /tmp/requirements.txt \
    && SUPERCRONIC_SHA256=$(eval echo \$SUPERCRONIC_SHA256_$(echo $TARGETARCH | tr '[:lower:]' '[:upper:]' | tr '/' '_')) \
    && curl -fsSL "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" -o /usr/local/bin/supercronic \
    && echo "${SUPERCRONIC_SHA256}  /usr/local/bin/supercronic" | sha256sum -c - \
    && chmod +x /usr/local/bin/supercronic \
    && apt-get remove --assume-yes \
        curl \
        lsb-release \
        wget \
        gnupg \
        gcc \
        python3-dev \
        python3-setuptools \
    && apt-get purge --assume-yes --auto-remove --option APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /tmp/requirements.txt

RUN addgroup --gid 1000 app \
    && adduser --uid 1000 --ingroup app --disabled-password --gecos "" --home /home/app app \
    && mkdir -p /backups /data \
    && chown app:app /backups /data /home/app

COPY ./backup_scripts /usr/local/bin/backup_scripts
RUN chmod +x /usr/local/bin/backup_scripts/* \
    && mv /usr/local/bin/backup_scripts/* /usr/local/bin \
    && rmdir /usr/local/bin/backup_scripts

COPY cron/crontab /etc/supercronic-crontab

COPY docker/entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

USER app

ENTRYPOINT ["/entrypoint"]
