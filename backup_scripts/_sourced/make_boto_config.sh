#!/usr/bin/env bash

BOTO_CONFIG="${HOME}/.boto"

cat <<EOF >"${BOTO_CONFIG}"
[Credentials]
gs_service_key_file = $GCS_KEY_FILE_PATH
[Boto]
https_validate_certificates = True
[GoogleCompute]
[GSUtil]
content_language = en
default_api_version = 2
parallel_composite_upload_threshold = 150M
software_update_check_period = 0
[OAuth2]
EOF

chmod 600 "${BOTO_CONFIG}"
