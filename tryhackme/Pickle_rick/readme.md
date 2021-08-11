# Pickle Rick

![image](https://user-images.githubusercontent.com/5285547/129107725-574bedc0-0dbe-452a-b0c1-a1ca6ea18283.png)

Link: https://tryhackme.com/room/picklerick

## Enum

nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

# Port 80

![image](https://user-images.githubusercontent.com/5285547/129107973-8645391b-34ad-42c0-9ba0-522d824d979d.png)

The source code of the page shows something intresting. 

![image](https://user-images.githubusercontent.com/5285547/129108043-7bf54e11-c16d-4158-8928-715bf7db9660.png)

Checking more with a quick dir brute force. 

```
ffuf -u http://10.10.79.239/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-large-files-lowercase.txt -fc 403

login.php               [Status: 200, Size: 882, Words: 89, Lines: 26]
index.html              [Status: 200, Size: 1062, Words: 148, Lines: 38]
robots.txt              [Status: 200, Size: 17, Words: 1, Lines: 2]
.                       [Status: 200, Size: 1062, Words: 148, Lines: 38]
portal.php              [Status: 302, Size: 0, Words: 1, Lines: 1]
denied.php              [Status: 302, Size: 0, Words: 1, Lines: 1]
```

/robots.txt

![image](https://user-images.githubusercontent.com/5285547/129108733-19aa3834-7ac4-4580-8871-850d353aacdf.png)

```
R1ckRul3s:Wubbalubbadubdub
```

Now we can login and get presented with a command shell and other options. 

![image](https://user-images.githubusercontent.com/5285547/129109015-ee510ce4-870c-41b8-8bde-d3e70f436c60.png)

Trying a few commands...

![image](https://user-images.githubusercontent.com/5285547/129109355-8e356077-4a8b-4b49-990e-39a15bcaccd6.png)

---

## What is the first ingredient Rick needs?

![image](https://user-images.githubusercontent.com/5285547/129109715-b5db64c9-d2c7-40bf-8551-1bac6b08b590.png)



