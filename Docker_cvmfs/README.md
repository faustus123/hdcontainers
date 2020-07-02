
## Docker + GlueX + CVMFS

This directory holds files for making a docker image that can be used to mount the
GlueX software in /group/halld/Software locally in the container so it can be run
on a laptop or desktop.

For this to work, the fuse module must be installed in the container. This can't actually
be done when the image is created so the mount-cvmfs.sh entrypoint script is 
provided to do it automatically when the container is started.

One also needs to run docker with the "--privileged"  option for this to work. To make 
this easy and to provide better integration with the host filesystem (same uid and gid)
a slightly modified version of the dsh script is included in the image. The best way to 
run this is something like:

docker run -it --rm jeffersonlab/gluex-cvmfs get_dsh | tr -d "\r" > dsh
chmod +x dsh
./dsh jeffersonlab/gluex-cvmfs -gdb


The "-gdb" argument is optional, but is needed if you want to run gdb inside the
container.


