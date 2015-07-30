# Deploy the base files to start the installation.
while [ $# -gt 0 ]; do
  case "$1" in
    --group)
      shift
      PDSH_GROUP=$1
      shift
      ;;
    --ambari-host)
      shift
      AMBARI_MASTER=$1
      shift
      ;;
    --cluster-name)
      shift
      CLUSTER=$1
      shift
      ;;    
    --help)
      echo "Usage: $0 --group <pdsh group file> --ambari-host <host> --cluster-name <ambari cluster name>"
      exit -1
      ;;
    *)
      break
      ;;
  esac
done

if [ "${PDSH_GROUP} == "" ]; then
      echo "Usage: $0 --group <pdsh group file> --ambari-host <host> --cluster-name <ambari cluster name>"
      exit -1
fi

if [ "${CLUSTER} == "" ]; then
      echo "Usage: $0 --group <pdsh group file> --ambari-host <host> --cluster-name <ambari cluster name>"
      exit -1
fi

if [ "${AMBARI_MASTER} == "" ]; then
      echo "Usage: $0 --group <pdsh group file> --ambari-host <host> --cluster-name <ambari cluster name>"
      exit -1
fi


pdsh -g ${PDHS_GROUP} 'rm -rf /etc/yum.repos.d/ambari*'

# TODO: You'll need to adjust for your repo.
pdsh -g ${PDHS_GROUP} 'wget -nv http://m1.hdp.local/repos/ambari/centos6/2.x/updates/2.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo'
# pdsh -g ${PDHS_GROUP} 'wget -nv http://m1.hdp.local/repos/HDP-UTILS-1.1.0.20/repos/centos6/hdp-util.repo -O /etc/yum.repos.d/hdp-util.repo'

pdsh -g ${PDHS_GROUP} 'yum clean all'

pdsh -g ${PDHS_GROUP} 'yum -y install ambari-agent'

pdsh -w ${AMBARI_MASTER} 'yum -y install ambari-server'

# When pdcp isn't available.
# TODO: You'll need to adjust with your list of servers.
# The referenced ambari-agent.ini has already been configured for this target cluster.
for i in m1 m2 d1 d2 d3 d4 d5; do
scp ../${CLUSTER}/ambari-agent.ini ${i}:/etc/ambari-agent/conf
done
