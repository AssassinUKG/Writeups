# Git and Crumpets 


- Room link:  
  https://tryhackme.com/room/gitandcrumpets
  
![image](https://user-images.githubusercontent.com/5285547/124516978-c903a380-ddda-11eb-9889-003881db1c7b.png)


## Nmap 

Let's see what we are working with here. 

```
Nmap scan report for git.git-and-crumpets.thm (10.10.255.148)
Host is up (0.022s latency).
Not shown: 997 filtered ports
PORT     STATE  SERVICE
22/tcp   open   ssh
80/tcp   open   http
9090/tcp closed zeus-admin
```
I see ```git.git-and-crumpets.thm``` and ```git-and-crumpets.thm``` in the nmap output.  
Let's add them to our ```/etc/hosts``` file

```
sudo nano /etc/hosts
```

## Port 80

Visiting the main website page, instantly redirects us to a Rick Astley video (we do love our Rick).
After having added the new hosts to the host file, I can now see the real page... 

![image](https://user-images.githubusercontent.com/5285547/124517211-55ae6180-dddb-11eb-8d35-0cb559d7a423.png)

Let's make an account and have a look around the system.  
After making the new account login. When you get there you will notice a few repos in ```Explore``` tab. 

![image](https://user-images.githubusercontent.com/5285547/124517322-9c9c5700-dddb-11eb-9f7c-4eb5f1302aed.png)

Checking the repo and its commits, we can see 5 changes. Let's review them. 

![image](https://user-images.githubusercontent.com/5285547/124517368-b50c7180-dddb-11eb-8987-c4513be276d0.png)

Now knowing the users password is in the image, lets get it. 

```
curl http://git.git-and-crumpets.thm/avatars/3fc2cde6ac97e8c8a0c8b202e527d56d -s | strings -n 8 | head
```
Result
```
8tEXtDescription
My 'Password' should be easy enough to guess
E7V:W*555}
```
Next we need to find his email, luckily its on the main profile for the user. 

![image](https://user-images.githubusercontent.com/5285547/124517524-13395480-dddc-11eb-8dc6-e45bb81effd2.png)

## User

Lets login as the new user, then check if he has nay higher privileges. 

![image](https://user-images.githubusercontent.com/5285547/124517654-66aba280-dddc-11eb-8537-2747bfff88f3.png)

Yes, Githooks are available. This will allow use to execute code on a successful change to the repo.

More info here: https://podalirius.net/en/articles/exploiting-cve-2020-14144-gitea-authenticated-remote-code-execution/

Edit the page above with a bash shell to your machine. 

![image](https://user-images.githubusercontent.com/5285547/124517772-bbe7b400-dddc-11eb-95fc-148134506ffe.png)

Then update the hook script to save it.
Now edit the readme.md file with any change to get our hook to fire and get a shell. 

![image](https://user-images.githubusercontent.com/5285547/124518309-fef65700-dddd-11eb-9e90-3fcd32af987f.png)

We can grab the flag in the home folder. (/home/git)  
Its abse64 encoded, so decode it. If you forget ...

```
#thm{fd7ab9ffd409064f257cd70cf3d6aa16}
echo dGhte2ZYzZDZhYTE2fQ=|base64 -d 
```





```

```
