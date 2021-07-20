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

In webapp.ini we can see a user and password for "tom".

Post files

```
rsync -av testfile.txt rsync://tom@10.10.55.140/Conf

sending incremental file list

sent 63 bytes  received 12 bytes  150.00 bytes/sec
total size is 7  speedup is 0.09
```

