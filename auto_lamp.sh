#! /bin/bash
#Auto Install LAMP PROGRAM
#By Author GuoKang

#Httpd define path variable
H_FILES=httpd-2.2.31.tar.gz
H_FILES_DIR=httpd-2.2.31
H_URL=http://mirrors.cnnic.cn/apache/httpd/
H_PREFIX=/usr/local/apache2/

#Mysql define path variable
M_FILES=mysql-5.5.20-linux2.6-x86_64.tar.gz
M_FILES_DIR=mysql-5.5.20-linux2.6-x86_64
M_URL=http://cdn.mysql.com/archives/mysql-5.5/
M_PREFIX=/usr/local/mysql/

#PHP define path variable
P_FILES=php-5.5.34.tar.gz
P_FILES_DIR=php-5.5.34
P_URL=http://cn2.php.net/distributions/php-5.5.34.tar.gz
P_PREFIX=/usr/local/php5/

if [ -z "$1" ];then
        echo -e "\033[36mPlease Select the Install Menu as Follow:\033[0m"
        echo -e "\033[32m1)编译安装Apache服务器\033[1m"
        echo "2)编译安装Mysql服务器"
	echo "3)编译安装PHP服务器"
	echo "4)配置index.php并启动LAMP服务"
	echo -e "\033[31mUsage: { /bin/sh `basename $0` 1|2|3|4|help}\033[0m"
	exit
fi

if [[ "$1" -eq "1" ]];then
   wget -c $H_URL/$H_FILES && tar -zxvf $H_FILES && cd $H_FILES_DIR;./configure --prefix=$H_PREFIX

   if [ $? -eq 0 ];then
      make && make install
      echo -e "\033[32m---------------------------------------------------\033[0m"
      echo -e "\033[32mThe service of Apache httpd install successfully.\033[0m"
   else
      echo -e "\033[32mThe service of Apache httpd install failed,Please check configuration...\033[0m"
      exit
   fi
fi

#Auto Install Mysql
if [[ "$1" -eq "2" ]];then
   wget -c $M_URL/$M_FILES && tar -zxvf $M_FILES
   useradd -s /sbin/nologin -M mysql 
   mv mysql-5.5.20-linux2.6-x86_64 /usr/local/mysql
   mkdir –p /data/mysql；chown –R mysql /data/mysql
   cd /usr/local/mysql/
   ./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
   cd /usr/local/mysql/support-files/
   cp my-large.cnf /etc/my.cnf
   cp mysql.server /etc/init.d/mysqld
   grep "^basedir=$" /etc/init.d/mysqld |sed -i 's/basedir\=/basedir\=\/usr\/local\/mysql/g' /etc/init.d/mysqld
   grep "^datadir=$" /etc/init.d/mysqld |sed -i 's/datadir\=/datadir\=\/data\/mysql/g' /etc/init.d/mysqld
   chkconfig --add mysqld
   chkconfig mysqld on

   if [ $? -eq 0 ];then
      make && make install
      echo -e "\033[32m---------------------------------------------------\033[0m"
      echo -e "\033[32mThe service of Mysql install successfully.\033[0m"
   else
      echo -e "\033[32mThe service of Mysql install failed,Please check configuration...\033[0m"
      exit
   fi
fi

#Auto Install PHP Server
if [[ "$1" -eq "3" ]];then
   wget -c $P_URL && tar -zxvf $P_FILES && cd $P_FILES_DIR;yum install -y libxml2-devel;./configure --prefix=$P_PREFIX --with-config-file-path=$P_PREFIX/etc --with-mysql=$M_PREFIX --with-apxs2=$H_PREFIX/bin/apxs

   if [ $? -eq 0 ];then
      make && make install
      echo -e "\033[32m---------------------------------------------------\033[0m"
      echo -e "\033[32mThe service of PHP install successfully.\033[0m"
   else
      echo -e "\033[32mThe service of PHP install failed,Please check configuration...\033[0m"
      exit
   fi
fi

#configure php configuration
if [[ "$1" -eq "4" ]];then
   
   sed -i 's/DirectoryIndex index\.html/DirectoryIndex index\.php index\.html/g' $H_PREFIX/conf/httpd.conf
   $H_PREFIX/bin/apachectl start
   echo "AddType  application/x-httpd-php .php" >>$H_PREFIX/conf/httpd.conf
   IP=`ifconfig |grep Bcast: |awk -F: '{print $2}'|awk '{print $1}'`
   echo "You can access http://$IP/index.php"

cat >$H_PREFIX/htdocs/index.php <<EOF
<?php
phpinfo();
?>
EOF
fi


