#!/bin/sh

#### BEGIN CONFIGURATION ####

NOWDATE=`date +%Y-%m-%d`
LASTDATE=$(date +%Y-%m-%d --date='1 week ago')


declare -a folders=("/Users/chris/Projects/s3-shell-backups/media_example/")


DESTDIR='files'
BUCKET='mmd-backups'

#### END CONFIGURATION ####


for folder in ${folders[@]}
do
	#pg_dump -h$HOST -p$PORT -U$USER $db -f $backup_folder/$db.sql
	#tar -czPf $backup_folder/$NOWDATE-$db.sql.tar.gz $backup_folder/$db.sql
	s3cmd -c .s3cfg sync $folder s3://$BUCKET/$DESTDIR$folder
done