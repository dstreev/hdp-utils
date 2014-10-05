#!/bin/sh

# Command Line params

# ACTUAL at this time:
# $1 = Interval Days to remove.
DAY_ARCHIVE_THRESHOLD=$1

#!/bin/bash

# Cleaning hadoop logs older than 30 days in all hadoop related folders on /var/log

LOG_BASE=/var/log

COMPONENTS="accumulo ambari-agent ambari-server falcon hadoop hadoop-hdfs hadoop-mapreduce hadoop-yarn hbase hive hive-cataglog hue knox nagios oozie storm webhcat zookeeper"

echo "Reviewing Logs for $COMPONENTS"
for i in $COMPONENTS; do
    if [ -d $LOG_BASE/$i ]; then
            echo "Removing logs for $LOG_BASE/$i that are $DAY_ARCHIVE_THRESHOLD (or more) days old"
            find $LOG_BASE/$i -mtime +$DAY_ARCHIVE_THRESHOLD -exec rm -f {} \;
        popd
    else
        echo "Component $i logs not found on this server"
    fi
done

# Cleanup OS Components
OS_COMPONENTS="messages maillog secure spooler"
for i in $OS_COMPONENTS; do
    if [ -d $LOG_BASE/$i ]; then
            echo "Removing logs for $LOG_BASE/$i that are $DAY_ARCHIVE_THRESHOLD (or more) days old"
            find $LOG_BASE/$i-* -mtime +$DAY_ARCHIVE_THRESHOLD -exec rm -f {} \;
        popd
    else
        echo "Component $i logs not found on this server"
    fi
done

