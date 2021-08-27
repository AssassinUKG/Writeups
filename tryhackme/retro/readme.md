# Retro

![image](https://user-images.githubusercontent.com/5285547/131119489-6feda4b6-44b3-41aa-b3fa-bcb22ece0b84.png)

Room link: https://tryhackme.com/room/retro

Room IP: 10.10.22.148  
*\* for me your's will be different*

## Enumeration


* Nmap 

```
PORT     STATE SERVICE
80/tcp   open  http
3389/tcp open  ms-wbt-server
```

* -sCV

```
PORT     STATE SERVICE       VERSION
80/tcp   open  http          Microsoft IIS httpd 10.0
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD POST
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/10.0
|_http-title: IIS Windows Server
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| rdp-ntlm-info: 
|   Target_Name: RETROWEB
|   NetBIOS_Domain_Name: RETROWEB
|   NetBIOS_Computer_Name: RETROWEB
|   DNS_Domain_Name: RetroWeb
|   DNS_Computer_Name: RetroWeb
|   Product_Version: 10.0.14393
|_  System_Time: 2021-08-27T11:32:23+00:00
| ssl-cert: Subject: commonName=RetroWeb
| Issuer: commonName=RetroWeb
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2021-08-26T11:19:26
| Not valid after:  2022-02-25T11:19:26
| MD5:   9269 09a9 b05b 293f 4a56 f70c 66b0 c167
|_SHA-1: 1c04 1ffc e75d 5f9f f772 12eb 5fcc c808 1b53 a3ed
|_ssl-date: 2021-08-27T11:32:23+00:00; +1s from scanner time.
```
---

* ffuf

```
ffuf -u http://10.10.22.148/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories-lowercase.txt -mc all -fc 404

retro                   [Status: 301, Size: 149, Words: 9, Lines: 2]
```

Scanning the directories shows /retro endpoint

---

* Port 80

http://10.10.22.148/retro

The page shows us lots of posts from a guy called Wade about classic gaming. 
I noticed the site urls are simular to how wordpress are laid out. There is a login link at the bottom that resolves to a wordpress login.  
This confirms my suspicion, time to get wp-scan out. 

```
wpscan --url http://10.10.22.148/retro/

Interesting Finding(s):

[+] Headers
 | Interesting Entries:
 |  - Server: Microsoft-IIS/10.0
 |  - X-Powered-By: PHP/7.1.29
 
[i] User(s) Identified:

[+] wade
 | Found By: Author Posts - Author Pattern (Passive Detection)
```

We can see this is an IIS server (as confirmed in the nmap scan) and wade is the user.  
Let's try to brute his login for wordpress using wpscan

```
wpscan --url http://10.10.22.148/retro/ -U wade -P /usr/share/wordlists/rockyou.txt
```


