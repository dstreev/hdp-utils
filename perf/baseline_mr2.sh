#!/bin/bash

################################################################################################
#
# Use this to establish a baseline for a cluster by running a variety of Teragen/sort processes.
#
# With the input parameters, the script will make some basic calculations to determine a good
# load profile that can will utilize the cluster to its fullest potential.  In order for these
# tests to perform consistently, we're making the assumption that the cluster will be FULLY
# available for the tests.
#
# Input parameters: (TODO's)
#   - Size in Mb, Gb or Tb
#   - Mappers
#   - Reducers
#
# Running this script:
#  :>nohup ./<script> --size <..> > results.out &
#  :>tail -f results.out
# This will log the script output to a file for safe keeping.  The results should be saved.
################################################################################################
# 1TB across 1000 mappers with create 1G part files

SIZE=1Tb

# Make adjustments based on your cluster. Containers * Nodes...

#Defaults
# 2048 Mappers will generate 512Mb Files
# 1024 Mappers will generate 1Gb Files
TERAGEN_MAPPERS=1024

# Estimates
# 8192 Reducers will sort 128Mb
# 4096 Reducers will sort 256Mb
# 2048 Reducers will sort 512Mb
TERASORT_REDUCERS=4096

while [ $# -gt 0 ]; do
  case "$1" in
    --size)
      shift
      SIZE=$1
      shift
      ;;
    --mappers)
      shift
      TERAGEN_MAPPERS=$1
      shift
      ;;
    --reducers)
      shift
      TERASORT_REDUCERS=$1
      shift
      ;;
    --help)
      echo "Usage: $0 --size <size in GB or TB 1Tb or 500Gb or 50Mb> --mappers <number of mappers for teragen> --reducers <number of reducers for sort>"
      exit -1
      ;;
    *)
      break
      ;;
  esac
done

echo "Running with... Size=${SIZE} , Mappers=${TERAGEN_MAPPERS} , Reducers=${TERASORT_REDUCERS}"

VALUE=""
MULTIPLIER=""

if [[ "$SIZE" =~ "Mb" ]]; then
#   echo "In Megabytes!"
  MULTIPLIER=2
  VALUE=`echo $SIZE | awk -F'Mb' '{print $1}'`
fi

if [[ "$SIZE" =~ "Gb" ]]; then
#   echo "In Gigabytes!"
  MULTIPLIER=3
  VALUE=`echo $SIZE | awk -F'Gb' '{print $1}'`
fi

if [[ "$SIZE" =~ "Tb" ]]; then
#   echo "In Terabytes!"
  MULTIPLIER=4
  VALUE=`echo $SIZE | awk -F'Tb' '{print $1}'`
fi

if [ "${VALUE}" == "" ]; then
    echo "Unable to determine size.  Use Mb, Gb or Tb.  IE: 500Mb or 36Gb or 1Tb"
    echo "Usage: $0 --size <size in GB or TB 1Tb or 500Gb or 50Mb> --mappers <number of mappers for teragen> --reducers <number of reducers for sort>"
    exit -1
fi

BASE_DIR=./perf

# Convert Size to Teragen Rows.
GEN_ROWS=`echo "($VALUE*1024^$MULTIPLIER)/100" | bc`

LC_NUMERIC=en_US
GEN_ROWS_COUNT=`printf "%'.f\n" ${GEN_ROWS}`

echo "TeraGen/Sort Rows: ${GEN_ROWS_COUNT}"

MR_EXAMPLES_JAR=/usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples.jar

if [ ! -f $MR_EXAMPLES_JAR ]; then
	echo "Couldn't find jar file with teragen/sort: $MR_EXAMPLES_JAR"
	exit -1
fi

hdfs dfs -mkdir $BASE_DIR

# MR2
MAPPER_COUNT_KEY=mapreduce.job.maps
RECUDER_COUNT_KEY=mapreduce.job.reduces
DFS_BLOCK_SIZE_KEY=dfs.blocksize

# Using powers of 2 to establish 64M - 1G Blocksize attempts.
# 26 = 64M
# 27 = 128M
# 28 = 256M
# 29 = 512M
# 30 = 1GB
for bsp in 27; do
# for bsp in 26 27 28 29 30; do
	DFS_BLOCK_SIZE=`echo "2^$bsp" | bc`
	echo "BLOCK SIZE: $DFS_BLOCK_SIZE"
	
	hdfs dfs -rm -r -skipTrash $BASE_DIR/teragen_$bsp

	hadoop jar $MR_EXAMPLES_JAR teragen -D$DFS_BLOCK_SIZE_KEY=$DFS_BLOCK_SIZE -D$MAPPER_COUNT_KEY=$TERAGEN_MAPPERS $GEN_ROWS $BASE_DIR/teragen_$bsp 2>&1

	hdfs dfs -rm -r -skipTrash $BASE_DIR/terasort_$bsp

	hadoop jar $MR_EXAMPLES_JAR terasort -D$RECUDER_COUNT_KEY=$TERASORT_REDUCERS $BASE_DIR/teragen_$bsp $BASE_DIR/terasort_$bsp 2>&1
done
