# Sweettooth inc.

![image](https://user-images.githubusercontent.com/5285547/126913536-e9fa3f39-06fa-4a83-aaab-250e553042c8.png)
Link: https://tryhackme.com/room/sweettoothinc

## Desc


## Nmap

```
PORT     STATE SERVICE VERSION
111/tcp  open  rpcbind 2-4 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|   100000  3,4          111/udp6  rpcbind
|   100024  1          34479/tcp6  status
|   100024  1          40714/udp   status
|   100024  1          46300/tcp   status
|_  100024  1          49237/udp6  status
2222/tcp open  ssh     OpenSSH 6.7p1 Debian 5+deb8u8 (protocol 2.0)
| ssh-hostkey: 
|   1024 b0:ce:c9:21:65:89:94:52:76:48:ce:d8:c8:fc:d4:ec (DSA)
|   2048 7e:86:88:fe:42:4e:94:48:0a:aa:da:ab:34:61:3c:6e (RSA)
|   256 04:1c:82:f6:a6:74:53:c9:c4:6f:25:37:4c:bf:8b:a8 (ECDSA)
|_  256 49:4b:dc:e6:04:07:b6:d5:ab:c0:b0:a3:42:8e:87:b5 (ED25519)
8086/tcp open  http    InfluxDB http admin 1.3.0
|_http-title: Site doesn't have a title (text/plain; charset=utf-8).
```

enum gave up some creds
http://10.10.219.78:8086/debug/requests

![image](https://user-images.githubusercontent.com/5285547/126914960-41ce25e3-5324-43da-b78b-e4c14de0d037.png)

creds
```
o5yY6yya:Spring2015
bzV5WTZ5eWE6U3ByaW5nMjAxNQ== (base64)
```

## Directory brute

```
gobuster dir -u http://10.10.219.78:8086/  -w  /usr/share/seclists/Discovery/Web-Content/raft-large-directories-lowercase.txt -t 30 

/status               (Status: 204) [Size: 0]
/query                (Status: 401) [Size: 55]
/ping                 (Status: 204) [Size: 0] 
/write                (Status: 405) [Size: 19]
```
