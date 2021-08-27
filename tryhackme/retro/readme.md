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

While leaving the wpscan running, I checked out the web app further, where i noticed a strange comment. 

![image](https://user-images.githubusercontent.com/5285547/131134191-2fcbcebe-f271-4dd7-bbf4-7959c58dff63.png)

---

* Reverse shell

After logging into the admin portal, I first checked to see if I could edit a theme template, which I could. 
Editing the 404.php page with a php reverse shell (windows version: https://raw.githubusercontent.com/ivan-sincek/php-reverse-shell/master/src/php_reverse_shell.php) we can get a shell. 

Call after editing. 

```
http://10.10.22.148/retro/wp-content/themes/90s-retro/404.php
```

whoami?

![image](https://user-images.githubusercontent.com/5285547/131135864-c7d8b488-9f84-4237-85a1-a83c8b194b01.png)

--- 

## User

Looking around the system I first check the wp-config.php file for any passwords. 

```
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wordpress567');

/** MySQL database username */
define('DB_USER', 'wordpressuser567');

/** MySQL database password */
define('DB_PASSWORD', 'YSPgW[%C.mQE');

/** MySQL hostname */
define('DB_HOST', 'localhost');
```

Not finding much else I remmebered we have another open port 3389. 

Info on port 3389:

Time to test the creds we have for wade. 

```
xfreerdp /u:[domain\]<username> /p:<password> /v:<IP>
```

We're in! 

![image](https://user-images.githubusercontent.com/5285547/131137667-ad9fef1c-4974-44e2-82bc-9ac48fb2d0d2.png)


## Root

After getting the user flag, I noticed the recycle bin had something in, I dragged this to the desktop and seen a file called. 
```hhupd.exe```

Gooling the file lead to this article: https://www.zerodayinitiative.com/blog/2019/11/19/thanksgiving-treat-easy-as-pie-windows-7-secure-desktop-escalation-of-privilege

We can check out the certificate and due to some misconfigurations on the way the UI handles opening a link, we effectivly run as system. 

Run the app and click the show more information link. 

![image](https://user-images.githubusercontent.com/5285547/131138533-435cc689-7421-4399-bf6c-0b082b6eafc9.png)

Then click on Issued by: VeriSign hyperlink to then open IE browser. Now choose save as and open a new UI (as system),

![image](https://user-images.githubusercontent.com/5285547/131138585-4550c94c-f265-4d3d-996c-3aa7a0bad387.png)

This failed for me, so I had to look for another way around

![image](https://user-images.githubusercontent.com/5285547/131140375-94acf104-cbd6-47e7-ae9d-309ee9bce9a1.png)

After more enumeration I found the system is vunerable to the exploit: https://github.com/jas502n/CVE-2019-1388

Copying the exploit to the box and running it gives us admin instantly. 

![image](https://user-images.githubusercontent.com/5285547/131141091-7462ac52-71e4-4576-8d5c-f07b30fc468e.png)

That's the end of the box. Thanks for reading! 
