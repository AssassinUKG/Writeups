# WalkThrough: That's the ticket!
https://tryhackme.com/room/thatstheticket

## Nmap 
cmd
```bash
nmap -p- -v 10.10.28.159
```

## Nikto 
cmd
```bash
nikto -h 10.10.28.159
```


## Webpage

1. Register up an account (any)
2. Login
3. See the message box is vunerable to XSS injection
```js
</textarea><script>alert(1)</script>
```
