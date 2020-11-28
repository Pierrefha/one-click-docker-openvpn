#!/bin/sh
#
# Revokes a certificate based on the passed client name.
# This is what you want to do if user forget their password to their private
# certificate or you think certain keys might have been stolen, or you simply
# don't want to allow the client access to your vpn anymore.

if [ -z $1 ]
then
    echo "You must pass a client name that you want to revoke.
Here is a list of all clients that are currently allowed to use your vpn:"
    grep "^[V]" /easy-rsa/easyrsa3/pki/index.txt | \
        awk -F 'CN\=' {'print $2'}
    exit 1
else
    grep "^[V]" /etc/openvpn/easy-rsa/keys/index.txt | \
        awk -F 'CN\=' {'print $2'} | \
        grep $1 && echo "Going to revoke cert for client $1." || \
        echo "Client $1 is already not allowed in our server."
fi

# must be inside easyrsa3 root dir to run their shell script
cd /easy-rsa/easyrsa3/

CLIENT_NAME=$1
export EASYRSA_BATCH=TRUE
export EASYRSA_PASSIN=pass:$EASYRSA_CA_PASS

# revokes the cert
/easy-rsa/easyrsa3/easyrsa revoke $CLIENT_NAME


# prints list of active certs
echo "Printing all clients that now are active:"
grep "^[V]" /easy-rsa/easyrsa3/pki/index.txt | \
    awk -F 'CN\=' {'print $2'}
echo "Printing all clients that are now revoked:"
grep "^[R]" /easy-rsa/easyrsa3/pki/index.txt | \
    awk -F 'CN\=' {'print $2'}

# generalte CRL (certificate revocation list) based on current revocations
echo "Updating the certificate revocation list based on the revocation we just
issued."
/easy-rsa/easyrsa3/easyrsa gen-crl

unset EASYRSA_PASSIN EASYRSA_PASSOUT EASYRSA_BATCH

# adapt ownership of CRL. user nobody needs to be able to access it since we
# drop privileges after starting the server.
chown nobody:nogroup /easy-rsa/easyrsa3/pki/crl.pem

# restart server to kill currently active connections that may have been
# revoked. really weird that this is needed if you ask me.
# since default restart script wont work force shutdown using kill
echo "Restarting the server to apply the changes..."
kill -9 $(ps aux | grep -m 1 openvpn/server.pid | awk {'print $2'})
# start server
service openvpn start
echo "Done!"
