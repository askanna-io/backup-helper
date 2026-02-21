#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

ENV_FILE="${HOME}/.backup_env"

# Collect environment variables needed for backup procedures
# File is stored in user home dir with restricted permissions
env | grep -E "^(GCS_|POSTGRES_|BACKUP_)" > "$ENV_FILE" || true
sed -i "s/^/export /" "$ENV_FILE"
chmod 600 "$ENV_FILE"

if [ $# -eq 0 ]; then
    exec backup_help
fi

exec "$@"
