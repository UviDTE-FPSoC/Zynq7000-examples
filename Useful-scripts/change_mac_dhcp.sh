#This file changes the MAC address of the eth0
#interface and the calls udhcpc command to obtain
#an IP address. In the lab each MAC has its own IP
#assigned.
#To watch MAC before and after the change use
#ip link show eth0

#before changing MAC bring interface down
ip link set dev eth0 down
#change MAC
ip link set dev eth0 address 00:04:4b:a1:2a
#bring the interface up again
ip link set dev eth0 up

#Now ask router a new IP
udhcpc
