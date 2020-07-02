#--------------------------------------------------------------------------
# sim-recon
# 
# This Dockerfile will produce an image based on the one used for running
# at NERSC, PSC, and the OSG, but which can also be used to mount CVMFS
# using any computer. The main use case is to provide a simple way to
# mount and run software from /group/halld/Software on you local laptop
# or desktop.
#
# To use this most effectively:
#
#      docker pull jeffersonlab/gluex-cvmfs
#      docker run -it --rm jeffersonlab/gluex-cvmfs get_dsh | tr -d "\r" > dsh
#      chmod +x ./dsh
#      ./dsh jeffersonlab/gluex-cvmfs
#
#--------------------------------------------------------------------------
#
# Build time: 
# Image size: 
#
#   docker build -t gluex-cvmfs -t jeffersonlab/gluex-cvmfs .
#
#--------------------------------------------------------------------------

FROM markito3/gluex_docker_devel


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install packages needed to mount CVMFS directory.
#
# Note that we can't install everything here since the fuse module
# must be installed at run time in the container. We do install the
# CVMFS software here though and set up the configuration file.
#
# Install git and then use that to grab the latest gluex_install scripts.
# Then, use those to build the gluex software
#
RUN yum -y install https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm \
	&& yum -y install cvmfs cvmfs-config-default \
	&& echo "CVMFS_HTTP_PROXY=DIRECT" | tee -a /etc/cvmfs/default.local \
	&& echo "======== Cleaning up ... =========" \
	&& rm -rf /var/cache/yum

COPY mount-cvmsf.sh /usr/local/bin/
COPY dsh /container/dsh
COPY Dockerfile /container/Dockerfile
RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat
RUN ln -s /root /home/root
RUN ln -s /root /home/0

ENTRYPOINT ["mount-cvmsf.sh"]
CMD ["/bin/bash"]
