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

login details for wordpress admin panel

```
test-corp:test
```


