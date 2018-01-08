#--------------------------------------------------------------------------
# jeffersonlab/hdccdb
#
# This will build an image that has a mysql server filled with
# the CCDB contents taken from a snapshot at a specific point in
# time. A container can be created from the image that allows 
# connections from other containers for use in GRID/Cloud/HPC
# environment. 
#
# See Comments in initialize_db.sh for details
#
# To build, you must first make a dump of the current ccdb DB
# into a file named "ccdb.sql" in the local directory:
#
#   mysqldump -h hallddb -u ccdb_user ccdb > ccdb.sql
#
#
#--------------------------------------------------------------------------
#
# Build time: 
# Image size: 
#
#   docker build -t hdccdb:2018.01.08 .
#
#   docker push jeffersonlab/hdccdb:2018.01.08
#
#--------------------------------------------------------------------------

FROM mysql:8.0.1
LABEL maintainer "David Lawrence <davidl@jlab.org>"

EXPOSE 3306
ADD . /docker

RUN /docker/initialize_db.sh

CMD ["mysqld", "--user=mysql"]
