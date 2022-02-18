# Backup Helper


# Backup postgresql
docker-compose run backup_helper backup

# Backup django USG
docker-compose run -e BACKUP_SOURCE=/data backup_helper backup_django_usg


# List backups
docker-compose run backup_helper backups

# Restore Postgresql backup
docker-compose run backup_helper restore <backup file>

# Restore Django USG backup
docker-compose run -e BACKUP_SOURCE=/data backup_helper restore_django_usg <backup file>
