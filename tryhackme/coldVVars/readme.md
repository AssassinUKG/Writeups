# Cold VVars
![image](https://user-images.githubusercontent.com/5285547/125272663-03ea6780-e304-11eb-9595-4169d0b8fdc3.png)
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
Secure File Upload and Testing Functionality
```

### Port 8082

Home page
```
http://10.10.236.49:8082
```

Scanning the URL with gobuster shows a login page (/login)  
[Bypass List: ](/tryhackme/coldVVars/sql_Injection_Bypass.txt)




