# Backup Helper

The Backup Helper aims to help you make and restore backups of your project files and PostgreSQL database.
Also, you can upload and download backup files to a remote storage. Remote storage support is powered by
[rclone](https://rclone.org), so you can use Google Cloud Storage, Amazon S3, Azure Blob Storage, SFTP and
[many other storage backends](https://rclone.org/overview/).

A list of commands that you can run with this container:

- `full_backup_procedure`: run a full backup procedure (upload, clean, backup postgres & files and upload)
- `backup_postgres`: make a backup of PostgreSQL database(s)
- `backup_files`: make a backup of files and directories
- `backup_ls`: list local backup files
- `backup_clean`: remove local backup files
- `restore_postgres`: restore a backup of a PostgreSQL database
- `restore_files`: restore a backup of files and directories
- `remote_upload`: upload backup files to a remote storage
- `remote_download`: download a backup file from a remote storage
- `remote_ls`: list backup files present on a remote storage

The `gcs_upload`, `gcs_download` and `gcs_ls` commands from version 2.x are still available as deprecated
aliases of the `remote_*` commands.

Run the container without a command to see the available commands:

```shell
docker run --rm registry.gitlab.com/askanna/backup-helper:latest
```

In the rest of this README, you can find more information about how to run and configure these commands.

## Docker image

The Docker image of the Backup Helper is available on
[GitLab Container Registry](https://gitlab.com/askanna/backup-helper/container_registry):

```shell
docker pull registry.gitlab.com/askanna/backup-helper:latest
```

## Configuration

Via environment variables you can configure the Backup Helper.

| Environment variable | Required | Default            | Description                                                  |
| -------------------- | -------- | ------------------ | ------------------------------------------------------------ |
| `BACKUP_DIR`         | No       | `/backups`         | The path where the backups will be saved                     |
| `BACKUP_FILE_PREFIX` | No       | `backup`           | An optional prefix for the backup filename                   |
| `BACKUP_KEEP_DAYS`   | No       | `NONE`             | The number of days you want to keep local backup files. The Backup Helper only removes local backup files when you run `backup_clean`.<br>&nbsp;<br>`NONE`: remove all local backups<br>`0`: keep backups that are modified less than 24 hours ago<br>`1`: keep backups that are modified less than 48 hours ago<br>`n`: keep backups that are modified less than `(n + 1) * 24` hours ago |
| `BACKUP_ZIP_FILES`   | No       | `true`             | `true` / `false`; if set to `true`, file compression with gzip will be applied. To speed up the backup of files, you can set `BACKUP_ZIP_FILES` to `false`. |

### PostgreSQL configuration

| Environment variable | Required | Default            | Description                                                  |
| -------------------- | -------- | ------------------ | ------------------------------------------------------------ |
| `POSTGRES_HOST`      | No       | `localhost`        | The PostgreSQL database server host                          |
| `POSTGRES_PORT`      | No       | `5432`             | The PostgreSQL database server port                          |
| `POSTGRES_DB`        | No       |                    | The database to backup. If this variable is not set, the `POSTGRES_USER` name is used (ref. [documentation](https://www.postgresql.org/docs/current/app-pgdump.html)). |
| `POSTGRES_DATABASES` | No       |                    | The databases to backup. If both `POSTGRES_DATABASES` and `POSTGRES_DB` are provided, the `POSTGRES_DATABASES` variable will be used.<br>&nbsp;<br>Format: `database_1 database_2 database_3` (without quotation marks) |
| `POSTGRES_USER`      | No       |                    | The PostgreSQL database user                                 |
| `POSTGRES_PASSWORD`  | No       |                    | The PostgreSQL database password                             |

### File configuration

| Environment variable | Required | Default            | Description                                                  |
| -------------------- | -------- | ------------------ | ------------------------------------------------------------ |
| `BACKUP_SOURCE`      | No       | `/data`            | The path of the directory with the files to backup           |
| `BACKUP_TARGET`      | No       | `${BACKUP_SOURCE}` | The path of the directory where files should be restored to  |

### Remote storage configuration

| Environment variable | Required | Default            | Description                                                  |
| -------------------- | -------- | ------------------ | ------------------------------------------------------------ |
| `REMOTE_URL`         | No       |                    | The remote storage location to upload backup files to or download them from, written as an rclone [connection string](https://rclone.org/docs/#connection-strings), e.g. `:gcs:my-bucket`, `:s3:my-bucket` or `:sftp:/backups`<br>&nbsp;<br>This variable is required if you want to use the Backup Helper to upload files to or download from a remote storage. |

The Backup Helper uses [rclone](https://rclone.org) for remote storage operations. Credentials and other
backend options are configured with rclone environment variables in the format `RCLONE_<BACKEND>_<OPTION>`
(see the [rclone documentation](https://rclone.org/docs/#environment-variables)). Below are examples for a few
popular backends.

Instead of environment variables, you can also mount an [rclone config file](https://rclone.org/docs/#config-config-file)
at `/home/app/.config/rclone/rclone.conf` and set `REMOTE_URL` to a named remote like `my-remote:my-bucket`.

#### Google Cloud Storage

```yaml
environment:
  REMOTE_URL: ":gcs:my-bucket"
  RCLONE_GCS_SERVICE_ACCOUNT_FILE: /keys/gcs-key.json
```

To use the Google Cloud Storage features, you need to have a Google service account or
[create a new service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account).
To authenticate, you need to have the associated private JSON key of the service account or
[create a new service account JSON key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

#### Amazon S3 (and S3-compatible providers)

```yaml
environment:
  REMOTE_URL: ":s3:my-bucket"
  RCLONE_S3_PROVIDER: AWS
  RCLONE_S3_REGION: eu-central-1
  RCLONE_S3_ACCESS_KEY_ID: <access key id>
  RCLONE_S3_SECRET_ACCESS_KEY: <secret access key>
```

#### Azure Blob Storage

```yaml
environment:
  REMOTE_URL: ":azureblob:my-container"
  RCLONE_AZUREBLOB_ACCOUNT: <storage account name>
  RCLONE_AZUREBLOB_KEY: <storage account key>
```

#### SFTP

```yaml
environment:
  REMOTE_URL: ":sftp:/backups"
  RCLONE_SFTP_HOST: sftp.example.com
  RCLONE_SFTP_USER: <user>
  RCLONE_SFTP_PASS: <obscured password>
```

The SFTP password must be obscured with [rclone obscure](https://rclone.org/commands/rclone_obscure/):

```shell
docker compose run --rm backup_helper rclone obscure <password>
```

### Deprecated: Google Cloud Storage configuration

The following environment variables are deprecated since version 3.0. They keep working: when set, they are
automatically converted to the rclone equivalents. See also the
[migration guide](#migrating-from-v2-to-v3).

| Environment variable | Required | Default            | Description                                                  |
| -------------------- | -------- | ------------------ | ------------------------------------------------------------ |
| `GCS_BUCKET`         | No       |                    | **Deprecated**, use `REMOTE_URL` instead. When set and `REMOTE_URL` is not set, it is converted to `REMOTE_URL=":gcs:<bucket>"`. |
| `GCS_KEY_FILE_PATH`  | No       | `/keys/gcs-key.json` | **Deprecated**, use `RCLONE_GCS_SERVICE_ACCOUNT_FILE` instead. When the file exists, it is exported as `RCLONE_GCS_SERVICE_ACCOUNT_FILE`. |

## Container user

The container runs as a non-root `app` user with UID 1000 and GID 1000. If you share volumes between the Backup
Helper and other containers (e.g. a Django application), make sure those containers use the same UID/GID so that
file permissions are consistent.

Key files that you mount into the container (e.g. a GCS service account key file) must be readable by the
`app` user. When mounting a key file as a bind mount, set the group to GID 1000 and permissions to 640 on the
host:

```shell
chown <owner>:1000 /path/to/gcs-key.json
chmod 640 /path/to/gcs-key.json
```

## Daily backup

When you start the container without a command, it shows the available commands. To schedule a daily backup, start
the container with `supercronic`:

```shell
command: supercronic /etc/supercronic-crontab
```

See also ['How we use it'](#how-we-use-it).

## How we use it

We use the Backup Helper for the AskAnna project that we run as a Docker Stack. In our
[Docker Compose](https://docs.docker.com/compose/) file we have a service named `backup_helper`:

```yaml
backup_helper:
  image: registry.gitlab.com/askanna/backup-helper:latest
  command: supercronic /etc/supercronic-crontab
  volumes:
    - backup_volume:/backups
    - storage_volume:/data
    - ../gcs-key.json:/keys/gcs-key.json:ro
  env_file:
    - ./postgres.env
  environment:
    REMOTE_URL: ":gcs:<Google Cloud Storage Bucket name>"
    RCLONE_GCS_SERVICE_ACCOUNT_FILE: /keys/gcs-key.json
```

With the Backup Helper available as a service in the Docker Stack, we can perform backup tasks. Depending on the
backup task, we run one or multiple of the commands below.

> If you don't want to schedule a daily backup, remove the `command` line.

## Make backup

### Full backup procedure

```shell
docker compose run --rm backup_helper full_backup_procedure
```

This command actually runs the following commands:

- remote_upload
- backup_clean
- backup_postgres
- backup_files
- remote_upload

The full backup procedure is also the command used for the daily backup.

### Backup PostgreSQL

```shell
docker compose run --rm backup_helper backup_postgres
```

### Backup files

```shell
docker compose run --rm backup_helper backup_files
```

## List backups

```shell
docker compose run --rm backup_helper backup_ls
```

## Restore backup

### Restore PostgreSQL

```shell
docker compose run --rm backup_helper restore_postgres <backup file>
```

### Restore files

```shell
docker compose run --rm backup_helper restore_files <backup file>
```

## Clean backups

```shell
docker compose run --rm backup_helper backup_clean
```

## Remote storage

### Upload backup

```shell
docker compose run --rm backup_helper remote_upload
```

### Download backup

```shell
docker compose run --rm backup_helper remote_download <backup file>
```

### List backups on the remote storage

```shell
docker compose run --rm backup_helper remote_ls
```

## Migrating from v2 to v3

In version 3.0, the Backup Helper switched from gsutil to [rclone](https://rclone.org) for storage operations.
Google will no longer include gsutil in the default Google Cloud CLI installation package per March 2027, and
with rclone the Backup Helper supports many more storage backends than Google Cloud Storage alone.

An existing v2.x setup keeps working without changes: the deprecated `GCS_BUCKET` and `GCS_KEY_FILE_PATH`
variables are automatically converted to their rclone equivalents, and the `gcs_*` commands remain available
as aliases. To future-proof your setup:

1. Replace `GCS_BUCKET: <bucket>` with `REMOTE_URL: ":gcs:<bucket>"` (without the `gs://` prefix)
2. Replace `GCS_KEY_FILE_PATH: <path>` with `RCLONE_GCS_SERVICE_ACCOUNT_FILE: <path>`
3. Replace the `gcs_upload`, `gcs_download` and `gcs_ls` commands with `remote_upload`, `remote_download` and
   `remote_ls`, for example in scripts that call the Backup Helper

## Credits

The Backup Helper is inspired by [cookiecutter/cookiecutter-django](https://github.com/cookiecutter/cookiecutter-django) and [diogopms/postgres-gcs-backup](https://github.com/diogopms/postgres-gcs-backup).
