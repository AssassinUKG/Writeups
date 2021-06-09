# WalkThrough: That's the ticket!
https://tryhackme.com/room/thatstheticket

IP: 10.10.28.159

## Nmap 
Cmd
```bash
nmap -p- -v 10.10.28.159
```
Output
```bash
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

## Nikto 
Cmd
```bash
nikto -h 10.10.28.159
```

Output
```bash

```


## Webpage


1. Register up an account (any)
2. Login
3. See the message box is vunerable to XSS injection
```js
</textarea><script>alert(1)</script>
```

#Room hint from tryhackme page
```markdown
Hint: Our HTTP & DNS Logging tool on http://10.10.10.100 may come in useful!
```
