#!/bin/bash

if [ "$#" -ne 2 ]
then
    echo "archivetos3.sh usage:  <s3_bucket> <archive_find_prefix>"
    exit 1
fi

S3_BUCKET=$1
ARCHIVE_FIND_PATTERN="${2}*.gz"
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`


log_line () {
    CURRENT_TIME=`date`
    echo "$CURRENT_TIME - $1"
}


log_line "starting archive"
ARCHIVE_FILES=`find $ARCHIVE_FIND_PATTERN -type f`
for archive in $ARCHIVE_FILES
do
    ARCHIVE_BASE_NAME=`basename $archive`
    ARCHIVE_DIR_NAME=`dirname $archive`
    S3_LOCATION_URL="s3://${S3_BUCKET}${ARCHIVE_DIR_NAME}/${INSTANCE_ID}-${ARCHIVE_BASE_NAME}"
    log_line "Archiving $archive to $S3_LOCATION_URL"
    aws s3 cp --quiet $archive $S3_LOCATION_URL
    if [ "$?" -ne 0 ]
    then
        log_line "Failed to archive $archive to $S3_LOCATION_URL ... skipping deletion"
    else
        log_line "deleting archive $archive"
        rm -f $archive
    fi
done

log_line "finished archive"
