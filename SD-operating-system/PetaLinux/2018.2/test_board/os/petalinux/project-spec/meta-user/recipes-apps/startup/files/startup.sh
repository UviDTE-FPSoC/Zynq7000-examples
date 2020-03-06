#!/bin/sh

start ()
{
    normal="\e[39m"
    lightred="\e[91m"
    lightgreen="\e[92m"
    green="\e[32m"
    yellow="\e[33m"
    cyan="\e[36m"
    red="\e[31m"
    magenta="\e[95m"

    echo -ne $yellow
    echo "Init Start"
    echo -ne $normal

#	mount -t vfat /dev/mmcblk1p1 /media
	if [ -f /run/media/mmcblk1p1/init.sh ]
	then
		echo -ne $lightgreen
		echo "Run init.sh from SD card"
		echo -ne $normal
		tr -d '\r' < /run/media/mmcblk1p1/init.sh > /tmp/init.sh
		source /tmp/init.sh
		rm /tmp/init.sh
		#umount /media
	fi

    echo -ne $yellow
    echo "Init End"
    echo -ne $normal

}
stop ()
{
	echo " Stop."
}
restart()
{
	stop
	start
}
case "$1" in
	start)
		start; ;;
	stop)
		stop; ;;
	restart)
		restart; ;;
	*)
		echo "Usage: $0 {start|stop|restart}"
		exit 1
	esac
exit $?
