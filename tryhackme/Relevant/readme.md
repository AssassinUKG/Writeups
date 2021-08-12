# Revelant

![image](https://user-images.githubusercontent.com/5285547/129174199-a0b07f6d-f4bf-4392-9ac2-cbde55554e84.png)

Room link: https://tryhackme.com/room/relevant

## Enum 

Nmap 

```
nmap -Pn -v 10.10.127.215

PORT     STATE SERVICE
80/tcp   open  http
135/tcp  open  msrpc
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
3389/tcp open  ms-wbt-server

nmap -Pn -v 10.10.127.215 -sVC

PORT     STATE SERVICE        VERSION
80/tcp   open  http           Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD POST
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/10.0
|_http-title: IIS Windows Server
135/tcp  open  msrpc          Microsoft Windows RPC
139/tcp  open  netbios-ssn    Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds   Windows Server 2016 Standard Evaluation 14393 microsoft-ds
3389/tcp open  ms-wbt-server?
| rdp-ntlm-info: 
|   Target_Name: RELEVANT
|   NetBIOS_Domain_Name: RELEVANT
|   NetBIOS_Computer_Name: RELEVANT
|   DNS_Domain_Name: Relevant
|   DNS_Computer_Name: Relevant
|   Product_Version: 10.0.14393
|_  System_Time: 2021-08-12T09:36:22+00:00
| ssl-cert: Subject: commonName=Relevant
| Issuer: commonName=Relevant
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2021-08-11T09:33:28
| Not valid after:  2022-02-10T09:33:28
| MD5:   f94f cb19 c957 e463 6a5a dc04 f356 0d18
|_SHA-1: 61a7 eb4a b3e7 72cf 6619 234f 2cd8 b2fd a709 7148
|_ssl-date: 2021-08-12T09:37:01+00:00; +1s from scanner time.
Service Info: OSs: Windows, Windows Server 2008 R2 - 2012; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: mean: 1h24m01s, deviation: 3h07m51s, median: 0s
| smb-os-discovery: 
|   OS: Windows Server 2016 Standard Evaluation 14393 (Windows Server 2016 Standard Evaluation 6.3)
|   Computer name: Relevant
|   NetBIOS computer name: RELEVANT\x00
|   Workgroup: WORKGROUP\x00
|_  System time: 2021-08-12T02:36:23-07:00
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2021-08-12T09:36:21
|_  start_date: 2021-08-12T09:34:06

```
