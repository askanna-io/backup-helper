#!/usr/bin/env bash

BACKUP_DIR=${BACKUP_DIR:-/backups}
BACKUP_FILE_PREFIX=${BACKUP_FILE_PREFIX:-backup}
BACKUP_SOURCE=${BACKUP_SOURCE:-/data}
BACKUP_TARGET=${BACKUP_TARGET:-${BACKUP_SOURCE}}

GCS_BUCKET=${GCS_BUCKET:-}
GCS_KEY_FILE_PATH=${GCS_KEY_FILE_PATH:-/keys/gcs-key.json}

BOTO_CONFIG_PATH=${BOTO_CONFIG_PATH:-/root/.boto}
