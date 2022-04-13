#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

backup_postgres
backup_files
gcs_upload
backup_clean
