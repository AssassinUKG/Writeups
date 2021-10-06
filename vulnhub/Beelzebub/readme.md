# Beelzebub

Link: https://www.vulnhub.com/entry/beelzebub-1,742/  
Level: Easy  
Credits:  Shaurya Sharma  

## Description

Difficulty: Easy

You have to enumerate as much as you can and don't forget about the Base64.  
For hints add me on  
Twitter- ShauryaSharma05  

---

## Enumeration

Nmap 

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
```

Ffuf



Nikto



```
http://192.168.1.175/phpinfo.php
http://192.168.1.175/phpmyadmin/
```

![image](https://user-images.githubusercontent.com/5285547/136195726-5cfe5b93-818b-4232-9e71-645d63e7aca9.png)

Encoding to MD5

```
$ echo -n "beelzebub"  | md5sum
d18e1e22becbd915b45e0e655429d487
```

New path to fuzz

```
http://IP/d18e1e22becbd915b45e0e655429d487/

ffuf -u http://192.168.1.175/d18e1e22becbd915b45e0e655429d487/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-lowercase-2.3-medium.txt  -mc all -fc 404,403 -ic  -c

wp-content              [Status: 301, Size: 352, Words: 20, Lines: 10]
wp-includes             [Status: 301, Size: 353, Words: 20, Lines: 10]
wp-admin                [Status: 301, Size: 350, Words: 20, Lines: 10]
```

## User

## Root

## Conclusion
