# ejabberd

Web-interfaces: http://domain:5280/admin

/opt/ejabberd-26.03/bin/ejabberdctl registered_users YOU_DOMAIN # checking domain existence

/opt/ejabberd-26.03/bin/ejabberdctl register USER DOMAIN PASSWORD # add new user

Be sure to add the first user, admin, with your domain. 
For example: /opt/ejabberd-26.03/bin/ejabberdctl register admin test.com qwerty

Recommend use client: Gajim
