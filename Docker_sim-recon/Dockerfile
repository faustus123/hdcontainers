#--------------------------------------------------------------------------
# sim-recon
# 
# This Dockerfile will produce an image containing a full build of sim-recon
# software. This is done via the gluex_install repository on github which
# in turn, relies on build_scripts to do most of the heavy lifting. The
# resulting image will be quite large.
#
#  Due to the large size, the image will not be suitable for pushing out
# to Dockerhub. It can be used, however, to build a full set of binaries 
# suitable for running from a smaller image based on the same OS as this.
#
#--------------------------------------------------------------------------
#
# Build time: 
# Image size: 
#
#   docker build -t sim-recon:2.23 .
#
#--------------------------------------------------------------------------

FROM centos:7.4.1708

# Check https://halldweb.jlab.org/dist for available versions
ARG SIM_RECON_VERSION=https://halldweb.jlab.org/dist/version_2.23.xml


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Use gluex_install and build scripts to build all prerequistes and sim-recon
#
# Install git and then use that to grab the latest gluex_install scripts.
# Then, use those to build the gluex software
#
RUN yum install -y epel-release \
	&& yum install -y git cmake 3\
	&& ln -s /usr/bin/cmake3 /usr/local/bin/cmake \	
	&& mkdir /halld \
	&& cd /halld \
	&& echo "======== Downloading gluex_install scripts and installing prerequisties =========" \
	&& git clone https://github.com/jeffersonlab/gluex_install \
	&& cd gluex_install \
	&& ./gluex_prereqs_centos_7.sh \
	&& echo "======== Getting sim-recon version file =========" \
	&& cd /halld \
	&& mkdir -p gluex_top \
	&& wget --no-check-certificate -O gluex_top/version.xml $SIM_RECON_VERSION \
	&& export ROOT6_BUILD_OPTIONS=-j8 \
	&& ./gluex_install/gluex_install.sh \
	&& echo "======== Cleaning up ... =========" \
	&& rm -rf /var/cache/yum

CMD /bin/bash
