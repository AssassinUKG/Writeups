# Nax

## Enumeration

Nmap 

```
PORT     STATE SERVICE
22/tcp   open  ssh
25/tcp   open  smtp
80/tcp   open  http
389/tcp  open  ldap
443/tcp  open  https
5667/tcp open  unknown

PORT     STATE SERVICE    VERSION
22/tcp   open  ssh        OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 62:1d:d9:88:01:77:0a:52:bb:59:f9:da:c1:a6:e3:cd (RSA)
|   256 af:67:7d:24:e5:95:f4:44:72:d1:0c:39:8d:cc:21:15 (ECDSA)
|_  256 20:28:15:ef:13:c8:9f:b8:a7:0f:50:e6:2f:3b:1e:57 (ED25519)
25/tcp   open  smtp       Postfix smtpd
|_smtp-commands: ubuntu.localdomain, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN, 
| ssl-cert: Subject: commonName=ubuntu
| Issuer: commonName=ubuntu
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2020-03-23T23:42:04
| Not valid after:  2030-03-21T23:42:04
| MD5:   9b85 15ad 46a7 016e 319a 033d 7d96 edbe
|_SHA-1: c488 0c2d a210 38dd cfbb a299 4a2a b69c 63fd 2cdc
|_ssl-date: TLS randomness does not represent time
80/tcp   open  http       Apache httpd 2.4.18 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
389/tcp  open  ldap       OpenLDAP 2.2.X - 2.3.X
443/tcp  open  ssl/https  Apache/2.4.18 (Ubuntu)
| http-methods: 
|_  Supported Methods: GET HEAD POST
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: 400 Bad Request
| ssl-cert: Subject: commonName=192.168.85.153/organizationName=Nagios Enterprises/stateOrProvinceName=Minnesota/countryName=US
| Issuer: commonName=192.168.85.153/organizationName=Nagios Enterprises/stateOrProvinceName=Minnesota/countryName=US
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha1WithRSAEncryption
| Not valid before: 2020-03-24T00:14:58
| Not valid after:  2030-03-22T00:14:58
| MD5:   636c ab0f 6399 34e3 b6de e6e2 b294 d4ef
|_SHA-1: 80cd 2e1b 110f 1b5f 1943 1b3f c218 71e7 8b98 6801
|_ssl-date: TLS randomness does not represent time
| tls-alpn: 
|_  http/1.1
5667/tcp open  tcpwrapped

```


## Port 80


![image](https://user-images.githubusercontent.com/5285547/137701296-5fb66fbe-46ac-44e1-a029-640f89142fc5.png)

```
Welcome to elements.
Ag - Hg - Ta - Sb - Po - Pd - Hg - Pt - Lr
```

These letters match to the periodic table. 

![image](https://user-images.githubusercontent.com/5285547/137705641-7f72a8fa-6c3c-41b1-b96f-7a18a5e62b19.png)

```
Ag = 47
Hg = 80
Ta = 73
Sb = 51
Po = 84
Pd = 46
Hg = 80
Pt = 78
Lr = 103
```

Cyberchef

![image](https://user-images.githubusercontent.com/5285547/137706326-f20c94d6-6b8f-442e-8384-b68c8fe4011f.png)


Downloading the image we see and going here to decrypt: https://www.bertnase.de/npiet/npiet-execute.php

![image](https://user-images.githubusercontent.com/5285547/137706960-043e6f39-f2ef-4753-ba05-2345e03345f4.png)


```
nagiosadmin
n3p3UQ&9BjLp4$7uhWdY
```
