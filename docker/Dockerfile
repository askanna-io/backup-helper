FROM docker.io/debian:trixie-slim@sha256:020c0d20b9880058cbe785a9db107156c3c75c2ac944a6aa7ab59f2add76a7bd

LABEL maintainer="AskAnna"

ARG TARGETARCH

# Version and checksums below are updated by Renovate (customManagers in renovate.json)
ARG SUPERCRONIC_VERSION=v0.2.48
ARG SUPERCRONIC_SHA256_AMD64=88c1b66b94c486f972fdd1a4d1f901e3e75ff04f749cddd60c5db573e3a33c6c
ARG SUPERCRONIC_SHA256_ARM64=50ae8755e04fa72812d0a1bc47a112a856811cc91cce7b6c875c378a850788bc

# renovate: datasource=github-releases depName=rclone/rclone
ARG RCLONE_VERSION=v1.74.4

RUN apt-get update && apt-get install --no-install-recommends --assume-yes \
        ca-certificates \
        curl \
        gnupg \
        unzip \
    && . /etc/os-release \
    && echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg \
    && apt-get update && apt-get install --no-install-recommends --assume-yes \
        postgresql-client \
    && SUPERCRONIC_SHA256=$(eval echo \$SUPERCRONIC_SHA256_$(echo $TARGETARCH | tr '[:lower:]' '[:upper:]' | tr '/' '_')) \
    && curl -fsSL "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" -o /usr/local/bin/supercronic \
    && echo "${SUPERCRONIC_SHA256}  /usr/local/bin/supercronic" | sha256sum -c - \
    && chmod +x /usr/local/bin/supercronic \
    && curl -fsSL "https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip" -o "/tmp/rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip" \
    && curl -fsSL "https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/SHA256SUMS" -o /tmp/SHA256SUMS \
    && cd /tmp \
    && grep "rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip" SHA256SUMS | sha256sum -c - \
    && unzip -q "rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip" \
    && install -m 755 "rclone-${RCLONE_VERSION}-linux-${TARGETARCH}/rclone" /usr/local/bin/rclone \
    && rm -rf "/tmp/rclone-${RCLONE_VERSION}-linux-${TARGETARCH}" "/tmp/rclone-${RCLONE_VERSION}-linux-${TARGETARCH}.zip" /tmp/SHA256SUMS \
    && apt-get remove --assume-yes \
        curl \
        gnupg \
        unzip \
    && apt-get purge --assume-yes --auto-remove --option APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

# GCS buckets with uniform bucket-level access reject per-object ACLs, so do
# not send them (gsutil did the same). Set RCLONE_GCS_BUCKET_POLICY_ONLY=false
# if you need rclone to set per-object ACLs on a fine-grained-access bucket.
ENV RCLONE_GCS_BUCKET_POLICY_ONLY=true

RUN addgroup --gid 1000 app \
    && adduser --uid 1000 --ingroup app --disabled-password --gecos "" --home /home/app app \
    && mkdir -p /backups /data /home/app/.config/rclone \
    && touch /home/app/.config/rclone/rclone.conf \
    && chown -R app:app /backups /data /home/app

COPY ./backup_scripts /usr/local/bin/backup_scripts
RUN chmod +x /usr/local/bin/backup_scripts/* \
    && mv /usr/local/bin/backup_scripts/* /usr/local/bin \
    && rmdir /usr/local/bin/backup_scripts \
    && ln -s /usr/local/bin/remote_upload /usr/local/bin/gcs_upload \
    && ln -s /usr/local/bin/remote_download /usr/local/bin/gcs_download \
    && ln -s /usr/local/bin/remote_ls /usr/local/bin/gcs_ls

COPY cron/crontab /etc/supercronic-crontab

COPY docker/entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

USER app

ENTRYPOINT ["/entrypoint"]
