### Fusion Crop

![image](https://user-images.githubusercontent.com/5285547/122137683-1f656e00-ce3d-11eb-9e38-8ad66e83b6ee.png)

[Room Link](https://tryhackme.com/room/fusioncorp)  
Created by: [MrSeth6797](https://tryhackme.com/p/MrSeth6797)

## Enumeration

### Nmap

A quick namp scan realeals a lot of open ports.

```
PORT      STATE SERVICE
53/tcp    open  domain
80/tcp    open  http
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
3389/tcp  open  ms-wbt-server
5985/tcp  open  wsman
9389/tcp  open  adws
49666/tcp open  unknown
49668/tcp open  unknown
49673/tcp open  unknown
49674/tcp open  unknown
49679/tcp open  unknown
49691/tcp open  unknown
49698/tcp open  unknown
```


```
nmap -n -sV --script "ldap* and not brute" 10.10.212.7
```

port 3268 looks good
