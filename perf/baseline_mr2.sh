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
#   - Node Count
#   - Memory Footprint per Node
#   - base directory (hdfs) for files.
#
#
# Running this script:
#  :>nohup ./<script> > results.out &
#  :>tail -f results.out
# This will log the script output to a file for safe keeping.  The results should be saved.
################################################################################################
# 1TB across 1000 mappers with create 1G part files


HDP_VER=2.4.0.2.1.3.0-563
BASE_DIR=./perf
# 1TB (1099511627776 bytes)/100 (bytes per record in Teragen)
TB_ROWS=10995116278

# Make adjustments based on your cluster. Containers * Nodes...
TERAGEN_MAPPERS=5390
TERASORT_REDUCERS=3000

MR_EXAMPLES_JAR=/usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples-$HDP_VER.jar

if [ ! -f $MR_EXAMPLES_JAR ]; then
	echo "Couldn't find jar file with teragen/sort: $MR_EXAMPLES_JAR"
	exit -1
fi

ROW_COUNT=$TB_ROWS
#ROW_COUNT=100000

hdfs dfs -mkdir $BASE_DIR

# MR Parameter Keys
# MR1
# MAPPER_COUNT_KEY=mapred.map.tasks
# RECUDER_COUNT_KEY=mapred.reduce.tasks
# DFS_BLOCK_SIZE_KEY=dfs.block.size

# MR2
MAPPER_COUNT_KEY=mapreduce.job.maps
RECUDER_COUNT_KEY=mapreduce.job.reduces
DFS_BLOCK_SIZE_KEY=dfs.blocksize

# Using powers of 2 to establish 64M - 1G Blocksize attempts.
for bsp in 26 27 28 29 30; do
	DFS_BLOCK_SIZE=`echo "2^$bsp" | bc`
	echo "BLOCK SIZE: $DFS_BLOCK_SIZE"
	
	hdfs dfs -rm -r -skipTrash $BASE_DIR/teragen_$bsp

	hadoop jar $MR_EXAMPLES_JAR teragen -D$DFS_BLOCK_SIZE_KEY=$DFS_BLOCK_SIZE -D$MAPPER_COUNT_KEY=$TERAGEN_MAPPERS $ROW_COUNT $BASE_DIR/teragen_$bsp 2>&1

	hdfs dfs -rm -r -skipTrash $BASE_DIR/terasort_$bsp

	hadoop jar $MR_EXAMPLES_JAR terasort -D$RECUDER_COUNT_KEY=$TERASORT_REDUCERS $BASE_DIR/teragen_$bsp $BASE_DIR/terasort_$bsp 2>&1
done
