# Cereal
# Link: https://www.vulnhub.com/entry/cereal-1,703/

![image](https://user-images.githubusercontent.com/5285547/123203849-dea9cc80-d4ae-11eb-89f6-e2e362ab4bfc.png)

## Nmap

```
PORT      STATE SERVICE
21/tcp    open  ftp
22/tcp    open  ssh
80/tcp    open  http
139/tcp   open  netbios-ssn
445/tcp   open  microsoft-ds
3306/tcp  open  mysql
11111/tcp open  vce
22222/tcp open  easyengine
22223/tcp open  unknown
33333/tcp open  dgi-serv
33334/tcp open  speedtrace
44441/tcp open  unknown
44444/tcp open  cognex-dataman
55551/tcp open  unknown
55555/tcp open  unknown
```

## Gobuster

```
/blog                 (Status: 301) [Size: 233] [--> http://192.168.1.67/blog/]
/admin                (Status: 301) [Size: 234] [--> http://192.168.1.67/admin/]
```

## Blog

![image](https://user-images.githubusercontent.com/5285547/123204142-65f74000-d4af-11eb-967b-76c6657cbe3e.png)

Let's add cereal.ctf to /etc/hosts file. 

