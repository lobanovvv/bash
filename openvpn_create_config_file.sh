#!/bin/bash
set -e

#VARIABLES

green='tput setaf 2'
red='tput setaf 1'
styleClear='tput sgr0'

#MAIN

#Case without indent, because using cat-eof
case $1 in
suac)

#Remove all config file in openvpn directory for correct working
rm -rf /etc/openvpn/*.conf

#Create client config file
cat << 'EOF' > /etc/openvpn/client.conf
client
dev tun
port 1194
proto udp

remote 10.0.0.23 1194             # VPN server IP : PORT
nobind

ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/client.crt
key /etc/openvpn/easy-rsa/keys/client.key

comp-lzo
persist-key
persist-tun

verb 3
EOF

service openvpn restart
$green; echo OK; $styleClear
exit 0
;;

susrv)

#Remove all config file in openvpn directory for correct working
rm -rf /etc/openvpn/*.conf

#Create client config file
cat << 'EOF' > /etc/openvpn/server.conf
port 1194
proto udp
dev tun

ca      /etc/openvpn/easy-rsa/keys/ca.crt    # generated keys
cert    /etc/openvpn/easy-rsa/keys/server.crt
key     /etc/openvpn/easy-rsa/keys/server.key  # keep secret
dh      /etc/openvpn/easy-rsa/keys/dh2048.pem

server 10.9.8.0 255.255.255.0  # internal tun0 connection IP
ifconfig-pool-persist /etc/openvpn/ipp.txt

keepalive 10 120

comp-lzo         # Compression - must be turned on at both end
persist-key
persist-tun

status /etc/openvpn/log/openvpn-status.log

verb 3  # verbose mode
client-to-client
EOF

#Create log directory and file
cd /etc/openvpn
mkdir -p log/
touch log/openvpn-status.log
chmod -R 777 /etc/openvpn/log

#Create static ip list file. Names gives from crt common name 
touch /etc/openvpn/ipp.txt
chmod 777 /etc/openvpn/ipp.txt
echo 'client,10.9.8.44' > /etc/openvpn/ipp.txt


service openvpn restart
$green; echo OK; $styleClear
;;

*)
    #Error message if user not set agrument
    echo -e 'Add argument for script\n./openvpn_create_config_file.sh suac\nor\n./openvpn_create_config_file.sh susrv'
;;
esac


exit 0
