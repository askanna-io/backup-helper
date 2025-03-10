#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

echo -e "Starting daily backup procedure\n"

gcs_upload
backup_clean
backup_postgres
backup_files
gcs_upload

echo -e "\nFinished daily backup procedure"
