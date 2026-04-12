#!/bin/bash

echo "Enter ip address your server:"
read ipaddr

echo "Enter domain name for XMPP server:"
read domain

echo "Enter new password database:"
read passworddb

echo "Enter new password jabber user database:"
read jabberdpassworddb

echo "Enter new admin password for ejabberd:"
read adminjabberdpassword

# Добавляем домен в /etc/hosts
echo "$ipaddr $domain" >> /etc/hosts

systemctl enable firewalld
systemctl start firewalld

yum install -y wget nano mariadb mariadb-server

systemctl enable mariadb
systemctl start mariadb

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
mysql -u root -p$passworddb ejabberd < /opt/ejabberd-26.03/lib/ejabberd-26.3.0/priv/sql/mysql.sql

# Простая конфигурация без шифрования
cat > /opt/ejabberd/conf/ejabberd.yml <<EOF

hosts:
  - "$domain"

listen:
  - port: 5222
    module: ejabberd_c2s
    starttls: false
    starttls_required: false
  - port: 5280
    module: ejabberd_http
    web_admin: true

auth_method: sql
sql_type: mysql
sql_server: "localhost"
sql_database: "ejabberd"
sql_username: "ejabberd"
sql_password: "$jabberdpassworddb"

acl:
  admin:
    user:
      - "admin@$domain"

access_rules:
  admin:
    allow: admin
  register:
    allow: all
EOF

cp /opt/ejabberd-26.03/bin/ejabberd.service /usr/lib/systemd/system/ejabberd.service

systemctl enable ejabberd
systemctl start ejabberd

firewall-cmd --permanent --add-port=5222/tcp
firewall-cmd --permanent --add-port=5280/tcp
firewall-cmd --reload

export PATH=$PATH:/opt/ejabberd-26.03/bin/

echo "=========================================="
echo "Ready! Open browser: http://$ipaddr:5280/admin"
echo "=========================================="
