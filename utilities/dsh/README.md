
# Introduction

 The dsh script is used to optionally launch and then attach to
a docker container. It is meant to make it easy to use the
container like a virtual machine by just typing 'dsh' to 
jump into the container and launch a new shell. The other key
feature is it will create a user and group with the same name
and id as the local system so it is easier to work in a shared
directory with the host.

If a container does not already exist, a new one is created
and the following actions performed on it by default:

1.) A new user is added that has the same username, uid, and
    gid as the user running dsh on the host

2.) The user's home directory on the host is mapped to the
    container with a link called 'home_host' in the home
    directory inside the container.

3.) The host /tmp directory is mapped to /tmp_host in the
    container.

4.) The command used to run the container is 'sleep infinity'
    which means the container will not exit when you exit
    from dsh. (use dsh -s to stop a container created by dsh)


Multiple instances of dsh can be run at the same time, each
representing a different shell process in the same container.
You can stop and remove the continer with dsh -s (or using the
docker stop and rm commands directly).

The following environment variables can be used to override the
default values in dsh:

DSH_SHELL          sets command to be run (e.g. tcsh) This is superceded 
                   by the -c command line option if given

DSH_DEFAULT_IMAGE  set the docker image used. This is superceded
				   by the the command line argument if given

# Usage

Usage:
       dsh \[options\] \[imagename\]

options:

     -h,--help     Print this usage/help statement

     -u  user      Set the user to 'user' instead of the one
                   running this script.

     -c  command   Set the command to be run inside the container
                   The default is to use the DSH_SHELL environment
				   variable and if that is not available then 'bash'

     -v volume     Specify a volume to be mapped to the container.
                   The format is just the host_dir:container_dir
                   format docker uses. This may be specified more
                   than once and all directories will be mapped.
                   This only affects when the container is first
                   started.

     -cv           Clear volumes. This will clear out the list of
                   volumes to be mapped, including any specified 
                   using the -v option above. The only real use of
                   this is to prevent the user's home directory on
                   the host from being mapped since it is added to
                   the list by default. 

     -s            Stop and remove the container

     -U+           Force addition of ubuntu style adduser args when
                   creating the container (see note below)

     -U-           Do NOT add ubuntu style adduser args when creating
                   the container (see note below)

## Users
The use of the -u option should be consistent throughout the
life of the container. More specifically, dsh will only create
a user when the container is first created. Subsequent invocations
of dsh will see the existing container and connect to it without
trying to create a new user. Users defined in the image itself
(e.g. root) are always available.

## Ubuntu style adduser arguments:
When running adduser on an
ubuntu-like system, it will normally prompt the user for
additional information such as password, full name, ...
If this happens, this script will fail at that point. Additional
arguments can be passed to avoid this, but they will cause the
adduser call to fail on other centos-like systems. By default,
this script will try and guess if this is ubuntu-like just from
the image name. The -U+ and -U- command line options will disable
this guessing and force the options to be or not be included.

