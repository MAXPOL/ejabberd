# ejabberd

Web-interface: http://you_domain:5280/admin

/opt/ejabberd-26.03/bin/ejabberdctl registered_users YOU_DOMAIN # checking domain existence

/opt/ejabberd-26.03/bin/ejabberdctl register USER DOMAIN PASSWORD # add new user

Be sure to add the first user, admin, with your domain. 
For example: /opt/ejabberd-26.03/bin/ejabberdctl register admin test.com qwerty

Recommend use client: Pidgin or maybe Gajim.

If you want use cryptography mode, create cert and change config file: 

openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/CN=test.com" -keyout /opt/ejabberd/conf/certs/privkey.pem -out /opt/ejabberd/conf/certs/fullchain.pem

cat /opt/ejabberd/conf/certs/fullchain.pem /opt/ejabberd/conf/certs/privkey.pem > /opt/ejabberd/conf/certs/ejabberd.pem

Change in ejabberd.yml: "starttls: false" on  "starttls: true"
