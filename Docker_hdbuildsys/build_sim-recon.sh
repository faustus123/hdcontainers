#!/bin/bash


export BUILD_THREADS=8

export ROOT_VERSION=6.12.06
export CCDB_VERSION=1.06.06
export CCDB_RUN_MIN=10000
export CCDB_RUN_MAX=99999
export RCDB_VERSION=0.02
export HDDS_VERSION=3.12
export JANA_VERSION=0.7.9p1
export AMPTOOLS_VERSION=0.9.3
export GLUEX_ROOT_ANALYSIS_VERSION=0.2
#ARG SIM_RECON_VERSION=2.20.1


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build and install ROOT

export INSTALL_DIR_ROOT=$GLUEX_TOP/root/$ROOT_VERSION

mkdir -p $GLUEX_TOP/build \
&&  cd $GLUEX_TOP/build \
&&  wget https://root.cern.ch/download/root_v${ROOT_VERSION}.source.tar.gz \
&&  tar xzf root_v${ROOT_VERSION}.source.tar.gz \
&&  mkdir root-build \
&&  cd root-build \
&&  cmake \
-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR_ROOT \
-Dgdml=ON \
-Dminuit2=ON \
../root-${ROOT_VERSION} \
&&  make -j $BUILD_THREADS \
&&  make install \
&&  ln -s $ROOT_VERSION $GLUEX_TOP/root/PRO \

export ROOTSYS=${GLUEX_TOP}/root/PRO
export PATH=${PATH}:${ROOTSYS}/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROOTSYS}/lib

exit(0)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build and install CCDB

ENV INSTALL_DIR_CCDB $CONTAINER_ROOT/app/ccdb

RUN mkdir -p $INSTALL_DIR_CCDB \
&&  cd $INSTALL_DIR_CCDB \
&&  git clone https://github.com/jeffersonlab/ccdb v$CCDB_VERSION \
&&  cd v$CCDB_VERSION  \
&&  git checkout tags/v$CCDB_VERSION \
&&  source ./environment.bash \
&&  scons -j$BUILD_THREADS \
&&  rm -rf java src projects doc tmp lib/libccdb.a \
&&  mkdir -p $GLUEX_TOP/app/ccdb \
&&  ln -s $INSTALL_DIR_CCDB/v$CCDB_VERSION $GLUEX_TOP/app/ccdb/v$CCDB_VERSION \
&&  ln -s v$CCDB_VERSION $GLUEX_TOP/app/ccdb/PRO

ENV CCDB_HOME ${GLUEX_TOP}/app/ccdb/PRO
ENV PATH ${PATH}:${CCDB_HOME}/bin
ENV LD_LIBRARY_PATH ${CCDB_HOME}/lib:${LD_LIBRARY_PATH}
ENV PYTHONPATH ${CCDB_HOME}/python


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build and install HDDS
#
# Note: Binaries will be installed in a directory named "build" since
# BMS_OSNAME is not yet defined here. When sim-recon is built below,
# it will create a symbolic link with the name of BMS_OSNAME that points
# to "build" so that sim-recon will build successfully. It is done this
# way because osrelease.pl which sets BMS_OSNAME is not available anywhere
# yet.
#

ENV INSTALL_DIR_HDDS $CONTAINER_ROOT/app/hdds
ENV XERCESCROOT /usr

RUN mkdir -p $INSTALL_DIR_HDDS \
&&  cd $INSTALL_DIR_HDDS \
&&  git clone https://github.com/jeffersonlab/hdds v$HDDS_VERSION \
&&  cd v$HDDS_VERSION  \
&&  git checkout tags/$HDDS_VERSION \
&&  scons -j$BUILD_THREADS install \
&&  rm -rf build/src/hddsGeant3.F build/lib/libhddsGeant3.a build/bin/hdds-geant build/bin/findall \
&&  mkdir -p $GLUEX_TOP/app/hdds \
&&  ln -s $INSTALL_DIR_HDDS/v$HDDS_VERSION $GLUEX_TOP/app/hdds/v$HDDS_VERSION \
&&  ln -s v$HDDS_VERSION $GLUEX_TOP/app/hdds/PRO

ENV HDDS_HOME ${GLUEX_TOP}/app/hdds/PRO
ENV PATH ${PATH}:${HDDS_HOME}/build/bin
ENV LD_LIBRARY_PATH ${HDDS_HOME}/build/lib:${LD_LIBRARY_PATH}
ENV JANA_GEOMETRY_URL xmlfile://${HDDS_HOME}/main_HDDS.xml


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build and install JANA

