# Backup Helper

The Backup Helper aims to help you make and restore backups of your project files and PostgreSQL database. Also, you
can upload and download backup files to Google Cloud Storage.

We use the Backup Helper for the AskAnna project that we run as a Docker Stack. In our Docker Stack we have a service
named `backup_helper`:

```docker
backup_helper:
  image: askanna/backup-helper
  volumes:
    - backup_volume:/backups
    - storage_volume:/data
  env_file:
    - ./postgres.env
```

With the commands below, you can make and restore backups. And you can upload and download backups to Google Cloud
Storage.

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

## Google Cloud Storage

The following commands can be used to save or get a copy of a backup on Google Cloud Storage. Also, you can list the
backups that are saved on Google Cloud Storage.

To use the Google Cloud Storage features, you need to have a Google service account or
[create a new service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account).
To authenticate, you need to have the associated private JSON key of the service account or
[create a new service account JSON key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

### Upload backup

```shell
docker-compose run --rm -v <path to gcs-key.json>:/keys/gcs-key.json -e GCS_BUCKET=<gsc bucket name> backup_helper gcs_upload
```

### Download backup

```shell
docker-compose run --rm -v <path to gcs-key.json>:/keys/gcs-key.json -e GCS_BUCKET=<gsc bucket name> backup_helper gcs_download <backup file>
```

### List backups on GCS

```shell
docker-compose run --rm -v <path to gcs-key.json>:/keys/gcs-key.json -e GCS_BUCKET=<gsc bucket name> gcs_ls
```
