#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

gcs_upload
backup_clean
backup_postgres
backup_files
gcs_upload
