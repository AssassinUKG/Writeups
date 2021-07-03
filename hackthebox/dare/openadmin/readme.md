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
```

## Artwork

http://10.10.10.171/artwork/index.html


## Music

http://10.10.10.171/music/index.html
