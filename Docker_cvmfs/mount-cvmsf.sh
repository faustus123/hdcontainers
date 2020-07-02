#!/bin/bash
#set -e

# This is used to install the fuse module and mount the CVMFS
# share. This can't be done when the image is built so is deferred
# to here.

if [ "$@" == "get_dsh" ]; then

	cat /container/dsh
	exit 0
fi

if [ ! -f /dev/fuse ]; then
	yum -y install fuse
	chmod 666 /dev/fuse
	mount -t cvmfs oasis.opensciencegrid.org /cvmfs/oasis.opensciencegrid.org
fi

exec "$@"
