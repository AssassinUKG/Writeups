# Hacksudo Proximacentauri

Link: https://www.vulnhub.com/entry/hacksudo-proximacentauri,709/

## Nmap 

```
PORT   STATE    SERVICE
22/tcp filtered ssh
80/tcp open     http
```

## Port 80

![image](https://user-images.githubusercontent.com/5285547/127061810-ca23d587-e067-442f-8025-a2315d550f80.png)

Here we see the webpage, I instantly see a variable that looks vunerable in the url. 
"?file=hacksudo-proxima-centauri"

We should check that out for LFI or even RFI.

![image](https://user-images.githubusercontent.com/5285547/127062062-d9584e89-963e-47f0-a1b5-27ef21bbeb32.png)

Seems we may have something! Time to test some payloads. 


