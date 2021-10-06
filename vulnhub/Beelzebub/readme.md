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


## User

## Root

## Conclusion
