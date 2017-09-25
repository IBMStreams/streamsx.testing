#! /bin/bash
# Test script to use the cpu $1 seconds and print out id $2
set -o errexit; set -o nounset;

echo "Start specialperf $2 use $1 seconds"
echo "--------"
trap -p
echo '--------'

trap -l

trap 'echo int rec' SIGINT

myId="$2"
myDuration="$1"

t1=$(date +'%-s')
t2=$((t1 + myDuration))
tx=0
while ((tx < t2)); do
    x=100000;
    while let x=x-1; do
        #echo $x
        #let x=x-1;
        :
    done;
    #echo "******* "
    tx=$(date +'%-s')
    #echo $tx
done

echo "END $myId"

exit 0