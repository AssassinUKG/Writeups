# Writeup HackTheBox

![image](https://user-images.githubusercontent.com/5285547/124397537-3e527400-dd08-11eb-9e21-914eb4ef2ea0.png)

## Nmap 

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.4p1 Debian 10+deb9u6 (protocol 2.0)
80/tcp open  http    Apache httpd 2.4.25 ((Debian))
```

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.4p1 Debian 10+deb9u6 (protocol 2.0)
| ssh-hostkey: 
|   2048 dd:53:10:70:0b:d0:47:0a:e2:7e:4a:b6:42:98:23:c7 (RSA)
|   256 37:2e:14:68:ae:b9:c2:34:2b:6e:d9:92:bc:bf:bd:28 (ECDSA)
|_  256 93:ea:a8:40:42:c1:a8:33:85:b3:56:00:62:1c:a0:ab (ED25519)
80/tcp open  http    Apache httpd 2.4.25 ((Debian))
| http-robots.txt: 1 disallowed entry 
|_/writeup/
|_http-title: Nothing here yet.
```


## Robots.txt

![image](https://user-images.githubusercontent.com/5285547/124394688-72259d80-dcf8-11eb-879b-2e092ef3c570.png)


## /writeup/

![image](https://user-images.githubusercontent.com/5285547/124394807-e6f8d780-dcf8-11eb-9399-2ca31be26055.png)

Checking the source code of the page we can see the CMS being used here. 

Redacted source code http://10.10.10.138/writeup/
```
<meta name="Generator" content="CMS Made Simple - Copyright (C) 2004-2019. All rights reserved." />
```

I quickly found this exploit online: https://www.exploit-db.com/exploits/46635

Downloading, editing and running the exploit gave me some creds. 

Python3 version (Edited by me): https://github.com/AssassinUKG/Writeups/blob/main/hackthebox/dare/writeup/cmsExploit/cms.py

```
cms.py -u http://10.10.10.138/writeup/ --crack -w /usr/share/SecLists/Passwords/rockyou.txt
```
![image](https://user-images.githubusercontent.com/5285547/124398557-33024700-dd0e-11eb-8b70-9aac12e92f52.png)


## User

Using the found credentials we can now ssh onto the box

```
ssh jkr@10.10.10.138
raykayjay9
```




