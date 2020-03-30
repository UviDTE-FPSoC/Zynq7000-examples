# This file assigns an IP address to the eth0 interface within a mask you
#can ping from a computer if you establish a manual connection to a IP in
#the same range and with the same mask

ifconfig 192.168.0.1 eth0 netmask 255.255.255.0
