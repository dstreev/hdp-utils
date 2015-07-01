# This script needs to be run as the HDFS user.

HDFS_USER=$1

hdfs dfs -mkdir /user/${HDFS_USER}/private.db
hdfs dfs -chown -R ${HDFS_USER} /user/${HDFS_USER}

echo "You need to give 'hive' rwx permissions to /user/${HDFS_USER}/private.db"
echo ""
echo "That can be done through Ranger HDFS Repo OR through Extended HDFS ACL's"
