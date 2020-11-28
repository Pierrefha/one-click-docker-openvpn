#!/bin/sh
#
# This script is started when running the container. It sets up the openvpn
# server

# enable usage of own vimrc and bashrc
mkdir -p /root/.vim
cp /setup/basics/vimrc /root/.vim/
cp /setup/basics/.bashrc /root/.bashrc

# copy config files to openvpn dir
cp /setup/basics/server.conf /setup/basics/client.conf /etc/openvpn/

# move scripts to bin to enable calling them without giving the complete path
cp /setup/scripts/* /usr/bin/

echo "Adapting routing using iptables."
/usr/bin/config-routing-iptables.sh && echo "Done!"

# avoids redundant setup of server. Starts server and prints log to stdout.
if [ -f "/etc/openvpn/setup-completed" ]
then
    echo "Found already existing openvpn files. Will use them and start up
your server!"
    # run openvpn server and print log to stdout
    service openvpn start
    tail -f /etc/openvpn/openvpn.log
fi

# Use own fork to avoid changes in easy-rsa shell script breaking this
# container. Forked 28.11.2020
mkdir -p /tmpdir123 && cd /tmpdir123
git clone https://github.com/Pierrefha/easy-rsa
cp -r /tmpdir123/easy-rsa/easyrsa3 /easy-rsa/ && rm -r /tmpdir123

echo "Initializing pki(public key infrastructure) and creating the server
cert."
/usr/bin/init-pki-and-server.sh && echo "Done!"

# create file to declare we have succesfully set up the ca and the server.
# this will be used to avoid trouble when restarting the docker container.
touch /etc/openvpn/setup-completed

# create logfile if non existant
touch /etc/openvpn/openvpn.log

# run openvpn server
service openvpn start

# print logs to stdout for container
tail -f /etc/openvpn/openvpn.log
