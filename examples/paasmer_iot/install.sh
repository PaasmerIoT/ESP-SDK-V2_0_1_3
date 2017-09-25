#!/bin/bash

echo " Installing the Board Requirements and Packages"
echo "Please wait....."

sudo apt-get install uuid
path=`pwd`

echo `rm -rf $path/details.h`

getting_unique()
{
realcounts=$(curl --data "deviceName="$devicename" &email="$username"" http://ec2-52-41-46-86.us-west-2.compute.amazonaws.com/paasmerv2DevAvailability.php)
echo $realcounts
if [ $realcounts = "devicename_accepted" ]
then
	echo "accepted"
elif [ $realcounts = "user_not_registered" ]
then
#       echo $realcounts
        exit
elif [ $realcounts = "devicename_already_there_for_this_user" ]
then
		echo "devicename already exist"
		read -r -p "do you want to continue with another name or you want to exit? [yes/no] " status
		if [ $status == "yes" ]
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

getting_username()
{
read -r -p "Please enter your paasmer registered email id " username
echo $username
if [ ${#username} != 0 ]
then
        usercount=$(curl --data "UserName="$username"" http://ec2-52-41-46-86.us-west-2.compute.amazonaws.com/paasmerv2UserVerify.php)
#       echo $usercount
        if [ $usercount = 1 ]; then
                echo "UserName exists, Please proceed with Device regsitration"
                getting_devicename
        else
                echo "User is not Registered"
                echo " "
                echo "Please Register to our PaasmerIoT platform at https://dashboard.paasmer.co/"
                exit
        fi
else
        getting_username
fi
}

getting_username
thingname=`uuid`
echo "#define UserName \"$username\"" >> /$path/details.h
echo "#define DeviceName \"$devicename\"" >> /$path/details.h
echo "#define ThingName \"$thingname\"" >> /$path/details.h

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

Thingjson=$(sudo su - root -c "aws iot create-thing --thing-name $thingname");
echo $Thingjson >> .Install.log
echo " Thing Json is "
echo $Thingjson | grep "thingArn" | awk '{print $38}'
data=$(sudo cat $path/.Install.log | grep "thingArn" | awk '{print $3'} | tr -d ',')
#ata=$(sudo cat $path/.Install.log | grep "thingArn")
echo $data
echo "#define ThingArn $data" >> $path/details.h

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

sudo aws iot create-policy --policy-name $thingname --policy-document '{ "Version": "2012-10-17", "Statement": [{"Action": ["iot:*"], "Resource": ["*"], "Effect": "Allow" }] }'

sudo su - root -c "echo \"alias PAASMER='sudo aws iot attach-principal-policy --policy-name $thingname --principal $ARN'\" >> /root/.bashrc"

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
sudo chmod 777 ./*
echo $PAASMER >> .Install.log
