# Hack Me Please: 1 

![image](https://user-images.githubusercontent.com/5285547/130267694-61e97652-f3e3-467b-b47f-416b2b230845.png)

Link: https://www.vulnhub.com/entry/hack-me-please-1,731/

## Enum 

Find IP

```
sudo arp-scan --localnet -I eth0
```

IP: 192.168.1.179

Nmap

```
nmap -p- -v 192.168.1.179

PORT      STATE SERVICE
80/tcp    open  http
3306/tcp  open  mysql
33060/tcp open  mysqlx
```

## Port 80

![image](https://user-images.githubusercontent.com/5285547/130267618-2288e9b7-eed5-4bc4-904c-78f64ce658ee.png)


Checking the main site didn't show anything of intrest. 
Looking in the js files (main.js) I saw an intresting comment. 

```
//make sure this js file is same as installed app on our server endpoint: /seeddms51x/seeddms-5.1.22/
```

