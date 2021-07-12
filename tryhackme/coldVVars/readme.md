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
```

### Port 8082

```

```

