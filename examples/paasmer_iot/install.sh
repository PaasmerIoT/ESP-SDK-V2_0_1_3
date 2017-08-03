#!/bin/bash
echo "Installing...\n";
path=`pwd`

getting_unique()
{
realcounts=$(curl --data "deviceName="$devicename"" http://ec2-52-41-46-86.us-west-2.compute.amazonaws.com/paasmerv2DevAvailability.php)
echo $realcounts
if [ $realcounts = 0 ]
then
	echo "accepted"
else
	echo "devicename already exist"
	read -r -p "do you want to continue with another name or you want to exit? [continue/exit] " status
	if [ $status == "continue" ]
	then
    		getting_devicename
	else
		exit
	fi
fi
}

getting_devicename ()
{
read -r -p "Please enter the device name you want:[alphanumeric only(a-z A-Z 0-9)] " devicename
echo $devicename
if [ ${#devicename} != 0 ]
then
	getting_unique
else
	getting_devicename
fi
}
getting_devicename

cat > .Install.log << EOF3
Logfile for Installing Paasmer...
EOF3

echo "--> Installing requerments......." >> .Install.log

sudo pip install awscli
echo "Configuring data..." >> .Install.log
sudo mkdir -p /root/.aws
sudo chmod 777 /root/.aws
cat > /root/.aws/config << EOF1
[default]
region = us-west-2
EOF1


accesskey=$(echo "U2FsdGVkX1904GIBR/J1JHaexBsYkU151ON7m0qqDvXHZP8OsLxZRH7zETfqopS6tB/bVMUfYJHBzkPQ/67R2g==" | openssl enc -aes-128-cbc -a -d -salt -pass pass:asdfghjkl);

keyid=$(echo "U2FsdGVkX19XbOtwglyiBxjyEME74FjnlS5KrbdvXHQGbUC/BulYsgg+a35BR64W" | openssl enc -aes-128-cbc -a -d -salt -pass pass:asdfghjkl);


echo "[default]
aws_secret_access_key = $accesskey
aws_access_key_id = $keyid
" > /root/.aws/credentials


endpoint=$(sudo aws iot describe-endpoint | grep "endpoint" | awk '{print $2}');
sudo openssl ecparam -out ecckey.key -name prime256v1 -genkey
yes "" | sudo openssl req -new -sha256 -key ecckey.key -nodes -out eccCsr.csr
keys=$(sudo aws iot create-certificate-from-csr --certificate-signing-request file://eccCsr.csr --certificate-pem-outfile eccCert.crt --set-as-active);

ARN=$(echo $keys|tr "," "\n"|grep "certificateArn"|awk '{print $3}');

echo $ARN
keytest=$(echo $keys |tr "," "\n"|grep "certificatePem" | cut -d : -f 2| sed -e 's/\\n/\\r\\n\"\"/g');
keytest=$(echo "${keytest::-2}");
client_key=$(cat ecckey.key | sed -e 's/^/"/g' | sed -e 's/$/\\r\\n"/g')
#echo $client_key

echo "// PAASMER IoT client endpoint
const char *client_endpoint = $endpoint;
// IoT device certificate (ECC)
const char *client_cert = $keytest;
// PAASMER IoT device private key (ECC)
const char *client_key = $client_key;
" > client_config.c

no=$RANDOM
#sudo aws iot create-policy --policy-name Paasmer-thing-policy-$no --policy-document '{ "Version": "2012-10-17", "Statement": [{"Action": ["iot:*"], "Resource": ["*"], "Effect": "Allow" }] }'
sudo aws iot create-policy --policy-name $devicename --policy-document '{ "Version": "2012-10-17", "Statement": [{"Action": ["iot:*"], "Resource": ["*"], "Effect": "Allow" }] }'

#function Paasmer {
#  echo "alias PAASMER='sudo aws iot attach-principal-policy --policy-name Paasmer-thing-policy-$no --principal $ARN'" >> ~/.bashrc
 #echo "alias PAASMER='sudo aws iot attach-principal-policy --policy-name $devicename --principal $ARN'" >> ~/.bashrc
 #export $(theja)
#}'''
sudo su - root -c "echo \"alias PAASMER='sudo aws iot attach-principal-policy --policy-name $devicename --principal $ARN'\" >> /root/.bashrc"
#alias Paasmer='sudo aws iot attach-principal-policy --policy-name test-thing-policy-'$no' --principal '$ARN''
#Paasmer

#xterm -e "source ~/.bashrc"
#xterm -e "sudo PAASMER"

#echo '#!/bin/bash
#xterm -e source ~/.bashrc;
#xterm -e sudo PAASMER;
#echo "Done Installing...";' > Configure.sh

#sudo chmod 777 Configure.sh
#bash Configure.sh

#cd ../../

echo "**********************************************************************"
echo "*      Please open new Terminal and type bellow command              *"
echo "*      $  sudo su                                                    *"
echo "*      $  source ~./bashrc										   *"
echo "*      $  PAASMER                                                    *"
echo "*      $  sudo sed -i 's/alias PAASMER/#alias PAASMER/g' ~/.bashrc   *"
echo "*      $  exit                                                       *"
echo "**********************************************************************"

echo "After device registration, edit the config file with credentials and feed details"

echo "File Transfered successfully...." >> .Install.log
echo "#define DeviceName  \"$devicename\"" > $path/deviceName.h
sudo chmod 777 ./*
echo $PAASMER >> .Install.log
