#!/bin/bash -e

wpuser='admin'
wpuserpass='admin'

clear

echo "================================================================="
echo "Awesome WordPress Installer!!"
echo "================================================================="

# accept user input for the databse name
echo "Project name: "
read -e pname

# accept user input for the databse name
echo "Database Name: (a new DB will be create)"
read -e dbname

# local
echo "Local (d/f)"
read -e lang

if [ "$lang" == d ] ; then
	lang=de_DE 
else
	lang=fr_FR
fi

# add a simple yes/no confirmation before we proceed
echo "================================================================="
echo ""
echo "Are you in /Sites folder?"
echo ""
echo "Are your DB User/Pass root/root?"
echo ""
echo "================================================================="
echo "Run Install? (y/n)"
read -e run

# if the user didn't say no, then go ahead an install
if [ "$run" == n ] ; then
exit
else

mysql --host=localhost -uroot -proot -e "CREATE DATABASE IF NOT EXISTS $dbname CHARACTER SET utf8 COLLATE utf8_general_ci"

# create dir and open it
mkdir "$pname"
cd "$pname"

# download the WordPress core files
wp core download --locale="$lang"

# create the wp-config file
wp core config --dbname=$dbname --dbuser=root --dbpass=root

wp core install --url="$pname.local" --title="$pname" --admin_user="$wpuser" --admin_password="$wpuserpass" --admin_email="user@example.org"

# remove themes
wp theme delete twentyfourteen
wp theme delete twentythirteen

# delete akismet and hello dolly
wp plugin delete akismet
wp plugin delete hello

# install plugins and activace
wp plugin install timber-library --activate
wp plugin install wp-limit-login-attempts --activate
wp plugin install ninja-forms --activate
wp plugin install w3-total-cache --activate
echo "Plugins installed"

# install the sprig twig starter theme
# wp theme install https://github.com/zach-adams/sprig.git --activate
cd wp-content/themes/
git clone https://github.com/olefredrik/FoundationPress.git
cd FoundationPress
npm install
echo "Theme installed"

# create some pages
wp post create --post_type=page --post_title='Home' --post_status=publish
wp post create --post_type=page --post_title='About' --post_status=publish
wp post create --post_type=page --post_title='Team' --post_status=publish
wp post create --post_type=page --post_title='Contact' --post_status=publish
echo "Dummy pages created"

# Permalinks to /%postname%/
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard
echo "Permalinks structure setted"


clear

echo "================================================================="
echo "Installation is complete."
echo ""
echo "Local URL: $pname.local"
echo "Project folder: $pname"
echo " "
echo "Username: $wpuser"
echo "Password: $wpuserpass"
echo ""
echo "================================================================="

fi
