# Changelog of the AskAnna Backup Helper

## Unreleased

- Replace gsutil with rclone for remote storage operations. Google will no longer include gsutil in the default
  Google Cloud CLI installation package per March 2027, and rclone adds support for
  [70+ storage backends](https://rclone.org/overview/) such as Google Cloud Storage, Amazon S3, Azure Blob Storage
  and SFTP
- Add `REMOTE_URL` environment variable to configure the remote storage as an rclone connection string
  (e.g. `:gcs:my-bucket`)
- Rename `gcs_upload`, `gcs_download` and `gcs_ls` to `remote_upload`, `remote_download` and `remote_ls`; the
  `gcs_*` commands remain available as deprecated aliases
- Deprecate `GCS_BUCKET` and `GCS_KEY_FILE_PATH`; they keep working and are converted to `REMOTE_URL` and
  `RCLONE_GCS_SERVICE_ACCOUNT_FILE`
- Skip the upload with a warning instead of failing when no remote storage is configured
- Switch base image from `python:3.13-slim` to `debian:bookworm-slim` with digest pinning, shrinking the image
  by about 20% (arm64 unpacked: 342MB → 273MB)
- Verify the rclone download against the `SHA256SUMS` file of the rclone release during the Docker build
- Remove the boto config file generation and `docker/requirements.txt`
- Track rclone releases with Renovate
- Update the CI `verify_image` job to check rclone, the `remote_*` commands and the `GCS_BUCKET` conversion
- Update supercronic to v0.2.48
- Fix supercronic SHA256 checksums not being updated on version bumps: Renovate now
  tracks the version and per-arch checksums together via a custom manager using the
  `github-release-attachments` datasource

## 2.0.4

- Use pipeline variables (`UPDATE_CACHE`, `RENOVATE`) instead of schedule-based CI rules
- Add `customManagers:dockerfileVersions` preset to fix Renovate tracking of supercronic version
- Add script, crontab and user checks to `verify_image` CI job
- Pin Renovate image to a specific version so Renovate tracks its own updates
- Pass a GitHub token to the Renovate job so it can look up `github-releases` datasources
- Update Renovate image to v43.251
- Update supercronic to v0.2.47

## 2.0.3

- Remove `.backup_env` workaround; supercronic inherits environment from the container
- Migrate Renovate config to use `managerFilePatterns` instead of deprecated `fileMatch`
- Fix Renovate `allowedVersions` syntax for Docker versioning

## 2.0.2

- Add major and minor version Docker tags (e.g. `2` and `2.0`) for easier production deployments

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
