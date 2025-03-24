#!/bin/bash

ENV_FILE="/etc/environment_container"

# Collect all environment variables needed for a full backup procedure and make sure they can be sourced
env | grep -E "^(GCS_|POSTGRES_|BACKUP_)" > "$ENV_FILE"
sed -i "s/^/export /" "$ENV_FILE"

exec "$@"
