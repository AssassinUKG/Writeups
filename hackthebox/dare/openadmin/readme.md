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

## Artwork

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

## Music

http://10.10.10.171/music/index.html


## Sierra

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



