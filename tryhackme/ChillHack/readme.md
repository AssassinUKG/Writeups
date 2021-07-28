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



