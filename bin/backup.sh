#!/bin/bash

BACKUP_DIR="/path/to/backup/directory"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
MYSQL_USER="root"
MYSQL_PASSWORD="your_password"
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
DOCKER_MYSQL_CONTAINER="mysql_container_name"  # MySQL container name
MYSQL_DATA_DIR="/var/lib/mysql"  # MySQL data directory inside the container

mkdir -p "$BACKUP_DIR"

# Run the backup with Percona XtraBackup in a temporary container
docker run --rm \
  --name percona-xtrabackup \
  --volumes-from "$DOCKER_MYSQL_CONTAINER" \
  -v "$BACKUP_DIR:/backup" \
  percona/percona-xtrabackup \
  --user="$MYSQL_USER" \
  --password="$MYSQL_PASSWORD" \
  --host="$MYSQL_HOST" \
  --port="$MYSQL_PORT" \
  --datadir="$MYSQL_DATA_DIR" \
  --backup \
  --target-dir="/backup/backup_$BACKUP_DATE"

# Optional: compress the backup
# tar -czvf "$BACKUP_DIR/backup_$BACKUP_DATE.tar.gz" "$BACKUP_DIR/backup_$BACKUP_DATE"

echo "Backup complete: $BACKUP_DIR/backup_$BACKUP_DATE"
*


#!/bin/bash

BACKUP_DIR="/path/to/your/backup/directory"
CONTAINER_NAME="your_postgres_container_name"

# Resolve the container's PGDATA mount (via docker inspect)
PGDATA=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/postgresql/data" }}{{ .Source }} {{ end }}{{ end }}' $CONTAINER_NAME)

if [[ -z "$PGDATA" ]]; then
    echo "Error: could not find PGDATA in the container"
    exit 1
fi

#!/bin/bash

BACKUP_DIR="/path/to/your/backup/directory"
CONTAINER_NAME="your_postgres_container_name"

# Resolve the container's PGDATA mount
PGDATA=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/postgresql/data" }}{{ .Source }} {{ end }}{{ end }}' $CONTAINER_NAME)

if [[ -z "$PGDATA" ]]; then
    logger -t backup "Error: could not find PGDATA in the container"
    exit 1
fi




BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

# Run the backup and log the outcome
logger -t backup "Backup started"
docker exec -it $CONTAINER_NAME pg_basebackup \
  -D "$PGDATA" \
  -P \  # parallel backup
  -F t \  # tar format
  -z 9 \  # gzip level 9
  -v \  # verbose
  -X \  # exclude temporary files
  -D "$BACKUP_DIR/backup_$BACKUP_DATE"
if [ $? -eq 0 ]; then
  logger -t backup "Backup completed: $BACKUP_DIR/backup_$BACKUP_DATE"
else
  logger -t backup "Backup failed"
fi




#!/bin/bash

BACKUP_DIR="/path/to/your/backup/directory"
MYSQL_CONTAINER_NAME="your_mysql_container"
MYSQL_USER="your_mysql_user"
MYSQL_PASSWORD="your_password"
MYSQL_HOST="localhost"
MYSQL_PORT="3306"

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

logger -t backup "MySQL backup started"
docker exec -it $MYSQL_CONTAINER_NAME innobackupex \
  --user=$MYSQL_USER \
  --password=$MYSQL_PASSWORD \
  --host=$MYSQL_HOST \
  --port=$MYSQL_PORT \
  --no-lock \
  --parallel=4 \
  --compress=zstd \
  --backup-dir="$BACKUP_DIR/backup_$BACKUP_DATE"

if [ $? -eq 0 ]; then
  logger -t backup "MySQL backup completed: $BACKUP_DIR/backup_$BACKUP_DATE"
else
  logger -t backup "MySQL backup failed"
fi
