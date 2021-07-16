# SP: Christophe (V1.0.2)

![image](https://user-images.githubusercontent.com/5285547/125982486-dc67b351-b5df-4e28-9973-9de19ff391fe.png)

## Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.1 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 14:11:d1:8b:12:0b:78:be:04:4f:74:0d:34:a5:fa:07 (RSA)
|   256 47:69:72:f9:b7:76:33:58:6f:eb:8d:1c:da:9e:b5:c6 (ECDSA)
|_  256 79:08:59:b0:df:ec:13:31:9e:d8:24:54:1d:b6:27:44 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-favicon: Unknown favicon MD5: 551E34ACF2930BF083670FA203420993
|_http-generator: CMS Made Simple - Copyright (C) 2004-2018. All rights reserved.
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Home - Viva La Resistance!
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

## CMS Made Simple
![image](https://user-images.githubusercontent.com/5285547/125982400-47f6763c-774a-4277-b48f-ca0770546ab8.png)

```
searchsploit "cms made simple"
```

![image](https://user-images.githubusercontent.com/5285547/125983683-849c0a35-68be-4a6d-a5d2-66a5aadd3b38.png)


Copy the exploit and run it with python and the variables it needs. 

```
[+] Salt for password found: 932129a6bd8545bd
[+] Username found: christophe
[+] Email found: christophe@christophe.local
[+] Password found: 7908b1494f82ed320b288a0e839bfbc5
```


