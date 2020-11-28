#!/bin/sh
#
# Copies client certificate (.ovpn) file from remote to local
# and makes sure it is deleted on remote (only we need our private key!)

if [ -z $1 ]
then
    echo "Please pass the client name you want to copy and rm from remote
server as argument!"
    exit 1
fi

# path were clients are stored on the remote server
REMOTE_OPENVPN_CLIENT_PATH=/var/dockerdata/openvpn/clients
# where client shall be stored on the client
STORE_CLIENT_HERE=/probably/your/openvpn/path
# ip and user of the remote server
REMOTE_IP=YOUR.SERVER.IP.HERE
REMOTE_USER=root

scp $REMOTE_USER@$REMOTE_IP:$REMOTE_OPENVPN_CLIENT_PATH/$1.ovpn \
    $STORE_CLIENT_HERE \
    && ssh $REMOTE_USER@$REMOTE_IP "rm $REMOTE_OPENVPN_CLIENT_PATH/$1.ovpn"
