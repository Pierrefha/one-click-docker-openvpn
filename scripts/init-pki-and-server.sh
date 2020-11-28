#!/bin/bash
#
# Initializes the pki(public key infrastructure), creates ca(certificate
# authoritiy) and server keys and certs using easy-rsa 3, a wrapper for openssl
# written and updated by the OpenVPN community.

# cd to easyrsa3 dir
cd /easy-rsa/easyrsa3

# create files once from env and then delete them and unset env after
# execution trying to avoid traces for the password.
export EASYRSA_BATCH=TRUE
export EASYRSA_PASSIN=file:ca.pass
export EASYRSA_PASSOUT=file:ca.pass
export EASYRSA_REQ_CN=$EASYRSA_CA_COMMON_NAME
echo "$EASYRSA_CA_PASS" > ca.pass
echo "$EASYRSA_CA_PASS" >> ca.pass
echo "$EASYRSA_SERVER_PASS" > server.pass && chmod 400 server.pass

# init structure for pki(public key infractructure)
./easyrsa init-pki

# build password encrypted private key for ca and password encrypted ca.cert
./easyrsa build-ca

export EASYRSA_PASSOUT=file:server.pass
# set password for easyrsa server private key using the server.pass file.
./easyrsa build-server-full $EASYRSA_SERVER_COMMON_NAME

# generate CRL (client revocation list) file and adapt ownership
# for user nobody needs to be able to access it since we drop privileges after
# starting the server.
./easyrsa gen-crl && \
chown nobody:nogroup /easy-rsa/easyrsa3/pki/crl.pem


# remove temporary files and envs which contained the passwords
unset EASYRSA_PASSIN EASYRSA_PASSOUT EASYRSA_BATCH EASYRSA_REQ_CN
unset $EASYRSA_CA_PASS $EASYRSA_SERVER_PASS
rm ./ca.pass
cp server.pass /etc/openvpn/

# create key to encrypt tls handshake starting at step 1 of TLS.
openvpn --genkey --secret /etc/openvpn/tls-crypt.key
# make it readable by nobody user in nobody group
chmod +r /etc/openvpn/tls-crypt.key
chown nobody:nogroup /etc/openvpn/tls-crypt.key

# create dhparams using openssl
openssl dhparam -out /etc/openvpn/dh2048.pem 2048 > /dev/null

# copy certs and keys to correct directory (the base one where server.conf
# is located)
cd ./pki
cp issued/server.crt private/server.key ca.crt  /etc/openvpn/
