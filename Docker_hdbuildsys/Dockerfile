#--------------------------------------------------------------------------
# faustus123/hdbuildsys
# 
# This Dockerfile will build an image that contains a C++ compiler and other
# system installed packages suitable for building GlueX/Hall-D software.
# One should generally use it by mounting a directory from the host system in
# /gluex where the builds can be done.
#
#
#--------------------------------------------------------------------------
#
# Build time: 
# Image size: 
#
#   docker build -t hdbuildsys .
#
#
#--------------------------------------------------------------------------

FROM centos:7.4.1708

ARG BUILD_THREADS=8

ARG CLHEP_TAG=CLHEP_2_3_4_5

ENV BMS_OSNAME=Linux_CentOS7-x86_64-gcc4.8.5-cntr

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set up basic environment
RUN sed -i.bak 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf

RUN yum install -y epel-release && \
    yum install -y \
		bzip2-devel \
		cmake3 \
		file \
		gcc-c++ \
		gcc-gfortran \
		git \
		subversion \
		make \
		mysql-devel \
		python \
		python-devel \
		protobuf-c-devel \
		scons \
		sudo \
		tcsh \
		wget \
		which \
		expat-devel \
		libX11-devel \
		libXt-devel \
		libXmu-devel \
		libXrender-devel \
		libXpm-devel \
		libXft-devel \
		xerces-c-devel \
		xkeyboard-config \
	&& ln -s /usr/bin/cmake3 /usr/local/bin/cmake \
	&& rm -rf /var/cache/yum

RUN useradd -m -G wheel gx \
	&&  sed -i.bak 's/#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers


# Create a /gluex directory for mounting build directory from host
ENV GLUEX_TOP /gluex
RUN mkdir -p $GLUEX_TOP/$BMS_OSNAME \
	&& chmod -R 777 $GLUEX_TOP

ENV PATH ${PATH}:$GLUEX_TOP/$BMS_OSNAME/bin
ENV LD_LIBRARY_PATH $GLUEX_TOP/$BMS_OSNAME/lib

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add graphics support

RUN yum install -y \
		tigervnc-server \
		ghostscript-fonts \
		net-tools \
		glx-utils \
		python-websockify \
		xterm \
		nedit \
		psmisc \
		git \
		which \
		tcsh \
		chromium \
	&&	yum groupinstall -y 'KDE' 'X Window System' \
	&& rm -rf /var/cache/yum \
	&& git clone https://github.com/kanaka/noVNC.git /opt/noVNC \
	&& cd /opt/noVNC \
	&& ln -s vnc.html index.html \
	&& mkdir -p /container/utilities

# These define an alias and a script for easily starting up the
# servers from either bash or tcsh.
COPY xstart.csh /etc/profile.d
COPY xstart.sh /etc/profile.d
COPY xstart.sh /etc/profile
COPY xstart.sh /etc/bash.bashrc
COPY eic_xstart.sh /container/utilities
COPY eic_xstart.csh /container/utilities
COPY xstop /usr/bin

# The following is only informational and does not automatically
# expose the ports to outside of the container. The user should
# use either the -p or -P options when running docker run. Usually,
# it will be easiest to use:
#
# docker run -p 6080:6080 -p 5900:5900 jleic:1.0.0
#
EXPOSE 6080 5900

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup to mount cvmfs inside container
#
# To actually mount cvmfs, the container needs to be run with the --privileged option.
# Do this once inside the container
#
#  mount -t cvmfs oasis.opensciencegrid.org /cvmfs/oasis.opensciencegrid.org
#

RUN   yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm \
	&& yum install -y \
		cvmfs \
		cvmfs-config-default \
		fuse \
	&& mknod -m 666 /dev/fuse c 10 229 \
	&& chmod 666 /dev/fuse \
	&& echo "CVMFS_HTTP_PROXY=DIRECT" | tee -a /etc/cvmfs/default.local \
	&& mkdir -p /cvmfs/oasis.opensciencegrid.org



#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Default run configuration is to run bash as user "gx" from /gluex directory

USER gx
WORKDIR /gluex
CMD /bin/bash
