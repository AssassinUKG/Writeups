# Vega


PwnTillDwn!!
IP: 10.150.150.222  
OS: Linux  
Room link: https://online.pwntilldawn.com/Target/Show/3  
Credits:https://www.wizlynxgroup.com/  https://online.pwntilldawn.com/ 


## Enum

I start off with a nmap scan to see whats open. 

nmap

```
PORT      STATE SERVICE
22/tcp    open  ssh
80/tcp    open  http
8089/tcp  open  unknown
10000/tcp open  snet-sensor-mgmt
```

Checking out the ports I found 2 web portals (logins) on ports 80, 10000 

```
http://10.150.150.222/
http://10.150.150.222:10000/
```
