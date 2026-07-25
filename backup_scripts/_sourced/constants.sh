#!/usr/bin/env bash

BACKUP_DIR=${BACKUP_DIR:-/backups}
BACKUP_FILE_PREFIX=${BACKUP_FILE_PREFIX:-backup}
BACKUP_KEEP_DAYS=${BACKUP_KEEP_DAYS:-NONE}
BACKUP_ZIP_FILES=${BACKUP_ZIP_FILES:-true}

POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_DB=${POSTGRES_DB:-}
POSTGRES_DATABASES=${POSTGRES_DATABASES:-}
POSTGRES_USER=${POSTGRES_USER:-}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-}

BACKUP_SOURCE=${BACKUP_SOURCE:-/data}
BACKUP_TARGET=${BACKUP_TARGET:-${BACKUP_SOURCE}}

GCS_BUCKET=${GCS_BUCKET:-}
GCS_KEY_FILE_PATH=${GCS_KEY_FILE_PATH:-/keys/gcs-key.json}

REMOTE_URL=${REMOTE_URL:-}

# Backwards compatibility with the deprecated GCS variables (v2.x). The Docker
# entrypoint does the same conversion, but commands started with
# 'docker compose exec' bypass the entrypoint, so it is repeated here.
if [[ -z "${REMOTE_URL}" ]] && [[ -n "${GCS_BUCKET}" ]]; then
    REMOTE_URL=":gcs:${GCS_BUCKET#gs://}"
fi
if [[ -z "${RCLONE_GCS_SERVICE_ACCOUNT_FILE:-}" ]] && [[ -f "${GCS_KEY_FILE_PATH}" ]]; then
    export RCLONE_GCS_SERVICE_ACCOUNT_FILE="${GCS_KEY_FILE_PATH}"
fi
