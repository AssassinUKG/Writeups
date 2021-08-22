# Uranium CTF 

![image](https://user-images.githubusercontent.com/5285547/130351555-c19838de-5d73-404a-9f39-58046e63a6e6.png)

Room Link: https://tryhackme.com/room/uranium

## Room Info

We have reached out a account one of the employees
hakanbey

In this room, you will learn about one of the phishing attack methods. I tried to design a phishing room (cronjobs and services) as much as I could.

Special Thanks to kral4 for helping us to make this room

Note: Please do not attack the given twitter account.

Machine IP: 10.10.208.199

Twitter Room info: 

![image](https://user-images.githubusercontent.com/5285547/130351618-ac5d9c8c-b93c-44a7-8b3e-f90f6528fc49.png)


## Enum

Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
25/tcp open  smtp
80/tcp open  http
```

## Port 25 SMTP 

Using the infomation from the room descrption, it was clear we needed to send an email with a filename called "application" this should then give us back a reverse shell. 

I made a python script to help with the email sending due to the TLS version not being supported in sendEmail in bash. 

Script: 

![image](https://user-images.githubusercontent.com/5285547/130352359-01b7f506-12d9-4b09-b1d8-3952cf997767.png)

# User

Looking around the system we see a file in logs that looks out of place. 

```
/var/log/hakanbey_network_log.pcap
```

Transfering this to my machine, i use wireshark to go over the file. 

Wireshark

![image](https://user-images.githubusercontent.com/5285547/130352595-0d944e8d-5665-4b46-822c-0b50d9fe90cd.png)

Using the password for the chat app we can get the password for hakanbey

![image](https://user-images.githubusercontent.com/5285547/130352637-256f577c-181c-4837-8aff-a105e7b03c5d.png)

## Hakanbey (sudo -l)

![image](https://user-images.githubusercontent.com/5285547/130352655-3fc2780f-429b-438d-9232-94db73adeb77.png)

This shows we can swap to karl using /bin/bash

```
sudo -u kral4 /bin/bash
```

## kral4 (email) 

Checking the email in /var/mail we can see a message to kral4

```
cat kral4 
From root@uranium.thm  Sat Apr 24 13:22:02 2021
Return-Path: <root@uranium.thm>
X-Original-To: kral4@uranium.thm
Delivered-To: kral4@uranium.thm
Received: from uranium (localhost [127.0.0.1])
        by uranium (Postfix) with ESMTP id C7533401C2
        for <kral4@uranium.thm>; Sat, 24 Apr 2021 13:22:02 +0000 (UTC)
Message-ID: <841530.943147035-sendEmail@uranium>
From: "root@uranium.thm" <root@uranium.thm>
To: "kral4@uranium.thm" <kral4@uranium.thm>
Subject: Hi Kral4
Date: Sat, 24 Apr 2021 13:22:02 +0000
X-Mailer: sendEmail-1.56
MIME-Version: 1.0
Content-Type: multipart/related; boundary="----MIME delimiter for sendEmail-992935.514616878"

This is a multi-part message in MIME format. To properly display this message you need a MIME-Version 1.0 compliant Email program.

------MIME delimiter for sendEmail-992935.514616878
Content-Type: text/plain;
        charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

I give SUID to the nano file in your home folder to fix the attack on our  index.html. Keep the nano there, in case it happens again.

------MIME delimiter for sendEmail-992935.514616878--
```

This tells me a binary Nano is left in the home folder we can use with SUID.  
So I copy nano to my home folder as kral4

```
cp /bin/nano /home/kral4/nano
```

![image](https://user-images.githubusercontent.com/5285547/130352801-28694d94-47f7-49e3-ab18-e304a757cf9c.png)

## SUID

Scanning the local system we find a SUID binary that may help us here to edit the index.html page. 

```
find / -perm -u=s 2>/dev/null
```

At the end of the list we find "/bin/dd"

![image](https://user-images.githubusercontent.com/5285547/130369284-7735f420-3cdb-4f4c-82d8-ad5047d711b0.png)

Using this we can edit the index.html page. 

```
echo "testing" | dd of=/var/www/html/index.html
```

After editing the file we see the SUID bit has been applied to the nano Binary. 

![image](https://user-images.githubusercontent.com/5285547/130369358-6c117e8b-f385-4c45-8c7f-0dfcee3266f1.png)

Checking GTFObins again we can use the SUID from nano to get the last flags

![image](https://user-images.githubusercontent.com/5285547/130369372-ff561416-7eb9-43ab-af23-b5de60b0accc.png)


```
./nano /root/root.txt
./nano /var/www/html/web_flag.txt
```
