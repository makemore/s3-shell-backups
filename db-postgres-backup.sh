#!/bin/sh

#### BEGIN CONFIGURATION ####

NOWDATE=`date +%Y-%m-%d`
LASTDATE=$(date +%Y-%m-%d --date='1 week ago')

backup_folder="../db_backups/"
#declare -a databases=("crossover" "flik" "angels")

HOST='127.0.0.1'
PORT='5432'
USER='chris'

SRCDIR='/tmp/s3backups'
DESTDIR='databases'
BUCKET='mmd-backups'

#### END CONFIGURATION ####
#http://stackoverflow.com/questions/2424921/python-vs-bash-in-which-kind-of-tasks-each-one-outruns-the-other-performance-w

mkdir -p $backup_folder



DBLIST=`psql -l -h$HOST -p$PORT -U$USER \
  | awk '{print $1}' | grep -v "+" | grep -v "Name" | \
  grep -v "List" | grep -v "(" | grep -v "template" | \
  grep -v "postgres" | grep -v "root" | grep -v "|" | grep -v "|"`

#for db in ${databases[@]}
for db in ${DBLIST}
do
        echo $db
        pg_dump -h$HOST -p$PORT -U$USER -w $db -f $backup_folder/$db.sql
	tar -czPf $backup_folder/$NOWDATE-$db.sql.tar.gz $backup_folder/$db.sql
	s3cmd -c .s3cfg put $backup_folder/$NOWDATE-$db.sql.tar.gz s3://$BUCKET/$DESTDIR/$db/
	s3cmd -c .s3cfg del --recursive s3://$BUCKET/$DESTDIR/$LASTDATE-$db.sql.tar.gz
	rm $backup_folder/$NOWDATE-$db.sql.tar.gz
done
