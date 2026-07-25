#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Backwards compatibility with the deprecated GCS variables (v2.x)
if [[ -z "${REMOTE_URL:-}" ]] && [[ -n "${GCS_BUCKET:-}" ]]; then
    GCS_BUCKET="${GCS_BUCKET#gs://}"
    export REMOTE_URL=":gcs:${GCS_BUCKET}"
fi

if [[ -n "${GCS_KEY_FILE_PATH:-}" ]] && [[ -f "${GCS_KEY_FILE_PATH:-}" ]]; then
    export RCLONE_GCS_SERVICE_ACCOUNT_FILE="${GCS_KEY_FILE_PATH}"
fi

if [ $# -eq 0 ]; then
    exec backup_help
fi

exec "$@"
