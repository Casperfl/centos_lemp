#!/bin/sh

DIRSCRIPT=$(cd $(dirname $0) && pwd)

#for local used in VBox
function install_lemp()
{
    yum remove -y nginx
    yum remove -y php-{fpm,cli,mysqlnd,curl,mbstring,json,xml,gettext,xmlrpc,pear,soap,pdo,opcache}

    yum install -y yum-utils \
      device-mapper-persistent-data \
      lvm2

    yum update -y
    #add EPEL repo
    sudo yum install -y epel-release
    sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

    #wget & unzip
    yum install -y wget unzip

    yum install -y yum-utils

    # Отключение SELinux:
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config && setenforce 0

    #открытие портов
    firewall-cmd --permanent --add-port={80,443,8080}/tcp
    # firewall-cmd --permanent --add-port={20,21,40900-40999}/tcp
    # firewall-cmd --permanent --add-port={25,465,587}/tcp
    firewall-cmd --reload

    #LEMP
#LEMP start
#add nginx repo
echo '[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true' > /etc/yum.repos.d/nginx.repo

    #nginx
    #install nginx from repo
    yum install -y nginx
    #install nginx from direct link
    # yum install -y https://nginx.org/packages/mainline/centos/8/x86_64/RPMS/nginx-1.17.9-1.el8.ngx.x86_64.rpm
    #add to autorun
    systemctl enable nginx
    #start service
    systemctl start nginx

# MariaDB repo
#see https://downloads.mariadb.org/mariadb/repositories/
echo '# MariaDB 10.4 CentOS repository list - created 2020-04-16 00:49 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1' > /etc/yum.repos.d/mariadb.repo
    #install MariaDB from repo
    sudo yum install -y MariaDB-server MariaDB-client && systemctl enable mariadb && systemctl start mariadb

    # MariaDB default repo (not last version)
    # yum install -y mariadb mariadb-server && systemctl enable mariadb && systemctl start mariadb

    ## Install PHP 7.4
    yum --enablerepo=remi-php74 install -y php
    #php-fpm
    yum --enablerepo=remi-php74 install -y php-{fpm,cli,mysqlnd,curl,mbstring,json,xml,gettext,xmlrpc,pear,soap,pdo,opcache}

    systemctl enable php-fpm && systemctl start php-fpm

    #test PHP file
    echo "<?php phpinfo();" > /usr/share/nginx/html/index.php
    # LEMP end
}

function nginx_conf(){
    if [ -d /etc/nginx/conf.d ] ; then
        rm -fr /etc/nginx/conf.d_old
        mv -f /etc/nginx/conf.d /etc/nginx/conf.d_old
    fi
    if [ -f /etc/nginx/nginx.conf ] ; then
        rm -f /etc/nginx/nginx.conf_old
        mv -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf_old
    fi

#    rm -fr /etc/nginx/conf.d
#    rm -f /etc/nginx/nginx.conf

    #copy current conf
    cp -fr $DIRSCRIPT/lemp/nginx/conf.d /etc/nginx
    cp -f $DIRSCRIPT/lemp/nginx/nginx.conf /etc/nginx

    php_conf
}

function php_conf() {
    if [ -f /etc/php.ini ]; then
        if grep -Eq ';user_ini.filename = ".user.ini"' /etc/php.ini; then
            sed -i 's/.*;user_ini.filename = ".user.ini".*/user_ini.filename = ".php.ini"/' /etc/php.ini
        fi
        if grep -Eq ';user_ini.cache_ttl = 300' /etc/php.ini; then
            sed -i 's/.*;user_ini.cache_ttl = 300.*/user_ini.cache_ttl = 300/' /etc/php.ini
        fi
    fi
}