ENV INSTALL_DIR_JANA $CONTAINER_ROOT/app/jana

RUN mkdir -p $INSTALL_DIR_JANA \
&&  cd $INSTALL_DIR_JANA \
&&  wget https://www.jlab.org/JANA/releases/jana_${JANA_VERSION}.tgz \
&&  tar xzf jana_${JANA_VERSION}.tgz \
&&  cd jana_${JANA_VERSION} \
&&  scons -j$BUILD_THREADS install \
&&  cd src \
&&  rm -rf .Linux* \
&&  cd ../Linux* \
&&  rm -rf test plugins bin/jcalibread bin/janadump bin/jgeomread bin/jresource bin/jcalibcopy bin/janactl \
&&  cd .. \
&&  ln -s Linux*/bin \
&&  ln -s Linux*/include \
&&  ln -s Linux*/lib \
&&  ln -s Linux*/plugins \
&&  mkdir -p $GLUEX_TOP/app/jana \
&&  ln -s $INSTALL_DIR_JANA/jana_${JANA_VERSION} $GLUEX_TOP/app/jana/jana_${JANA_VERSION} \
&&  ln -s jana_${JANA_VERSION} $GLUEX_TOP/app/jana/PRO

ENV JANA_HOME ${GLUEX_TOP}/app/jana/PRO
ENV PATH ${PATH}:${JANA_HOME}/bin
ENV LD_LIBRARY_PATH ${JANA_HOME}/lib:${LD_LIBRARY_PATH}
ENV JANA_PLUGIN_PATH ${JANA_HOME}/plugins


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build and install RCDB

ENV INSTALL_DIR_RCDB $CONTAINER_ROOT/app/rcdb

RUN mkdir -p $INSTALL_DIR_RCDB \
&&  cd $INSTALL_DIR_RCDB \
&&  git clone https://github.com/jeffersonlab/rcdb v$RCDB_VERSION \
&&  cd v$RCDB_VERSION  \
&&  git checkout tags/v$RCDB_VERSION \
&&  source ./environment.bash \
&&  cd cpp \
&&  scons -j$BUILD_THREADS \
&&  rm -rf src tmp bin/exmpl* lib/librcdb.a \
&&  cd .. \
&&  ln -s cpp/include \
&&  ln -s cpp/lib \
&&  mkdir -p $GLUEX_TOP/app/rcdb \
&&  ln -s $INSTALL_DIR_RCDB/v$RCDB_VERSION $GLUEX_TOP/app/rcdb/v$RCDB_VERSION \
&&  ln -s v$RCDB_VERSION $GLUEX_TOP/app/rcdb/PRO

ENV RCDB_HOME ${GLUEX_TOP}/app/rcdb/PRO
ENV PATH ${PATH}:${RCDB_HOME}/bin
ENV LD_LIBRARY_PATH ${RCDB_HOME}/lib:${LD_LIBRARY_PATH}
ENV PYTHONPATH ${RCDB_HOME}/python:${PYTHONPATH}


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build and install AMPTOOLS (disabled)
#
#ENV INSTALL_DIR_AMPTOOLS $CONTAINER_ROOT/app/amptools
#
#RUN mkdir -p $INSTALL_DIR_AMPTOOLS \
#    &&  cd $INSTALL_DIR_AMPTOOLS \
#    &&  git clone https://github.com/mashephe/AmpTools v$AMPTOOLS_VERSION \
#    &&  cd v$AMPTOOLS_VERSION  \
#    &&  git checkout tags/v$AMPTOOLS_VERSION \
#    &&  make -j $BUILD_THREADS -C AmpTools \
#    &&  export AMPTOOLS=${PWD}/AmpTools \
#    &&  make -j $BUILD_THREADS -C AmpPlotter \
#    &&  rm -rf Tutorials AmpTools/IUAmpTools/lib*.a AmpTools/UpRootMinuit/lib*.a AmpTools/MinuitInterface/lib*.a \
#    &&  mkdir -p $GLUEX_TOP/app/amptools \
#    &&  ln -s $INSTALL_DIR_AMPTOOLS/v$AMPTOOLS_VERSION $GLUEX_TOP/app/amptools/v$AMPTOOLS_VERSION \
#    &&  ln -s v$AMPTOOLS_VERSION $GLUEX_TOP/app/amptools/PRO
#
#ENV AMPTOOLS_HOME ${GLUEX_TOP}/app/amptools/PRO
#ENV AMPTOOLS   ${AMPTOOLS_HOME}/AmpTools
#ENV AMPPLOTTER ${AMPTOOLS_HOME}/AmpPlotter
#ENV PATH ${PATH}:${AMPTOOLS}/bin:${AMPPLOTTER}/bin
#ENV LD_LIBRARY_PATH ${AMPTOOLS}/lib:${AMPPLOTTER}/lib:${LD_LIBRARY_PATH}


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build and install GLUEX_ROOT_ANALYSIS


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build and install SIM-RECON

