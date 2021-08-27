# Wordpress CVE-2021-29447

![image](https://user-images.githubusercontent.com/5285547/131180504-779a6218-3cd1-4220-aceb-3ed5e7accef6.png)

Room link: https://tryhackme.com/room/wordpresscve202129447

IP: 10.10.65.126


## Enumeration

nmap

```
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
3306/tcp open  mysql
```


ffuf intresting results

```
http://10.10.65.126/
http://10.10.65.126/?attachment_id=5
http://10.10.65.126/wp-login.php
```

wpscan results

![image](https://user-images.githubusercontent.com/5285547/131180743-2094cd44-a5b0-47da-8f09-23748932b84b.png)

They show this is vunerable to: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-29447


login details for wordpress admin panel

```
test-corp:test
```

## Exploit setup

1. Create the malicious wav file. 
2. Create a xml .dtd file to extracts any file contents out. 
3. Convert the base64 on return.

### 1. 



