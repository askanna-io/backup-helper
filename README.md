# Backup Helper

## Backup PostgreSQL

```shell
docker-compose run --rm backup_helper backup
```

## Backup Django USG

```shell
docker-compose run --rm -e BACKUP_SOURCE=/data backup_helper backup_django_usg
```

## List backups

```shell
docker-compose run --rm backup_helper backups
```

## Restore PostgreSQL backup

```shell
docker-compose run --rm backup_helper restore <backup file>
```

## Restore Django USG backup

```bash
docker-compose run --rm -e BACKUP_SOURCE=/data backup_helper restore_django_usg <backup file>
```