function nginx_conf_local(){
    #create nginx conf dir
    if [ -d /lemp/nginx/conf.d ] ; then
        echo '/lemp/nginx/conf.d found ...'
    else
        echo '/lemp/nginx/conf.d not found create it ...'
        mkdir /lemp/nginx/conf.d
    fi

    if [ "$NGINX_CONF_COPY" = 'COPY' ];
    then
        #copy conf to host
        cp -f /etc/nginx/conf.d/default.conf /lemp/nginx/conf.d/default.conf
        cp -f /etc/nginx/nginx.conf /lemp/nginx/nginx.conf
    fi

    #copy conf to host
    if [ -f /lemp/nginx/conf.d/default.conf ] ; then
        echo '/lemp/nginx/conf.d/default.conf found ...'
    else
        echo '/lemp/nginx/conf.d/default.conf not found create it ...'
        cp -f /etc/nginx/conf.d/default.conf /lemp/nginx/conf.d/default.conf
    fi

    #copy conf to host
    if [ -f /lemp/nginx/nginx.conf ] ; then
        echo '/lemp/nginx/nginx.conf found ...'
    else
        echo '/lemp/nginx/nginx.conf not found create it ...'
        cp -f /etc/nginx/nginx.conf /lemp/nginx/nginx.conf
    fi

    # fix start on VBox
    fix_vbox_startnginx

    if [ "$NGINX_CONF_COPY" = 'LINK' ];
    then

        rm -fr /var/www_old
        rm -fr /etc/nginx/conf.d_old
        rm -f /etc/nginx/nginx.conf_old

        #add default conf
        mv -f /var/www /var/www_old
        mv -f /etc/nginx/conf.d /etc/nginx/conf.d_old
        mv -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf_old

        rm -fr /var/www
        rm -fr /etc/nginx/conf.d
        rm -f /etc/nginx/nginx.conf

        #add default conf
        ln -s /lemp/nginx/conf.d /etc/nginx
        ln -s /lemp/domains /var/www
        ln -sf /lemp/nginx/nginx.conf /etc/nginx/nginx.conf

    fi

    systemctl restart nginx
}


# fix start on VBox
function fix_vbox_startnginx()
{
if [ -f /etc/rc.local ]; then
if grep -Eq '#centos 7 lemp' /etc/rc.local; then
echo "#centos 7 lemp in /etc/rc.local file";
else
cat >> /etc/rc.local << \EOF
#centos 7 lemp
sleep 5
systemctl restart nginx

EOF
echo "#centos 7 lemp added in /etc/rc.local file";
fi
fi
}

echo "How to set lemp?"
option=0
until [ "$option" = "4" ]; do
    echo "  1.) local: set settings & domain path to /lemp dir"
    echo "  2.) remote: all lemp seting is default"
    echo "  q.) Quit"

    echo -n "Enter choice: "
    read option
    echo ""
    case $option in
        1 )

    echo "Share folders on you VBox"
    echo "Structure lepm on host mashine:"
    echo "└───lemp/
        └───domains/
            └───domains1/
                └───index.php
                └───php.ini
        └───mysql/
        └───nginx/
            └───conf.d/
                └───default.conf
            └───nginx.conf
    "

        echo -n "Copy nginx *.conf to /lemp/nginx folders and override it ? (y/n)"
        read item
        case "$item" in
            y|Y) echo "set as local ..."
            NGINX_CONF_COPY='COPY'
            install_lemp
            nginx_conf
            nginx_conf_local
            echo "   Done!"
    systemctl restart nginx
                ;;
            n|N)
            NGINX_CONF_COPY='LINK'
            install_lemp
            nginx_conf
            nginx_conf_local
            echo "   Done!"
    systemctl restart nginx
                exit 0
                ;;
            *) echo "cancel..."
                ;;
        esac
        break;;
        2 )
        NGINX_CONF_COPY='LINK'
        install_lemp
        nginx_conf
    echo "   Done!"
    systemctl restart nginx
        break;;
        'q' ) break;;
        * ) tput setf 4 && echo "invalid option $REPLY" && tput setf 7;;
    esac
done