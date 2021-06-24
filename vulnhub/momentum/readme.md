# Momemtum
# Link: https://www.vulnhub.com/entry/momentum-2,702/

## Enum

### Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

### Gobuster

```
/index.html           (Status: 200) [Size: 1428]
/img                  (Status: 301) [Size: 312] [--> http://192.168.1.145/img/]
/css                  (Status: 301) [Size: 312] [--> http://192.168.1.145/css/]
/ajax.php             (Status: 200) [Size: 0]                                  
/manual               (Status: 301) [Size: 315] [--> http://192.168.1.145/manual/]
/js                   (Status: 301) [Size: 311] [--> http://192.168.1.145/js/]    
/dashboard.html       (Status: 200) [Size: 513]                                   
/owls                 (Status: 301) [Size: 313] [--> http://192.168.1.145/owls/]  
/server-status        (Status: 403) [Size: 278] 
```

Intresting...

```
http://192.168.1.145/dashboard.html
```

We can upload files but only .txt seems to be accpeted. Checking out the code for main.js we can see the AJAX call (POST) to upload the file.  

![image](https://user-images.githubusercontent.com/5285547/123197771-efa11080-d4a3-11eb-82bd-0d876351ea2b.png)

Looking for the ajax.php we can also noticed there is a backup copy ajax.php.bak

```
http://192.168.1.145/ajax.php.bak
```

![image](https://user-images.githubusercontent.com/5285547/123197920-2bd47100-d4a4-11eb-8802-f6f354117b28.png)

Now we know we need to set the admin cookie (adding an extra charater as the hint suggests).  
We will use Burp for this. 

![image](https://user-images.githubusercontent.com/5285547/123198397-f3816280-d4a4-11eb-9cf5-b68d3d2627a9.png)



## User

## Root
