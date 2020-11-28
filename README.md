## One click docker OpenVPN server
Hosting your own openvpn server can be just one click away.

### Prerequesites
- If you are using the default configuration you will have to make sure
port 41194/udp is open.
```shell
# using ufw
sudo ufw allow 41194/udp comment "openvpn server"
# or using iptables
/sbin/iptables -A INPUT -p udp --dport 41194 -m state --state NEW -j ACCEPT
```
Hint: docker will generally ignore ufw if you did not adapt the iptables. \
More about this topic here: https://github.com/docker/for-linux/issues/690
- docker-compose is installed https://docs.docker.com/compose/install/

### Important commands
- initialize and start server
```shell
docker-compose up -d
```
- create a client certificate.\
Example: creating client with name "mylaptop" which has the password
"mylaptoppassword".
```shell
docker container exec -ti idOfYourContainerHere create-client.sh mylaptop
mylaptoppassword
```
- revoke a client certificate.\
This should be done if you think someone else did get his hands on your
certificate.\
Or you gave out some certs and don't want to have them using your vpn
anymore.\
Example: revoking the certificate we have issued before. Using our vpn with
this certificate will no longer be permitted.
```shell
docker container exec -ti idOfYourContainerHere revoke-client.sh mylaptop
```

### Securely transfering the certificate
One of the most important steps to make sure there won't be unallowed guests at
your party.\
It is advised to use scp/ssh for transfering the certificate to your
machine.\
There is a small script in the additionals folder you could adapt to do so.\
(Which expects that you have your ssh configured for your local machine).
