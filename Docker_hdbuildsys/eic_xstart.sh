#!/bin/bash
#
# This script should be sourced in order to modify the 
# environment of the calling shell. Normally, this will
# be done via the xstart alias which is defined in
# /etc/profile.d/xstart.sh  which itself is sourced 
# automatically at login.
#

geom="1400x1000"
#vncpassword="123456"
#
#if [ ! -f $HOME/.vnc/passwd ]; then
#	mkdir -p ${HOME}/.vnc
#	echo $vncpassword | vncpasswd -f > $HOME/.vnc/passwd
#	chmod 600 $HOME/.vnc/passwd
#	echo " "
#	echo "    VNC PASSWORD SET TO: $vncpassword"
#	echo " "
#elif [ `echo $vncpassword | vncpasswd -f` == `cat $HOME/.vnc/passwd` ]; then
#	echo "    VNC PASSWORD in ~/.vnc/passwd already set to: $vncpassword"
#else
#	vncpassword="<your default from ~/.vnc/passwd>"
#fi

# Start VNC server
vncserver -SecurityTypes None -geometry $geom |& grep "desktop is" | awk '{split($6,a,":"); print a[2]}' > /tmp/vncnum
vncnum=`cat /tmp/vncnum`

# set DISPLAY
export DISPLAY=:$vncnum

# set DISPLAY in .bashrc so subsequent logins will use
# this. The following line will replace any existing line
# starting with "DISPLAY=" or append a new one if no existing
# one is found.
if [ -f $HOME/.bashrc ]; then
	sed '/^export\ DISPLAY=/{h;s/=.*/=:'$vncnum'/};${x;/^$/{s//export\ DISPLAY=:'$vncnum'/;H};x}' -i $HOME/.bashrc
else
	echo "export DISPLAY=:$vncnum" >> $HOME/.bashrc
fi

# Start xfce4 window manager
sleep 2
#openbox < /dev/null &> /dev/null &
#xfwm4 < /dev/null &> /dev/null &
#xfce4-session < /dev/null &> /dev/null &
startkde < /dev/null &> /dev/null &

# Open Example.md file in nedit window
if [ -f /eic/doc/examples/Examples.md ]; then
	if [ ! -f $HOME/.nedit/nedit.rc ]; then
		mkdir -p $HOME/.nedit
		echo "nedit.textRows: 60" > $HOME/.nedit/nedit.rc
	fi
	nedit /eic/doc/examples/Examples.md  &> /dev/null &
fi

# Start noVNC server to present VNC as HTML5 webserver
# Note that unlike vncserver, this will not find an available
# port. We must keep trying until we find one.
vnchostport=localhost:`expr 5900 "+" $vncnum`
for port in {6080..6280}; do
	line=`netstat -lnt | awk '$6 == "LISTEN" && $4 ~ /:'$port'$/'  | wc | awk '{print $1}'`
	[ "$line" -eq "0" ] && break
	echo "Port $port unavailable for noVNC server"
	sleep 0.25
done

echo "Launching noVNC on port $port ..."
/opt/noVNC/utils/launch.sh --listen $port --vnc $vnchostport < /dev/null &> /dev/null &

echo " "
echo " "
echo "Point your HTML5 enabled browser on the host to:"
echo " "
echo "    http://localhost:$port"
echo " "
echo "Alternatively, point your VNC client to $vnchostport"
echo " "
#echo " VNC PASSWORD: $vncpassword"
#echo " "

