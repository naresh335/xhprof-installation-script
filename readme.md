# This is an installation script for the XHPROF repository

## actual repository url

https://github.com/preinheimer/xhprof.git

## Instructions for installation

git clone https://github.com/naresh335/xhprof-installation-script.git

## Create a new mysql database for xhprof using phpmyadmin or terminal

sudo mysql -e 'CREATE DATABASE xhprof;'

## execute script and follow instructions
cd xhprof && sudo ./xhprof.sh

#### start profiling your requests by passing `/?_profile=1` argument in the first request

#### visit http://localhost/xhprof or http://anydomain.local/xhprof for xhprof dashboard

#### This is tested on Ubuntu 18.04 LTS only, also installation script is intended for development environment only.