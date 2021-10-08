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

yum install -y wget nano mariadb-server glibc

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
wget --no-check-certificate https://www.process-one.net/downloads/downloads-action.php?file=/19.05/ejabberd-19.05-0.x86_64.rpm
mv downloads-action.php?file=%2F19.05%2Fejabberd-19.05-0.x86_64.rpm ejabberd-19.05-0.x86_64.rpm
rpm -ivh ejabberd-19.05-0.x86_64.rpm

mysql -u root -p$passworddb -e "CREATE DATABASE ejabberd;"
mysql -u root -p$passworddb -e "GRANT ALL ON ejabberd.* TO 'ejabberd'@'localhost' IDENTIFIED BY '$jabberdpassworddb';"
mysql -u root -p$passworddb -e "FLUSH PRIVILEGES;"
mysqldump -u root -p$passworddb ejabberd < /opt/ejabberd-19.05/lib/ejabberd-19.05/priv/sql/mysql.sql

cat >> /opt/ejabberd/conf/ejabberd.yml <<EOF
sql_type: mysql
sql_server: "localhost"
sql_database: "ejabberd"
sql_username: "ejabberd"
sql_password: "$jabberdpassworddb"
EOF

cp /opt/ejabberd-19.05/bin/ejabberd.service /usr/lib/systemd/system/ejabberd.service

systemctl enable ejabberd.service

sed -i 's/::/'$ipaddr'/g' /opt/ejabberd/conf/ejabberd.yml

systemctl start ejabberd.service

firewall-cmd --permanent --new-zone=vpn
firewall-cmd --zone=vpn --change-interface=tun0
firewall-cmd --permanent --zone=vpn --add-port={5280,5222}/tcp
firewall-cmd --reload

export PATH=$PATH:/opt/ejabberd-19.05/bin/
ejabberdctl register admin ejabberdexample.com $adminjabberdpasswor

echo "Enter in broser http:// $ipaddr :5280/admin"
echo "You login: admin You password $adminjabberdpasswor"
