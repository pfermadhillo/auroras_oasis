## readme


### commands i ran

 sudo ln -s /etc/nginx/sites-available/auroras /etc/nginx/sites-enabled/auroras

sudo chmod 777 /etc/nginx/sites-available/auroras
sudo vim /etc/nginx/sites-available/auroras
sudo chmod 644 /etc/nginx/sites-available/auroras ; sudo service nginx restart


sudo service nginx restart


### auth

phone has link to account creation and textField for code insert 
	[a-z0-9] no upper or special

account creation website has user input email and password

once logged in, they gen a code

code placed into phone, sends code to website

website returns legit code (base64 craycray) for that handset