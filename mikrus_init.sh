#!/bin/bash

# sudo /etc/init.d/saslauthd stop
sudo service saslauthd stop
sudo apt-get remove -y sasl2-bin

sudo service xinetd stop
sudo apt-get remove -y xinetd

sudo service apache2 stop
sudo apt-get purge -y apache2

sudo apt-get install -y nginx

sudo pip3 install uwsgi
sudo pip3 install virtualenv

#django-admin.py startproject mysite
git clone https://github.com/szwagier90/mikr_us_453.git mikrus
cd mikrus
virtualenv venv
source venv/bin/activate

cp mysite/local_settings.py.template mysite/local_settings.py

pip3 install -r deploy_requirements.txt
# pip3 install Django | pip3 install -r requirements
# pip3 install uwsgi | pip3 install -r requirements

wget -P mysite/ https://raw.githubusercontent.com/nginx/nginx/master/conf/uwsgi_params

sudo bash -c 'cat > /etc/nginx/sites-available/mysite_nginx.conf' << EOF
# mysite_nginx.conf

# the upstream component nginx needs to connect to
upstream django {
    server unix:///home/szwagier/mikrus/mysite/mysite.sock; # for a file socket
    # server 127.0.0.1:8001; # for a web port socket (we'll use this first)
}

# configuration of the server
server {
    # the port your site will be served on
    listen      [::]:80;
    listen      80;
    # the domain name it will serve for
    server_name uw453.mikr.us; # substitute your machine's IP address or FQDN
    charset     utf-8;

    # max upload size
    client_max_body_size 75M;   # adjust to taste

    # Django media
    location /media  {
        alias /path/to/your/mysite/media;  # your Django project's media files - amend as required
    }

    location /static {
        alias /path/to/your/mysite/static; # your Django project's static files - amend as required
    }

    # Finally, send all non-media requests to the Django server.
    location / {
        uwsgi_pass  django;
        include     /home/szwagier/mikrus/mysite/uwsgi_params; # the uwsgi_params file you installed
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/mysite_nginx.conf /etc/nginx/sites-enabled/

sudo bash -c 'cat > mysite/mysite_uwsgi.ini' << EOF
# mysite_uwsgi.ini file
[uwsgi]

# Django-related settings
# the base directory (full path)
chdir           = /home/szwagier/mikrus
# Django's wsgi file
module          = mysite.wsgi
# the virtualenv (full path)
home            = /home/szwagier/mikrus/venv

# process-related settings
# master
master          = true
# maximum number of worker processes
processes       = 5
# the socket (use the full path to be safe
socket          = /home/szwagier/mikrus/mysite/mysite.sock
# ... with appropriate permissions - may be needed
chmod-socket    = 664
# clear environment on exit
vacuum          = true
EOF

sudo chown :www-data mysite

sudo mkdir -p /etc/uwsgi/vassals
sudo ln -s /home/szwagier/mikrus/mysite/mysite_uwsgi.ini /etc/uwsgi/vassals/
sudo rm /etc/nginx/sites-enabled/default

sudo service nginx restart
sudo /usr/local/bin/uwsgi --emperor /etc/uwsgi/vassals --uid www-data --gid www-data --daemonize /var/log/uwsgi-emperor.log
sudo sed -i -e '$i /usr/local/bin/uwsgi --emperor /etc/uwsgi/vassals --uid www-data --gid www-data --daemonize /var/log/uwsgi-emperor.log' /etc/rc.local

