#!/bin/bash

# Configuration
BACKUP_DIR="/chemin/vers/le/dossier/de/sauvegarde"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
MYSQL_USER="root"
MYSQL_PASSWORD="votre_mot_de_passe"
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
DOCKER_MYSQL_CONTAINER="nom_du_conteneur_mysql"  # Nom du conteneur MySQL
MYSQL_DATA_DIR="/var/lib/mysql"  # Répertoire des données MySQL dans le conteneur

# Créer le répertoire de sauvegarde local si nécessaire
mkdir -p "$BACKUP_DIR"

# Exécuter la sauvegarde avec Percona XtraBackup dans un conteneur temporaire
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

# Optionnel : Compresser la sauvegarde
# tar -czvf "$BACKUP_DIR/backup_$BACKUP_DATE.tar.gz" "$BACKUP_DIR/backup_$BACKUP_DATE"

echo "Sauvegarde terminée : $BACKUP_DIR/backup_$BACKUP_DATE"
*


#!/bin/bash

# Configuration
BACKUP_DIR="/chemin/vers/votre/dossier/de/sauvegarde"
CONTAINER_NAME="nom_de_votre_conteneur_postgres"

# Obtenir le chemin PGDATA depuis le conteneur (exemple avec docker inspect)
PGDATA=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/postgresql/data" }}{{ .Source }} {{ end }}{{ end }}' $CONTAINER_NAME)

# Vérifier si PGDATA a été trouvé
if [[ -z "$PGDATA" ]]; then
    echo "Erreur : Impossible de trouver le chemin PGDATA dans le conteneur"
    exit 1
fi

#!/bin/bash

# Configuration (à adapter selon votre environnement)
BACKUP_DIR="/chemin/vers/votre/dossier/de/sauvegarde"
CONTAINER_NAME="nom_de_votre_conteneur_postgres"

# Obtenir le chemin PGDATA depuis le conteneur
PGDATA=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/postgresql/data" }}{{ .Source }} {{ end }}{{ end }}' $CONTAINER_NAME)

# Vérifier si PGDATA a été trouvé
if [[ -z "$PGDATA" ]]; then
    logger -t backup "Erreur : Impossible de trouver le chemin PGDATA dans le conteneur"
    exit 1
fi




# Date de la sauvegarde
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

# Exécuter la sauvegarde et enregistrer les logs
logger -t backup "Début de la sauvegarde"
docker exec -it $CONTAINER_NAME pg_basebackup \
  -D "$PGDATA" \
  -P \  # Sauvegarde parallèle
  -F t \  # Format tar
  -z 9 \  # Compression gzip niveau 9
  -v \  # Mode verbeux
  -X \  # Exclure les fichiers temporaires
  -D "$BACKUP_DIR/backup_$BACKUP_DATE"
if [ $? -eq 0 ]; then
  logger -t backup "Sauvegarde terminée avec succès : $BACKUP_DIR/backup_$BACKUP_DATE"
else
  logger -t backup "Erreur lors de la sauvegarde"
fi





#!/bin/bash

# Configuration (à adapter selon votre environnement)
BACKUP_DIR="/chemin/vers/votre/dossier/de/sauvegarde"
MYSQL_CONTAINER_NAME="nom_de_votre_conteneur_mysql"
MYSQL_USER="votre_utilisateur_mysql"
MYSQL_PASSWORD="votre_mot_de_passe"
MYSQL_HOST="localhost"
MYSQL_PORT="3306"

# Date de la sauvegarde
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

# Exécuter la sauvegarde et enregistrer les logs
logger -t backup "Début de la sauvegarde MySQL"
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
  logger -t backup "Sauvegarde MySQL terminée avec succès : $BACKUP_DIR/backup_$BACKUP_DATE"
else
  logger -t backup "Erreur lors de la sauvegarde MySQL"
fi