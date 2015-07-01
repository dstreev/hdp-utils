# This script needs to be run as the HDFS user.

HDFS_USER=$1

hdfs dfs -mkdir /user/${HDFS_USER}
hdfs dfs -chown -R ${HDFS_USER} /user/${HDFS_USER}

