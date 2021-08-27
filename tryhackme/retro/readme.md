# Retro

![image](https://user-images.githubusercontent.com/5285547/131119489-6feda4b6-44b3-41aa-b3fa-bcb22ece0b84.png)

Room link: https://tryhackme.com/room/retro

Room IP: 10.10.22.148  
*\* for me your's will be different*

## Enumeration


Nmap 

```
PORT     STATE SERVICE
80/tcp   open  http
3389/tcp open  ms-wbt-server
```

ffuf

```
ffuf -u http://10.10.22.148/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories-lowercase.txt -mc all -fc 404

retro                   [Status: 301, Size: 149, Words: 9, Lines: 2]
```

Scanning the directories shows /retro endpoint


Port 80

http://10.10.22.148/retro

The page shows us lots of posts from a guy called Wade about classic gaming. 
I noticed the site urls are simular to how wordpress are laid out. There is a login link at the bottom that resolves to a wordpress login.  
This confirms my suspicion, time to get wp-scan out. 

```
wpscan --url http://10.10.22.148/retro/
```
