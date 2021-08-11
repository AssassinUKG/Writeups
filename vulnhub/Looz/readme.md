# Looz

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

I only got redirected back to port 80, so tried to brute force the directroys. 

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


