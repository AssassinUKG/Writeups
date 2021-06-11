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

Here we find a users.bak file. We can download and check the contents.
Which seem to be a mysql or database command for creating a new user

![image](https://user-images.githubusercontent.com/5285547/121745773-be682e00-cafc-11eb-951c-aff68f56f379.png)

So now we have a username: Admin 


## Website's (port 80, 8765)

### Port 80

This portal contains a blog for "mustacchio" brand for all mankind!

![image](https://user-images.githubusercontent.com/5285547/121744541-f9696200-cafa-11eb-9b2f-eeb05996505d.png)

Checking the webpages source code revealed nothing, but i noted a mobile.js script file included. Pressing F12 and using the developer console. I looked at the source code for the mobile.js file. 

![image](https://user-images.githubusercontent.com/5285547/121744888-7b598b00-cafb-11eb-8b8d-6741f1d9b90b.png)

I see some md5 at the bottom of the source code so try it on https://crackstation.net/ 

We get a hit

![image](https://user-images.githubusercontent.com/5285547/121745099-d55a5080-cafb-11eb-852e-bb56347012c3.png)

Now we have a username and password but nowhere to use them!?

Let's move on to the next port. 


### Port 8765

http://10.10.68.59:8765/

This page presents us with what we need for our credentials, a login page. 

![image](https://user-images.githubusercontent.com/5285547/121746171-5d8d2580-cafd-11eb-9c70-328eff1493a4.png)




