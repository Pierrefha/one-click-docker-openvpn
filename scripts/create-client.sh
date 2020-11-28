#!/bin/sh
#
# Creates a client using the openssl wrapper easy-rsa3.

if [ $# -lt 2 ]
then
    echo "Please pass clientName clientPass and optionally the
serverIp as arguments!"
    exit 1
fi

CLIENT_NAME=$1
export EASYRSA_BATCH=TRUE
export EASYRSA_PASSIN=pass:$EASYRSA_CA_PASS
export EASYRSA_PASSOUT=pass:$2

cd /easy-rsa/easyrsa3/
./easyrsa build-client-full $CLIENT_NAME

unset EASYRSA_PASSIN EASYRSA_PASSOUT EASYRSA_BATCH


if [ -z $3 ]
then
    echo "No specific IP address was given. Will assume it is the public ip of
this server."
    TARGET_IP=$(curl icanhazip.com)
else
    TARGET_IP=$3
fi

# merges all resulting files into one file using xml tags
cd ./pki
cat /etc/openvpn/client.conf  >> $CLIENT_NAME.ovpn
echo "<ca>" >> $CLIENT_NAME.ovpn; cat ./ca.crt >> $CLIENT_NAME.ovpn; \
    echo "</ca>" >> $CLIENT_NAME.ovpn
echo "<cert>" >> $CLIENT_NAME.ovpn; \
    cat ./issued/$CLIENT_NAME.crt >> $CLIENT_NAME.ovpn; \
    echo "</cert>" >> $CLIENT_NAME.ovpn
echo "<key>" >> $CLIENT_NAME.ovpn; \
    cat ./private/$CLIENT_NAME.key >> $CLIENT_NAME.ovpn; \
    echo "</key>" >> $CLIENT_NAME.ovpn
echo "<tls-crypt>" >> $CLIENT_NAME.ovpn; \
    cat /etc/openvpn/tls-crypt.key >> $CLIENT_NAME.ovpn; \
    echo "</tls-crypt>" >> $CLIENT_NAME.ovpn
# get rid of private key. only the client needs to have his private key.
rm ./private/$CLIENT_NAME.key

# replaces default entry with correct ip and port
sed -i -E "s/my-server-1.*/$TARGET_IP $OPENVPN_SERVER_PORT/g" \
    $CLIENT_NAME.ovpn
sed -i -E "s/^proto.*/proto\ $OPENVPN_PROTOCOL_TYPE/g" $CLIENT_NAME.ovpn

# puts resulting file into the mounted volume so the host can remove them from
# this container.
mkdir -p $OPENVPN_SERVER_DATA_PATH/clients
mv ./$CLIENT_NAME.ovpn $OPENVPN_SERVER_DATA_PATH/clients/
echo "Client $CLIENT_NAME was generated."
