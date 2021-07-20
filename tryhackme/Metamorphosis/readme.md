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

## Rsync Port 873

```
nc -vn 10.10.177.2 873
(UNKNOWN) [10.10.177.2] 873 (rsync) open
@RSYNCD: 31.0        <--- You receive this banner with the version from the server
@RSYNCD: 31.0        <--- Then you send the same info
#list                <--- Then you ask the sever to list
Conf            All Confs <--- The server starts enumerating
@RSYNCD: EXIT         <--- Sever closes the connection
```

