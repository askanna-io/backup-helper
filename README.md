# Backup Helper

The Backup Helper aims to help you make and restore backups of your project files and PostgreSQL database.
Also, you can upload and download backup files to Google Cloud Storage.

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
| `BACKUP_KEEP_DAYS`   | No       | `7`                | The number of days you want to keep local backup files. The Backup Helper only removes local backup files when you run `backup_clean`. |

### PostgreSQL configuration

| Environment variable | Required | Default            | Description                                                  |
| -------------------- | -------- | ------------------ | ------------------------------------------------------------ |
| `POSTGRES_HOST`      | No       | `localhost`        | The PostgreSQL database server host                          |
| `POSTGRES_PORT`      | No       | `5432`             | The PostgreSQL database server port                          |
| `POSTGRES_DB`        | No       |                    | The database to backup. By default, the Backup Helper makes a backup of all the databases. |
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

## How we use it

We use the Backup Helper for the AskAnna project that we run as a Docker Stack. In our
[Docker Compose](https://docs.docker.com/compose/) file we have a service named `backup_helper`:

```docker
backup_helper:
  image: askanna/backup-helper
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
