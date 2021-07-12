# Cold VVars

![image](https://user-images.githubusercontent.com/5285547/125265936-38a6f080-e2fd-11eb-8651-018cdbf4b2de.png)
Room link: https://tryhackme.com/room/coldvvars

Target IP: 10.10.236.49

## Nmap 

```
PORT     STATE SERVICE
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
8080/tcp open  http-proxy
8082/tcp open  blackice-alerts
```

## Websites
### Port 8080

After a quick gobuster I found a new endpoint /dev, can use OPTIONS to bypass the 403,405
```
http://10.10.236.49:8080/dev/
http://10.10.236.49:8080/dev/note.txt
```
```
curl 10.10.236.49:8080/dev/note.txt 
```
Contents: 
```
* Connected to 10.10.236.49 (10.10.236.49) port 8080 (#0)
> POST /dev/note.txt HTTP/1.1
> Host: 10.10.236.49:8080
> User-Agent: curl/7.74.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Mon, 12 Jul 2021 10:16:41 GMT
< Server: Apache/2.4.29 (Ubuntu)
< Last-Modified: Thu, 11 Mar 2021 12:19:52 GMT
< ETag: "2d-5bd41ccf981ff"
< Accept-Ranges: bytes
< Content-Length: 45
< Content-Type: text/plain
< 
Secure File Upload and Testing Functionality
```

### Port 8082

```

```

