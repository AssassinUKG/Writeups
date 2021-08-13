# The Great Escape

![image](https://user-images.githubusercontent.com/5285547/129349152-690fda9a-3458-4f63-9303-f278336f727d.png)

Room link: https://tryhackme.com/room/thegreatescape

## Enum

Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

22/tcp open  ssh?
| fingerprint-strings: 
|   GenericLines: 
|_    m6"<
|_ssh-hostkey: ERROR: Script execution failed (use -d to debug)
80/tcp open  http    nginx 1.19.6
|_http-favicon: Unknown favicon MD5: 67EDB7D39E1376FDD8A24B0C640D781E
| http-methods: 
|_  Supported Methods: HEAD
| http-robots.txt: 3 disallowed entries 
|_/api/ /exif-util /*.bak.txt$
|_http-server-header: nginx/1.19.6
|_http-title: docker-escape-nuxt
|_http-trane-info: Problem with XML parsing of /evox/about
```

## Port 80 

Main page

![image](https://user-images.githubusercontent.com/5285547/129352075-939b44a6-fd05-417c-aa06-fb216545fc94.png)

/robots.txt

![image](https://user-images.githubusercontent.com/5285547/129353839-6e377d1b-43c3-487b-95a4-60f78c934ea4.png)



