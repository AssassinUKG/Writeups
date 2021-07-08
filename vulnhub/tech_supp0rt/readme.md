# Tech Supp0rt
Link: https://www.vulnhub.com/entry/tech_supp0rt-1,708/
Box: Easy

## Nmap 

```
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
139/tcp open  netbios-ssn
445/tcp open  microsoft-ds
```
```
PORT    STATE SERVICE     VERSION
22/tcp  open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 10:8a:f5:72:d7:f9:7e:14:a5:c5:4f:9e:97:8b:3d:58 (RSA)
|   256 7f:10:f5:57:41:3c:71:db:b5:5b:db:75:c9:76:30:5c (ECDSA)
|_  256 6b:4c:23:50:6f:36:00:7c:a6:7c:11:73:c1:a8:60:0c (ED25519)
80/tcp  open  http        Apache httpd 2.4.18 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: -1h49m59s, deviation: 3h10m30s, median: 0s
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)
|   Computer name: techsupport
|   NetBIOS computer name: TECHSUPPORT\x00
|   Domain name: \x00
|   FQDN: techsupport
|_  System time: 2021-07-08T16:06:14+05:30
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2021-07-08T10:36:14
|_  start_date: N/A
```

## Nikto 

```
- Nikto v2.1.6
---------------------------------------------------------------------------
+ Target IP:          192.168.1.106
+ Target Hostname:    192.168.1.106
+ Target Port:        80
+ Start Time:         2021-07-08 11:14:52 (GMT1)
---------------------------------------------------------------------------
+ Server: Apache/2.4.18 (Ubuntu)
+ The anti-clickjacking X-Frame-Options header is not present.
+ The X-XSS-Protection header is not defined. This header can hint to the user agent to protect against some forms of XSS
+ The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type
+ No CGI Directories found (use '-C all' to force check all possible dirs)
+ Apache/2.4.18 appears to be outdated (current is at least Apache/2.4.37). Apache 2.2.34 is the EOL for the 2.x branch.
+ Server may leak inodes via ETags, header found with file /, inode: 2c39, size: 5c367f4428b1f, mtime: gzip
+ Allowed HTTP Methods: GET, HEAD, POST, OPTIONS 
+ /phpinfo.php: Output from the phpinfo() function was found.
+ OSVDB-3092: /test/: This might be interesting...
+ OSVDB-3233: /phpinfo.php: PHP is installed, and a test script which runs phpinfo() was found. This gives a lot of system information.
+ OSVDB-3233: /icons/README: Apache default file found.
+ 7915 requests: 0 error(s) and 10 item(s) reported on remote host
+ End Time:           2021-07-08 11:15:44 (GMT1) (52 seconds)
---------------------------------------------------------------------------
```

## Gobuster

```
/index.html           (Status: 200) [Size: 11321]
/wordpress            (Status: 301) [Size: 318] [--> http://192.168.1.106/wordpress/]
/test                 (Status: 301) [Size: 313] [--> http://192.168.1.106/test/]     
/phpinfo.php          (Status: 200) [Size: 94955]                                    
/server-status        (Status: 403) [Size: 278]
```

## Enum4linux

Redacted some infos
```
Sharename       Type      Comment
---------       ----      -------
print$          Disk      Printer Drivers
websvr          Disk      
 IPC$            IPC       IPC Service (TechSupport server (Samba, Ubuntu))
SMB1 disabled -- no workgroup available

S-1-22-1-1000 Unix User\scamsite (Local User)
S-1-5-21-2071169391-1069193170-3284189824-513 TECHSUPPORT\None (Domain Group)
```

## Smbclient

```
smbclient -L 192.168.1.106                                                                                1 ⨯
Enter WORKGROUP\ac1d's password: 

        Sharename       Type      Comment
        ---------       ----      -------
        print$          Disk      Printer Drivers
        websvr          Disk      
        IPC$            IPC       IPC Service (TechSupport server (Samba, Ubuntu))
SMB1 disabled -- no workgroup available
```

Let's check out that share.

```smbclient \\\\192.168.1.106\\websvr```

![image](https://user-images.githubusercontent.com/5285547/124909104-f9695e80-dfe1-11eb-890e-b42198883a53.png)

