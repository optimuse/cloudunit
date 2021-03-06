#!/bin/bash

export CU_USER=admincu
export CU_HOME=/home/$CU_USER/cloudunit
export CU_INSTALL_DIR=$CU_HOME/cu-production

export COMPOSE_VERSION=1.9.0

ROOTUID="0"

if [ "$(id -u)" -ne "$ROOTUID" ] ; then
    echo "This script must be executed with root privileges."
    exit 1
fi

echo ""
echo ""
read -p "- Domain : " domain
echo ""
echo ""

# INIT
apt-get update
apt-get install -y git

[ -z "$1" ] && echo "No branch argument supplied. Exit..." && exit 1

export GIT_BRANCH=$1
BRANCH_EXIST=$(git ls-remote --heads https://github.com/Treeptik/cloudunit $GIT_BRANCH)
echo git ls-remote --heads https://github.com/Treeptik/cloudunit $GIT_BRANCH
if [ ! "$BRANCH_EXIST" ];
  then
    echo "The branch $1 is not valid. Please choose one the following branches: "
    git ls-remote --heads https://github.com/Treeptik/cloudunit
    exit 1
fi

# CREATE ADMINCU USER admincu account
useradd -m -s /bin/bash $CU_USER

# PROVISION THE ENV
apt-get install -y nmap
apt-get install -y htop
apt-get install -y ncdu
apt-get install -y git
apt-get install -y haveged

# CLONE CLOUDUNIT
cd /home/$CU_USER && git clone https://github.com/Treeptik/cloudunit.git -b $GIT_BRANCH
chown -R $CU_USER:$CU_USER /home/$CU_USER

# INSTALL DOCKER
apt-get install -y apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
cp $CU_INSTALL_DIR/files/sources.list /etc/apt/sources.list
apt-get update
apt-get install -y docker-engine
apt-get install -y mysql-client
usermod -aG docker admincu
service docker stop
sh /home/admincu/cloudunit/cu-production/generate-certs.sh
cp -f $CU_INSTALL_DIR/files/docker.service /etc/default/docker
service docker start

# install Docker Compose
# @see http://docs.docker.com/compose/install/
curl -o docker-compose -L https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m`
chmod a+x docker-compose
sudo mv docker-compose /usr/local/bin

# Install log rotate
cp $CU_INSTALL_DIR/files/docker-logrotate /etc/logrotate.d/

# Install cron restart
mkdir -p /home/admincu/.cloudunit
cp $CU_INSTALL_DIR/files/cron.sh /home/admincu/.cloudunit/cron.sh
echo "*/3 * * * * admincu /home/admincu/.cloudunit/cron.sh" >> /etc/crontab

chmod +x /home/admincu/.cloudunit/cron.sh
chown -R admincu /home/admincu/
chown -R admincu /home/admincu/.cloudunit

# Add admincu to sudoers group
cp -f $CU_INSTALL_DIR/files/sudoers /etc/sudoers
usermod -g sudo $CU_USER

# copy the environment file
cp -f $CU_INSTALL_DIR/files/environment /etc/environment
sed -i "s/DOMAIN_NAME/$domain/g" /etc/environment

# display values to declare
echo ""
echo "You have to declare into your dns"
echo ""
cat /etc/environment

# Change admincu passwd
passwd admincu

echo ""
echo "You can open a new session with admincu"
echo ""
