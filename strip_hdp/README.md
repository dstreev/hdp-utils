# Cluster Reset

It helps to have a script that allows you to quickly reset your cluster so it can be built again.

The [strip_hdp.sh](./strip_hdp.sh) script will is driven by three files that control the extent of the cleansing.

[etc_dir.txt](etc_dir.txt) lists all of the "configuration" folders that will be deleted.

[data_log_dirs.txt](data_log_dirs.txt) lists all of the DATA and log folders that will be REMOVED post the yum erase.

[yum_packages.txt](yum_packages.txt) lists all of the yum packages to be removed to reset the cluster.

# Cluster Prep

[prep.sh](prep.sh) is a template script I use to deploy the ambari repos and install the ambari-server and agents.