ENV INSTALL_DIR_SIM_RECON $CONTAINER_ROOT/app/sim-recon

# Set envars here before building so they make it into the setenv.(c)sh file
ENV JANA_CALIB_URL    sqlite:///${GLUEX_TOP}/DB/ccdb.sqlite
ENV JANA_RESOURCE_DIR ${GLUEX_TOP}/resources

RUN mkdir -p $INSTALL_DIR_SIM_RECON \
&&  cd $INSTALL_DIR_SIM_RECON \
&&  git clone https://github.com/jeffersonlab/sim-recon latest \
&&  cd latest \
&&  export HALLD_HOME=$PWD \
&&  export BMS_OSNAME=`./src/BMS/osrelease.pl` \
&&  ln -s build $HDDS_HOME/$BMS_OSNAME \
&&  cd src \
&&  scons -j $BUILD_THREADS install \
&&  cd ../Linux* \
&&  mv bin junk \
&&  mkdir bin \
&&  mv junk/hd_root bin \
&&  cd .. \
&&  rm -rf .git src Linux*/lib/lib*.a Linux*/junk Linux*/python2\
&&  ln -s Linux*/bin \
&&  ln -s Linux*/include \
&&  ln -s Linux*/lib \
&&  ln -s Linux*/plugins \
&&  mkdir -p $GLUEX_TOP/app/sim-recon \
&&  ln -s $INSTALL_DIR_SIM_RECON/latest $GLUEX_TOP/app/sim-recon/latest \
&&  ln -s latest $GLUEX_TOP/app/sim-recon/PRO

ENV HALLD_HOME ${GLUEX_TOP}/app/sim-recon/PRO
ENV PATH ${PATH}:${HALLD_HOME}/bin
ENV LD_LIBRARY_PATH ${HALLD_HOME}/lib:${LD_LIBRARY_PATH}
ENV JANA_PLUGIN_PATH ${HALLD_HOME}/plugins:${JANA_PLUGIN_PATH}


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Download and install SQLite file for CCDB

ENV INSTALL_DIR_CCDB_DB $CONTAINER_ROOT/DB

RUN mkdir -p $INSTALL_DIR_CCDB_DB \
&&  cd $INSTALL_DIR_CCDB_DB \
&&  wget -O ccdb_`date +"%Y_%m_%d"`.sqlite https://halldweb.jlab.org/dist/ccdb.sqlite \
&&  ln -s ccdb_*.sqlite ccdb.sqlite \
&&  mkdir ${GLUEX_TOP}/DB \
&&  ln -s ${INSTALL_DIR_CCDB_DB}/ccdb.sqlite ${GLUEX_TOP}/DB/ccdb.sqlite

# Reduce size of CCDB file (broken at the moment)
#RUN git clone https://github.com/jeffersonlab/hd_utilities \
#    &&  ./hd_utilities/CCDButils/ccdb_reduce.py -input=ccdb.sqlite -output=ccdb_sparse.sqlite -rmin=$CCDB_RUN_MIN -rmax=$CCDB_RU_MAX \
#    &&  rm -rf ccdb.sqlite ccdb_20*.sqlite hd_utilities \
#    &&  mv cdb_sparse.sqlite cdb_sparse_`date +"%Y_%m_%d"`.sqlite \
#    &&  ln -s ccdb_sparse*.sqlite ccdb.sqlite


# n.b. JANA_CALIB_URL is set prior to building sim-recon above
ENV CCDB_CONNECTION ${JANA_CALIB_URL}


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Pull in resources (e.g. magnetic field map)

COPY *.evio /container
RUN mkdir /container/resources \
&&  cd /container \
&&  ln -s /container/resources ${GLUEX_TOP}/resources \
&&  hd_root -PAUTOACTIVATE=DChargedTrack,DNeutralParticle *.evio \
&&  rm -rf hd_root.root *.evio \
&&  chmod go+w -R /container/resources

# n.b. JANA_RESOURCE_DIR is set prior to building sim-recon above


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Default run configuration is to run bash as user "gx" from home directory

USER gx
WORKDIR /data
CMD /bin/bash

