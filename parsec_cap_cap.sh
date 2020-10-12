#!/bin/bash

#CREATES

#Create script
echo '#!/bin/bash

execaps -c 0xffff /bin/true
ret=$?
echo "ret: $ret"
echo $ret > /tmp/capcap.log' > /tmp/capcap.sh

chmod +x /tmp/capcap.sh

#Create unit
echo '[Unit]
Description=capcap test unit (ok)

[Service]
Type=simple
ExecStart=/tmp/capcap.sh
PDPLabel=0:0
CapabilitiesParsec=PARSEC_CAP_CAP' >  /run/systemd/system/capcap_ok.service

#Create unit
echo '[Unit]
Description=capcap test unit (fail)

[Service]
Type=simple
ExecStart=/tmp/capcap.sh
PDPLabel=0:0
#CapabilitiesParsec=PARSEC_CAP_CAP' >  /run/systemd/system/capcap_fail.service


#MAIN

systemctl daemon-reload
systemctl start capcap_ok.service


if grep -q 0 /tmp/capcap.log
then
	echo 'Capcap ok_test OK'
else

	echo 'Capcap ok_test FAIL'

fi


systemctl start capcap_fail.service
sleep 2


if grep  -q 0 /tmp/capcap.log
then
	echo 'Capcap fail_test FAIL'
else

	echo 'Capcap fail_test OK'

fi

systemctl stop capcap_ok.service
systemctl stop capcap_fail.service
rm /tmp/capcap.sh /run/systemd/system/capcap_ok.service /run/systemd/system/capcap_fail.service /tmp/capcap.log


exit 0
