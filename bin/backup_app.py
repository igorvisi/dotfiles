import os
import subprocess
from datetime import datetime, timedelta
from dotenv import load_dotenv
import shutil

# Charger les variables d'environnement depuis .env
load_dotenv()

# Configuration des variables
APPLICATION_NAME = os.getenv('APPLICATION_NAME')
DATABASE_TYPE = os.getenv('DATABASE_TYPE')

MYSQL_USER = os.getenv('MYSQL_USER')
MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD')
MYSQL_PORT = os.getenv('MYSQL_PORT', '3306')
MYSQL_HOST = os.getenv('MYSQL_HOST', 'localhost')

PG_USER = os.getenv('PG_USER')
PG_PASSWORD = os.getenv('PG_PASSWORD')
PG_PORT = os.getenv('PG_PORT', '5432')
PG_HOST = os.getenv('PG_HOST', 'localhost')
PG_DATABASE = os.getenv('PG_DATABASE')

FILES_DIR = os.getenv('FILES_DIR')
FILES_BACKUP_DIR = os.getenv('FILES_BACKUP_DIR')
BACKUP_DIR = os.getenv('BACKUP_DIR')

REMOTE_TYPE = os.getenv('REMOTE_TYPE')
REMOTE_URL = os.getenv('REMOTE_URL')
REMOTE_USER = os.getenv('REMOTE_USER')
REMOTE_PASS = os.getenv('REMOTE_PASS')
S3_BUCKET = os.getenv('S3_BUCKET')
S3_PATH = os.getenv('S3_PATH')

RETENTION_DAYS = int(os.getenv('RETENTION_DAYS', '7'))
LOG_FILE = os.getenv('LOG_FILE')

# Date actuelle pour horodatage
DATE = datetime.now().strftime("%Y%m%d_%H%M%S")

def log_message(message):
    """Écrit un message dans le fichier log"""
    with open(LOG_FILE, 'a') as log_file:
        log_file.write(f"{datetime.now()} - {message}\n")

def backup_files():
    """Sauvegarde des fichiers"""
    files_backup_file = f"{FILES_BACKUP_DIR}/{APPLICATION_NAME}_files_backup_{DATE}.tar.gz"
    command = f"tar -czf {files_backup_file} -C {FILES_DIR} ."
    try:
        subprocess.run(command, shell=True, check=True)
        size = os.path.getsize(files_backup_file)
        log_message(f"Sauvegarde des fichiers réussie: {files_backup_file} (taille: {size} octets)")
    except subprocess.CalledProcessError:
        log_message("Erreur lors de la sauvegarde des fichiers")

def backup_mysql():
    """Sauvegarde MySQL"""
    mysql_backup_file = f"{BACKUP_DIR}/{APPLICATION_NAME}_mysql_backup_{DATE}.sql.gz"
    command = f"mysqldump -h {MYSQL_HOST} -u {MYSQL_USER} -p{MYSQL_PASSWORD} -P {MYSQL_PORT} --all-databases | gzip > {mysql_backup_file}"
    try:
        subprocess.run(command, shell=True, check=True)
        size = os.path.getsize(mysql_backup_file)
        log_message(f"Sauvegarde MySQL réussie: {mysql_backup_file} (taille: {size} octets)")
    except subprocess.CalledProcessError:
        log_message("Erreur lors de la sauvegarde MySQL")

def backup_postgres():
    """Sauvegarde PostgreSQL"""
    pg_backup_file = f"{BACKUP_DIR}/{APPLICATION_NAME}_postgres_backup_{DATE}.sql.gz"
    command = f"PGPASSWORD={PG_PASSWORD} pg_dump -h {PG_HOST} -U {PG_USER} -p {PG_PORT} {PG_DATABASE} | gzip > {pg_backup_file}"
    try:
        subprocess.run(command, shell=True, check=True)
        size = os.path.getsize(pg_backup_file)
        log_message(f"Sauvegarde PostgreSQL réussie: {pg_backup_file} (taille: {size} octets)")
    except subprocess.CalledProcessError:
        log_message("Erreur lors de la sauvegarde PostgreSQL")

def transfer_backups():
    """Transfert les sauvegardes vers un serveur distant"""
    if REMOTE_TYPE == 'ssh':
        command = f"rsync -avz --remove-source-files {BACKUP_DIR}/* {REMOTE_USER}@{REMOTE_URL}"
        try:
            subprocess.run(command, shell=True, check=True)
            log_message("Transfert des sauvegardes vers l'espace distant réussi (SSH)")
        except subprocess.CalledProcessError:
            log_message("Erreur lors du transfert des sauvegardes (SSH)")
    
    elif REMOTE_TYPE == 'ftp':
        command = f"lftp -e 'mirror -R {BACKUP_DIR} {REMOTE_URL} && bye' -u {REMOTE_USER},{REMOTE_PASS} ftp://{REMOTE_URL}"
        try:
            subprocess.run(command, shell=True, check=True)
            log_message("Transfert des sauvegardes vers l'espace distant réussi (FTP)")
        except subprocess.CalledProcessError:
            log_message("Erreur lors du transfert des sauvegardes (FTP)")

    elif REMOTE_TYPE == 's3':
        for file in os.listdir(BACKUP_DIR):
            file_path = os.path.join(BACKUP_DIR, file)
            command = f"aws s3 cp {file_path} s3://{S3_BUCKET}/{S3_PATH}/"
            try:
                subprocess.run(command, shell=True, check=True)
                log_message(f"Transfert de {file} vers S3 réussi")
            except subprocess.CalledProcessError:
                log_message(f"Erreur lors du transfert de {file} vers S3")

def cleanup_old_backups():
    """Suppression des anciennes sauvegardes selon la période de rétention"""
    retention_period = datetime.now() - timedelta(days=RETENTION_DAYS)
    total_size = 0
    for filename in os.listdir(BACKUP_DIR):
        file_path = os.path.join(BACKUP_DIR, filename)
        if os.path.isfile(file_path) and filename.startswith(APPLICATION_NAME):
            file_time = datetime.fromtimestamp(os.path.getmtime(file_path))
            if file_time < retention_period:
                os.remove(file_path)
                log_message(f"Supprimé: {file_path}")
            else:
                total_size += os.path.getsize(file_path)
    
    log_message(f"Taille totale des sauvegardes retenues pour {APPLICATION_NAME}: {total_size} octets")

if __name__ == "__main__":
    if DATABASE_TYPE == 'mysql':
        backup_mysql()
    elif DATABASE_TYPE == 'postgres':
        backup_postgres()
    
    backup_files()
    transfer_backups()
    cleanup_old_backups()

