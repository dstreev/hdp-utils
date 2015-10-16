#!/bin/bash

# Should be run on the MySQL Server as the root db user.

# Adjust values to match your cluster configuration.
MYSQL_ROOT_USER=root
MYSQL_ROOT_PASSWORD=hadoop

HIVE_DB=hive
HIVE_USER=hive
HIVE_USER_PASSWORD=hive

AMBARI_DB=ambari
AMBARI_USER=ambari
AMBARI_USER_PASSWORD=ambari

OOZIE_DB=oozie
OOZIE_USER=oozie
OOZIE_USER_PASSWORD=oozie

RANGER_DB=ranger
RANGER_USER=ranger
RANGER_USER_PASSWORD=ranger

RANGER_AUDIT_DB=ranger_audit
RANGER_AUDIT_USER=ranger_audit
RANGER_AUDIT_USER_PASSWORD=ranger

RANGER_KMS_DB=ranger_kms
RANGER_KMS_USER=ranger_kms
RANGER_KMS_USER_PASSWORD=ranger

# ALL HOSTS SHOULD contain localhost
AMBARI_HOSTS="% localhost m1.hdp.local"
HIVE_HOSTS="% localhost m1.hdp.local m2.hdp.local m3.hdp.local"
RANGER_HOSTS="% localhost m1.hdp.local m2.hdp.local m3.hdp.local d1.hdp.local d2.hdp.local d3.hdp.local d4.hdp.local"
OOZIE_HOSTS="% localhost m1.hdp.local m2.hdp.local m3.hdp.local"


RUN_DROP_SCRIPT=/tmp/hdp_drop_mysql_users.sql
echo "" > $RUN_DROP_SCRIPT
for i in $(eval echo ${AMBARI_HOSTS}); do
    echo "DROP USER '${AMBARI_USER}'@'${i}';" >> $RUN_DROP_SCRIPT
done
for i in $(eval echo ${HIVE_HOSTS}); do
    echo "DROP USER '${HIVE_USER}'@'${i}';" >> $RUN_DROP_SCRIPT
done
for i in $(eval echo ${OOZIE_HOSTS}); do
    echo "DROP USER '${OOZIE_USER}'@'${i}';" >> $RUN_DROP_SCRIPT
done
for i in $(eval echo ${RANGER_HOSTS}); do
    echo "DROP USER '${RANGER_USER}'@'${i}';" >> $RUN_DROP_SCRIPT
    echo "DROP USER '${RANGER_AUDIT_USER}'@'${i}';" >> $RUN_DROP_SCRIPT
    echo "DROP USER '${RANGER_KMS_USER}'@'${i}';" >> $RUN_DROP_SCRIPT
done

RUN_SCRIPT=/tmp/hdp_create_mysql_users.sql

# Ambari DB
echo "" > $RUN_SCRIPT
echo "CREATE DATABASE IF NOT EXISTS ${AMBARI_DB};" > $RUN_SCRIPT
for i in $(eval echo ${AMBARI_HOSTS}); do
echo "CREATE USER '${AMBARI_USER}'@'${i}' IDENTIFIED BY '${AMBARI_USER_PASSWORD}';" >> $RUN_SCRIPT
echo "GRANT ALL PRIVILEGES ON ${AMBARI_DB}.* TO '${AMBARI_USER}'@'${i}';" >> $RUN_SCRIPT
done

# Hive DB
echo "CREATE DATABASE IF NOT EXISTS ${HIVE_DB};" >> $RUN_SCRIPT
for i in $(eval echo ${HIVE_HOSTS}); do
echo "CREATE USER '${HIVE_USER}'@'${i}' IDENTIFIED BY '${HIVE_USER_PASSWORD}';" >> $RUN_SCRIPT
echo "GRANT ALL PRIVILEGES ON ${HIVE_DB}.* TO '${HIVE_USER}'@'${i}';" >> $RUN_SCRIPT
done

# Oozie DB
echo "CREATE DATABASE IF NOT EXISTS ${OOZIE_DB};" >> $RUN_SCRIPT
for i in $(eval echo ${OOZIE_HOSTS}); do
echo "CREATE USER '${OOZIE_USER}'@'${i}' IDENTIFIED BY '${OOZIE_USER_PASSWORD}';" >> $RUN_SCRIPT
echo "GRANT ALL PRIVILEGES ON ${OOZIE_DB}.* TO '${OOZIE_USER}'@'${i}';" >> $RUN_SCRIPT
done

# Ranger DB
echo "CREATE DATABASE IF NOT EXISTS ${RANGER_DB};" >> $RUN_SCRIPT
for i in $(eval echo ${RANGER_HOSTS}); do
echo "CREATE USER '${RANGER_USER}'@'${i}' IDENTIFIED BY '${RANGER_USER_PASSWORD}';" >> $RUN_SCRIPT
echo "GRANT ALL PRIVILEGES ON ${RANGER_DB}.* TO '${RANGER_USER}'@'${i}' WITH GRANT OPTION;" >> $RUN_SCRIPT
done

# Ranger Audit DB
echo "CREATE DATABASE IF NOT EXISTS ${RANGER_AUDIT_DB};" >> $RUN_SCRIPT
for i in $(eval echo ${RANGER_HOSTS}); do
echo "CREATE USER '${RANGER_AUDIT_USER}'@'${i}' IDENTIFIED BY '${RANGER_AUDIT_USER_PASSWORD}';" >> $RUN_SCRIPT
echo "GRANT ALL PRIVILEGES ON ${RANGER_AUDIT_DB}.* TO '${RANGER_AUDIT_USER}'@'${i}' WITH GRANT OPTION;" >> $RUN_SCRIPT
done

# Ranger KMS DB
echo "CREATE DATABASE IF NOT EXISTS ${RANGER_KMS_DB};" >> $RUN_SCRIPT
for i in $(eval echo ${RANGER_HOSTS}); do
echo "CREATE USER '${RANGER_KMS_USER}'@'${i}' IDENTIFIED BY '${RANGER_KMS_USER_PASSWORD}';" >> $RUN_SCRIPT
echo "GRANT ALL PRIVILEGES ON ${RANGER_KMS_DB}.* TO '${RANGER_KMS_USER}'@'${i}' WITH GRANT OPTION;" >> $RUN_SCRIPT
done

echo "User DROP Script created: ${RUN_DROP_SCRIPT}"
echo "User and Database Create script created: ${RUN_SCRIPT}"

