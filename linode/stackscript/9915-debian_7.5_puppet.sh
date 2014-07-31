#!/bin/bash

## Parameters
# <udf name="hostname" label="hostname">
# <udf name="ip_private" label="private ip">
# <udf name="domain_public" label="public domain name" default="planetb612.info">
# <udf name="domain_private" label="private domain name" default="ln.planetb612.info">
# <udf name="username" label="unprivileged user name" default="neo">
# <udf name="userpass" label="unprivileged user password" default="">
# <udf name="default_debian_release" label="default debian release" default="wheezy">

## logging
exec > /root/stackscript.log 2> /root/stackscript.err.log
## debug info
echo "Start running StackScript - $(date)"
env
echo

## set static networking - https://www.linode.com/docs/networking/linux-static-ip-configuration
## hostname
echo "${HOSTNAME}" > /etc/hostname
hostname -F /etc/hostname
## resolver
sed -i "s/^domain.*/domain ${DOMAIN_PRIVATE}/" /etc/resolv.conf
sed -i "s/^search.*/search ${DOMAIN_PUBLIC} ${DOMAIN_PRIVATE}/" /etc/resolv.conf
## static interfaces
IP_PRIMARY=$(ifconfig eth0 | awk -F: '/inet addr:/ {print $2}' | awk '{ print $1 }')
IP_GATEWAY="$(echo $IP_PRIMARY | cut -d. -f1-3).1"
#IP_PRIVATE=<set by udf>
cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
#iface eth0 inet dhcp
iface eth0 inet static
  address ${IP_PRIMARY}/24
  gateway ${IP_GATEWAY}
iface eth0 inet static
  address ${IP_PRIVATE}/17

EOF
echo -e "\n## FQDN" >> /etc/hosts
echo "$IP_PRIMARY ${HOSTNAME}.${DOMAIN_PUBLIC}" >> /etc/hosts
echo "$IP_PRIVATE ${HOSTNAME}.${DOMAIN_PRIVATE} ${HOSTNAME}" >> /etc/hosts
#/etc/init.d/networking restart
ifdown -a && ifup -a
#sed /etc/default/dhcpcd

## apt
## package mirror and settings
mv /etc/apt/sources.list /etc/apt/sources.list~
cat > /etc/apt/sources.list.d/linode.list <<EOF
deb http://mirrors.linode.com/debian/ wheezy main contrib non-free
deb http://mirrors.linode.com/debian/ jessie main contrib non-free
deb http://mirrors.linode.com/debian/ sid main contrib non-free
#deb http://mirrors.linode.com/debian-security/ testing/updates main contrib non-free
deb http://mirrors.linode.com/debian-security/ wheezy/updates main contrib non-free
deb http://mirrors.linode.com/debian-security/ jessie/updates main contrib non-free
EOF
cat > /etc/apt/apt.conf.d/10periodic <<EOF
APT::Periodic::Update-Package-Lists "4";
APT::Periodic::Download-Upgradeable-Packages "8";
APT::Periodic::AutocleanInterval "12";
EOF
echo "APT::Default-Release \"${DEFAULT_DEBIAN_RELEASE}\";" > "/etc/apt/apt.conf.d/24${DEFAULT_DEBIAN_RELEASE}"
echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/25norecommends
## update and upgrade
aptitude update
aptitude -y full-upgrade

# ## non-privileged user
# ## add user
# adduser $USERNAME --disabled-password --gecos ""
# [ -n "$PASSWORD"] && ( echo "$USERNAME:$USERPASS" | chpasswd )
# usermod -aG sudo $USERNAME
# ## add ssh public key
# mkdir -p /home/$USERNAME/.ssh
# #curl 'url_of_public_key' >> /home/$USERNAME/.ssh/authorized_keys
# chown -R "$USERNAME":"$USERNAME" /home/$USERNAME/.ssh

## various system settings
## enable tmpfs on /tmp
sed -i 's/#\?RAMTMP=.*/RAMTMP=yes/' /etc/default/tmpfs
## disable root ssh
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
/etc/init.d/ssh restart

echo "Finished - $(date)"
