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
Next we need to find his email, luckily its on the main profile. 



```

```
