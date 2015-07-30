# Clean sweep.  Reset / Prep for Cluster Rebuild.

cd `dirname $0`

# Warning: This is a destructive process at some point because it will remove data directories and content.

while [ $# -gt 0 ]; do
  case "$1" in
    --group)
      shift
      PDSH_GROUP=$1
      shift
      ;;
    --help)
      echo "Usage: $0 --group <pdsh group file>"
      exit -1
      ;;
    *)
      break
      ;;
  esac
done

if [ "${PDSH_GROUP} == "" ]; then
      echo "Usage: $0 --group <pdsh group file>"
      exit -1
fi

# Directories to remove

CFG_DIRS=etc_dir.txt
YUM_PACKAGES=yum_packages.txt
DATA_LOG_DIRS=data_log_dirs.txt

# Will require pdsh on ALL targeted Hosts.
pdcp -g ${PDSH_GROUP} -e /usr/bin/pdcp ${CFG_DIRS} /tmp
pdcp -g ${PDSH_GROUP} -e /usr/bin/pdcp ${YUM_PACKAGES} /tmp
pdcp -g ${PDSH_GROUP} -e /usr/bin/pdcp ${DATA_LOG_DIRS} /tmp

pdsh -g ${PDSH_GROUP} 'for i in `cat /tmp/yum_packages.txt`;do yum -y erase "${i}";done'

pdsh -g ${PDSH_GROUP} 'for i in `cat /tmp/etc_dir.txt`;do rm -rf ${i};done'

pdsh -g ${PDSH_GROUP} 'for i in `cat /tmp/data_log_dirs.txt`;do rm -rf ${i};done'

pdsh -g ${PDSH_GROUP} 'yum clean all'