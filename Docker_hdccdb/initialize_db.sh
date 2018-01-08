#!/bin/sh

# This script is made to run while building a new image. It will
# start up the MySQL server and wait for it to start accepting
# connections. Then it will create the ccdb database and ccdb_user
# and finally fill the ccdb using a dump of the CCDB that has been
# copied to /docker. Once done, it will AUTOMATICALLY DELETE the
# /docker/ccdb.sqlite file in order to reduce the final image size.
#
# It should appear in a Dockerfile like this:
#
#   RUN /docker/initialize_db.sh
#

export MYSQL_ROOT_PASSWORD=654321

# OK, so there is a nasty issue that if the base image declares a
# directory a VOLUME then any modifications to that in containers
# (and therefore, derived images) are lost. They do this with the
# /var/lib/mysql directory where the actual data is kept for the 
# mysql official images. The assumption being that users will want
# to store data in an external, persistent volume that can survive
# restarting a new container. This issues is discussed and thouroughly
# complained about here:
#
#   https://github.com/moby/moby/issues/3639
# 
# The solution (which I found here:
#  http://l33t.peopleperhour.com/2015/02/18/docker-extending-official-images/)
# is to tell the mysqld server to use a different directory.
# (What a pain in the ass!)
mkdir -p /var/lib/mysql2
chown mysql:mysql /var/lib/mysql2
mv /etc/mysql/my.cnf /etc/mysql/my.cnf.orig
cat /etc/mysql/my.cnf.orig | sed -e 's/\/var\/lib\/mysql/\/var\/lib\/mysql2/g' > /etc/mysql/my.cnf
 

echo 'Starting mysql server ....'
cd /
./entrypoint.sh mysqld &
mysql_pid=$!

echo 'waiting for server to initialize and start accepting connections. (This may take 10-15mins!)'
until mysql -p$MYSQL_ROOT_PASSWORD -e "SELECT NOW()" ; do
  echo -n "."; sleep 1
done

# It seems that the server only briefly allows conncetions and then
# restarts itself. This looked to be just long enough for the user to
# be created but failed when running the GRANT query. Sleep for 10
# seconds to let it begin the restart process and then watch for the
# connection to become live again.
echo 'waiting 10 seconds for server to restart ...'
sleep 10
echo 'waiting for server to accept conncetions again ...'
until mysql -p$MYSQL_ROOT_PASSWORD -e "SELECT NOW()" ; do
  echo -n "."; sleep 1
done

echo 'Setting up CCDB ...'
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE ccdb"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE USER 'ccdb_user'@'%'"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'ccdb_user'@'%'"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "SET GLOBAL max_allowed_packet=1000000000"

echo 'Filling CCDB ...'
mysql -uccdb_user ccdb < /docker/ccdb.sql
rm /docker/ccdb.sql

ls -l /var/lib/mysql

# Tell the MySQL daemon to shutdown.
echo 'sending HUP to server ...'
kill -HUP $mysql_pid
sleep 5
echo 'sending INT to server ...'
kill -INT $mysql_pid
sleep 2
echo 'sending KILL to server ...'
kill -9 $mysql_pid



