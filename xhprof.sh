#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, try \`sudo ./${0##*/}\`" 
   exit 1
fi

#check for mysql pass

read -p "Enter MySQL username: " mysqlUser
read -s -p "Enter MySQL password: " mysqlPassword

while ! mysql -u $mysqlUser -p$mysqlPassword  -e ';' &> /dev/null ; do
       read -p "Can't connect, please retry MySQL username: " mysqlUser
       read -s -p "MySQL password: " mysqlPassword
done
printf "\nConnected!!\n"
read -p "Enter MYSQL database name for xhprof: " mysqlDatabase
sudo mysql -u $mysqlUser -p$mysqlPassword $mysqlDatabase < xhprof-schema.sql &> /dev/null
echo "created schema table for xhprof"

#install php dependencies
sudo apt install git graphviz -y
sudo apt install tideways-php
if [[ "$?" -ne "0" ]]; then
	read -p "Enter php version (7.0 or 7.1 or 7.2 or 7.3) for which you want to install xhprof: " phpVersion
	sudo apt install php${phpVersion}-tideways
fi
{
sudo systemctl restart php7.0-fpm php7.1-fpm php7.2-fpm php7.3-fpm apache2
} &> /dev/null

sed -i "s/xhprofuser/${mysqlUser}/g" sample-config-xhprof.php
sed -i "s/xhprofpass/${mysqlPassword}/g" sample-config-xhprof.php
sed -i "s/xhprofdb/${mysqlDatabase}/g" sample-config-xhprof.php

printf "\n Configuration setup success \n pass \`\?_profile=1\` argument to start profiling your requests"

#install xhprof from git
mkdir -p /etc/xhprof
sudo cp apache.conf /etc/xhprof/apache.conf
ln -s /etc/xhprof/apache.conf /etc/apache2/conf-enabled/xhprof.conf &> /dev/null

mkdir -p /usr/share/xhprof
git clone https://github.com/preinheimer/xhprof.git /usr/share/xhprof &> /dev/null
sudo cp sample-config-xhprof.php /usr/share/xhprof/xhprof_lib/config.php

grep -qxF 'auto_prepend_file=/usr/share/xhprof/external/header.php' /etc/php/${phpVersion}/mods-available/tideways.ini || echo 'auto_prepend_file=/usr/share/xhprof/external/header.php' >> /etc/php/7.2/mods-available/tideways.ini

sudo systemctl reload php${phpVersion}-fpm apache2

printf "\n Script successfully executed, \n open xhprof dashboard via any localdomain/xhprof ...";
