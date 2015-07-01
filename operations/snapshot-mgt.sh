#!/bin/bash

## Manage snapshots for automated backup and recover processes

## Options
## Take Snapshot
## Remove Snapshots Older than
## Restore Snapshot (-replace option)

while [ $# -gt 0 ]; do
  case "$1" in
    --take)
      shift
      ACTION="TAKE"
      TARGET_DIR=$1
      shift
      ;;
    --remove)
      shift
      ACTION="REMOVE"
      TARGET_DIR=$1
      shift
      ;;
    --restore)
      shift
      ACTION="RESTORE"
      TARGET_DIR=$1
      shift
      ;;
    --replace)
      REPLACE="YES"
      shift
      ;;
    --snapshot-name)
      shift
      SNAPSHOT_NAME=$1
      shift
      ;;
    --older-than)
      shift
      OLDER_THAN=$1
      shift
      ;;
    --help)
      echo "Usage: $0 (--take <target-directory>|--remove <target-directory> [--older-than]|--restore <target-directory> --snapshot-name <snapshot-name> [--replace])"
      exit -1
      ;;
    *)
      break
      ;;
  esac
done

# Things to check for..
# Is directory snapshotable for this user?
# hdfs lsSnapshottableDir

exec< <(hdfs lsSnapshottableDir)

    #exec< ${DIR_LIST}

    while read line ; do


case "$ACTION" in
    TAKE)


        ;;
    REMOVE)

        ;;
    RESTORE)

        ;;
esac
