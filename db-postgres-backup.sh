#!/bin/sh

#### BEGIN CONFIGURATION ####

NOWDATE=`date +%Y-%m-%d`
LASTDATE=$(date +%Y-%m-%d --date='1 week ago')

backup_folder="../db_backups/"
declare -a databases=("crossover" "flik" "angels")

HOST='127.0.0.1'
PORT='5432'
USER='chris'

SRCDIR='/tmp/s3backups'
DESTDIR='databases'
BUCKET='mmd-backups'

#### END CONFIGURATION ####


mkdir -p $backup_folder


for db in ${databases[@]}
do
echo $db
pg_dump -h$HOST -p$PORT -U$USER $db -f $backup_folder/$db.sql
tar -czPf $backup_folder/$NOWDATE-$db.sql.tar.gz $backup_folder/$db.sql
	s3cmd -c .s3cfg put $backup_folder/$NOWDATE-$db.sql.tar.gz s3://$BUCKET/$DESTDIR/$db/
	s3cmd -c .s3cfg del --recursive s3://$BUCKET/$DESTDIR/$LASTDATE-$db.sql.tar.gz
	rm $backup_folder/$NOWDATE-$db.sql.tar.gz
done