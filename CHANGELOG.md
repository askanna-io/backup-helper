# Changelog of the AskAnna Backup Helper

## Unreleased

## 2.0.1

- Update Docker image from 28 to 29 (cli + dind) in CI pipeline
- Pin Python Docker image to 3.13.x in Renovate config

## 2.0.0

- Switch container user from `root` to `app` (UID 1000, GID 1000)
- Show available commands when container starts without arguments
- Switch base image from Python 3.12 to 3.13
- Replace cron with supercronic for scheduled backups
- Install gsutil via pip instead of tar download
- Extract pip dependencies to `docker/requirements.txt`
- Add path traversal prevention in `gcs_download`, `restore_files` and `restore_postgres`
- Fix GCS bucket regex pattern (`^gs://` instead of `gs://*`)
- Fix variable quoting in shell scripts
- Restrict permissions on boto config and backup env file
- Add error tracing with step tracking in `full_backup_procedure`
- Use trap for temp file cleanup in `backup_clean`
- Add `backup_help` command for use while container is running
- Add `--no-same-owner` to tar restore for non-root compatibility
- Switch Docker build cache from local to registry-based
- Add scheduled no-cache Docker builds (weekly, Sunday)
- Use lighter `docker:28-cli` image for build job
- Add workflow auto-cancel for interruptible CI jobs
- Add Renovate for automated dependency update tracking
- Add automatic GitLab releases on semver tags
- Update README with container user instructions, supercronic usage and GitLab Container Registry

## 1.4.2

- Fix downloading large files from GCS by installing the required Python tools for crcmod

## 1.4.1

- Fix daily cronjob by sourcing required environment variables
- Fix downloading large files from GCS by installing gcc for crcmod

## 1.4.0

- Add multiplatform support
- Refactored build job, a.o. to support multiplatform build

## 1.3.0

- Add command + script that runs a full backup procedure
- Refactor cron schedule to run the full backup procedure daily at 2:15

## 1.2.2

- Fix daily cronjob config

## 1.2.1

- Install cron

## 1.2.0

- Add support for the latest version of PostgreSQL
- Fix tar command to support the latest version of tar
- Remove publishing containers to Docker Hub
- Drop support for GitPod

## 1.1.0

The backup of files was always using gzip, which could make it slow to make a backup. In this update, we made it
configurable if you want to apply compression to the file backup archive.

We also improved the code quality and added GitPod config.

## 1.0.0

The first version of the AskAnna Backup Helper with support to backup and restore files and PostgreSQL databases. And
to upload and download backup files from Google Cloud Storage Buckets.
