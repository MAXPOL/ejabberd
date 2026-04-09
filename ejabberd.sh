#!/bin/bash

echo "Enter ip address you server:"
read ipaddr

echo "Enter new password database:"
read passworddb

echo "Enter new password jabber user database:"
read jabberdpassworddb

echo "Enter new admin password for ejabberd:"
read adminjabberdpassword

systemctl enable firewalld
systemctl start firewalld

yum install -y wget nano mariadb mariadb-client mariadb-server glibc

systemctl enable mariadb.service
systemctl start mariadb.service

mysql_secure_installation <<EOF

y
$passworddb
$passworddb
y
n
y
y
EOF

cd /
wget https://github.com/processone/ejabberd/releases/download/26.03/ejabberd-26.03-1-linux-x64.run
chmod +x ejabberd-26.03-1-linux-x64.run
./ejabberd-26.03-1-linux-x64.run

mysql -u root -p$passworddb -e "CREATE DATABASE ejabberd;"
mysql -u root -p$passworddb -e "GRANT ALL ON ejabberd.* TO 'ejabberd'@'localhost' IDENTIFIED BY '$jabberdpassworddb';"
mysql -u root -p$passworddb -e "FLUSH PRIVILEGES;"
mysqldump -u root -p$passworddb ejabberd < /opt/ejabberd-26.03/lib/ejabberd-26.3.0/priv/sql/mysql.sql

cat >> /opt/ejabberd/conf/ejabberd.yml <<EOF
sql_type: mysql
sql_server: "localhost"
sql_database: "ejabberd"
sql_username: "ejabberd"
sql_password: "$jabberdpassworddb"
EOF

cp /opt/ejabberd-26.03/bin/ejabberd.service /usr/lib/systemd/system/ejabberd.service

systemctl enable ejabberd.service

sed -i 's/::/'$ipaddr'/g' /opt/ejabberd/conf/ejabberd.yml

systemctl start ejabberd.service

#firewall-cmd --permanent --new-zone=vpn
#firewall-cmd --zone=vpn --change-interface=tun0
#firewall-cmd --permanent --zone=vpn --add-port={5280,5222}/tcp
firewall-cmd --permanent --zone=public --add-port={5280,5222}/tcp
firewall-cmd --reload

export PATH=$PATH:/opt/ejabberd-26.03/bin/
#ejabberdctl register admin ejabberdexample.com $adminjabberdpasswor
ejabberdctl register admin localhost $adminjabberdpasswor

echo "Enter in broser http:// $ipaddr :5280/admin"
echo "You login: admin You password $adminjabberdpasswor"

/opt/ejabberd-26.03/bin/ejabberdctl registered_users localhost
