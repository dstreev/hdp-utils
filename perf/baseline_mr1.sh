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

BASE_DIR=./perf

# 1TB (1099511627776 bytes)/100 (bytes per record in Teragen)
TERABYTE_ROW_COUNT=10995116278

##############################
# ADJUST FOR YOUR CLUSTER
##############################
DATANODES=135
MAP_SLOTS_PER_NODE=12
REDUCE_SLOTS_PER_NODE=6

MR_EXAMPLES_JAR=/usr/lib/hadoop/hadoop-examples.jar

if [ ! -f $MR_EXAMPLES_JAR ]; then
	echo "Couldn't find jar file with teragen/sort: $MR_EXAMPLES_JAR"
	exit -1
fi

ROW_COUNT=$TERABYTE_ROW_COUNT
# ROW_COUNT=100000

hadoop fs -mkdir $BASE_DIR

# MR Parameter Keys
# MR1
MAPPER_COUNT_KEY=mapred.map.tasks
RECUDER_COUNT_KEY=mapred.reduce.tasks
DFS_BLOCK_SIZE_KEY=dfs.block.size

# NOTE: 1TB across 1000 mappers with create 1G part files
TERAGEN_MAPPERS=`echo "$DATANODES*$MAP_SLOTS_PER_NODE-5" | bc`
TERASORT_REDUCERS=`echo "$DATANODES*$REDUCE_SLOTS_PER_NODE-5" | bc`

# Using powers of 2 to establish 64M - 1G Blocksize attempts.
for bsp in 26 27 28 29 30; do
	DFS_BLOCK_SIZE=`echo "2^$bsp" | bc`
	echo "BLOCK SIZE: $DFS_BLOCK_SIZE"

	hadoop fs -rmr -skipTrash $BASE_DIR/teragen_$bsp

	hadoop jar $MR_EXAMPLES_JAR teragen -D$DFS_BLOCK_SIZE_KEY=$DFS_BLOCK_SIZE -D$MAPPER_COUNT_KEY=$TERAGEN_MAPPERS $ROW_COUNT $BASE_DIR/teragen_$bsp 2>&1

	hadoop fs -rmr -skipTrash $BASE_DIR/terasort_$bsp

	hadoop jar $MR_EXAMPLES_JAR terasort -D$RECUDER_COUNT_KEY=$TERASORT_REDUCERS $BASE_DIR/teragen_$bsp $BASE_DIR/terasort_$bsp 2>&1
done
