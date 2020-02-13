#!/bin/bash

file="/etc/network/interfaces"
interface=$(ip -4 -f inet a | grep BROADCAST | awk '{print $2}' | cut -d ":" -f1)

cdr2mask()
{
set -- $((5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 000
[ $1 -gt 1 ] && shift $1 || shift
echo ${1-0}.${2-0}.${3-0}.${4-0}
}

getinfo()
{
  echo "You actual configuration is:"
  ip addr show dev $interface | grep -E '(inet )' | awk '{print $2}' | cut -d "/" -f 1
  cdr2mask $(ip addr show dev $interface | grep -E '(inet )' | awk '{print $2}' | cut -d "/" -f 2)
  ip route list | grep default | awk $'{print $3}' | head -n 1  
  echo "--------------------------------------------"
  echo "Your dns config is:"
  cat /etc/resolv.conf
  echo "--------------------------------------------"
  echo "Press ENTER to use default"
  read -p "Enter your gateway ip address:    (use default 192.168.1.1   ?):" routerip
  [ ! -z "$routerip" ] || routerip=192.168.1.1
  read -p "Enter netmask for your network:   (use default 255.255.255.0 ?):" netmask
  [ ! -z "$netmask" ] || netmask=255.255.255.0
  read -p "Enter ip address for your server: (use default 192.168.1.50  ?):" staticip
  [ ! -z "$staticip" ] || staticip=192.168.1.50
  read -p "Enter ip address for your DNS   : (use default 192.168.1.1   ?):" nameserverip
  [ ! -z "$nameserverip" ] || nameserverip=192.168.1.1
  read -p "Enter your domain name          : (use default faac          ?):" domainlocal
  [ ! -z "$domainlocal" ] || domainlocal=faac

}

writeinterfacefile()
{
cat << EOF > $1
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).
# The loopback network interface
auto lo
iface lo inet loopback
# The primary network interface
auto $interface
#iface enp0s3 inet dhcp

#Your static network configuration
iface $interface inet static
address $staticip
netmask $netmask
gateway $routerip
dns-nameserver $nameserverip
dns-search     $domainlocal
EOF
#don't use any space before of after 'EOF' in the previous line

  echo ""
  echo "Your informatons was saved in '$1' file."
  echo ""
  read -p "Apply the new configuration? [y/n]: " yn2
  case $yn2 in
    [Yy]* ) $("reboot");;
  esac
  exit 0
}

if [ ! -f $file ]; then
  echo ""
  echo "The file '$file' doesn't exist!"
  echo ""
  exit 1
fi

clear
echo "Let's set up a static ip address for your site"
echo ""

getinfo
echo ""
echo "Are this settings correct? :"
echo "Router Address is           : $routerip"
echo "Network Mask is             : $netmask"
echo "Server IP address is        : $staticip"
echo "Name Server IP address is   : $nameserverip"
echo "Default name server         : $domainlocal"
echo ""

while true; do
  read -p "Are these informations correct? [y/n]: " yn
  case $yn in
    [Yy]* ) writeinterfacefile $file;;
    [Nn]* ) getinfo;;
        * ) echo "Pleas enter y or n!";;
  esac
done

