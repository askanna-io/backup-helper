# Backup Helper

The Backup Helper aims to help you make and restore backups of your project files and PostgreSQL database.
Also, you can upload and download backup files to Google Cloud Storage.

A list of commands that you can run with this container:

- `backup_postgres`: make a backup of PostgreSQL database(s)
- `backup_files`: make a backup of files and directories
- `backup_ls`: list local backup files
- `backup_clean`: remove local backup files
- `restore_postgres`: restore a backup of a PostgreSQL database
- `restore_files`: restore a backup of files and directories
- `gcs_upload`: upload backup files to Google Cloud Storage
- `gcs_download`: download a backup file from Google Cloud Storage
- `gcs_ls`: list backup files present in Google Cloud Storage

In the rest of this README, you can find more information about how to run and configure these commands.

## Docker image

The Docker image of the Backup Helper is available on [Docker Hub](https://hub.docker.com/r/askanna/backup-helper):

```shell
docker pull askanna/backup-helper
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

### Google Cloud Storage configuration

| Environment variable | Required | Default            | Description                                                  |
| -------------------- | -------- | ------------------ | ------------------------------------------------------------ |
| `GCS_BUCKET`         | No       |                    | The Google Cloud Storage Bucket you want to upload the backup files to or download them from<br>&nbsp;<br>This variable is required if you want to use the Backup Helper to upload files to or download from Google Cloud Storage. |
| `GCS_KEY_FILE_PATH`      | No      | `/keys/gcs-key.json` | The path where the GCS service account key file will be mounted.<br>&nbsp;<br>This variable is required if you want to use the Backup Helper to upload files to or download from Google Cloud Storage. |

#### GCS service account key file

To use the Google Cloud Storage features, you need to have a Google service account or
[create a new service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account).
To authenticate, you need to have the associated private JSON key of the service account or
[create a new service account JSON key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

## Daily backup

There is a backup, upload and clean script in this image's directory `/etc/periodic/daily`. This backup script run the
following commands:

- gcs_upload
- backup_clean
- backup_postgres
- backup_files
- gcs_upload

When you start the image, the daily backup is not scheduled because the cron daemon is not started by default. When
you run the image with the command `crond -f` it will start the cron daemon and schedule the daily backup. See also
['How we use it'](#how-we-use-it).

## How we use it

We use the Backup Helper for the AskAnna project that we run as a Docker Stack. In our
[Docker Compose](https://docs.docker.com/compose/) file we have a service named `backup-helper`:

```docker
backup_helper:
  image: askanna/backup-helper
  command: crond -f
  volumes:
    - backup_volume:/backups
    - storage_volume:/data
    - ../gcs-key.json:/keys/gcs-key.json:ro
  env_file:
    - ./postgres.env
  environment:
      GCS_BUCKET: <Google Cloud Storage Bucket name>
```

With the Backup Helper available as a service in the Docker Stack, we can perform backup tasks. Depending on the
backup task, we run one or multiple of the commands below.

> If you don't want to schedule a daily backup, remove the line `command: crond -f`.

## Make backup

### Backup PostgreSQL

```shell
docker-compose run --rm backup_helper backup_postgres
```

### Backup files

```shell
docker-compose run --rm backup_helper backup_files
```

## List backups

```shell
docker-compose run --rm backup_helper backup_ls
```

## Restore backup

### Restore PostgreSQL

```shell
docker-compose run --rm backup_helper restore_postgres <backup file>
```

### Restore files

```shell
docker-compose run --rm backup_helper restore_files <backup file>
```

## Clean backups

```shell
docker-compose run --rm backup_helper backup_clean
```

## Google Cloud Storage

### Upload backup

```shell
docker-compose run --rm backup_helper gcs_upload
```

### Download backup

```shell
docker-compose run --rm backup_helper gcs_download <backup file>
```

### List backups on GCS

```shell
docker-compose run --rm backup_helper gcs_ls
```

## Credits

The Backup Helper is inspired by [cookiecutter/cookiecutter-django](https://github.com/cookiecutter/cookiecutter-django) and [diogopms/postgres-gcs-backup](https://github.com/diogopms/postgres-gcs-backup).
