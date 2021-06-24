# Coffee Addicts
# Link: https://www.vulnhub.com/entry/coffee-addicts-1,699/

![image](https://user-images.githubusercontent.com/5285547/123182639-c4102d00-d487-11eb-9cda-b2d59844948a.png)


## Enum
IP: 192.168.1.159

Note: Add coffeeaddicts.thm to /etc/hosts 

### Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

### Port 80

![image](https://user-images.githubusercontent.com/5285547/123182605-b6f33e00-d487-11eb-957f-0f65c0c4ee36.png)

### Gobuster (dir)

```
 ffuf -w /usr/share/SecLists/Discovery/Web-Content/directory-list-lowercase-2.3-medium.txt -u http://coffeeaddicts.thm/FUZZ -ic
```
```
wordpress               [Status: 301, Size: 326, Words: 20, Lines: 10]
                        [Status: 200, Size: 735, Words: 95, Lines: 32]
```

## Wordpress
```
http://coffeeaddicts.thm/wordpress/
```

wpscan reveals a username 'gus'


## User

## Root
