# Coffee Addicts
# Link: https://www.vulnhub.com/entry/coffee-addicts-1,699/

![image](https://user-images.githubusercontent.com/5285547/123182639-c4102d00-d487-11eb-9cda-b2d59844948a.png)


## Enum
IP: 192.168.1.159

Note: Add coffeeaddicts.thm to /etc/hosts 

### Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

### Port 80

![image](https://user-images.githubusercontent.com/5285547/123182605-b6f33e00-d487-11eb-957f-0f65c0c4ee36.png)

### Gobuster (dir)

```
 ffuf -w /usr/share/SecLists/Discovery/Web-Content/directory-list-lowercase-2.3-medium.txt -u http://coffeeaddicts.thm/FUZZ -ic
```
```
wordpress               [Status: 301, Size: 326, Words: 20, Lines: 10]
                        [Status: 200, Size: 735, Words: 95, Lines: 32]
```

## Wordpress
```
http://coffeeaddicts.thm/wordpress/
```

Wpscan reveals a username 'gus'

Checking the comments of the second post shows us a hint

![image](https://user-images.githubusercontent.com/5285547/123186245-aa72e380-d48f-11eb-96d3-b84a7860ca67.png)

*Hint: password is in the image above...

Now we can login to the admin panel, checking out the app quickly. I see we can edit the plugin files. 

You can check akismet plugin and edit the php for a reverse shell, either a php rev shell or basic webshell will do. 

![image](https://user-images.githubusercontent.com/5285547/123186390-ed34bb80-d48f-11eb-852f-66d9cc9a71de.png)

Then call the URL for akismet.php file to activate your reverse shell. 

```
http://coffeeaddicts.thm/wordpress/wp-content/plugins/akismet/akismet.php?c=id
```

![image](https://user-images.githubusercontent.com/5285547/123186467-1e14f080-d490-11eb-8a74-ee30da83ae0b.png)


## User

After getting a reverse shell and checking out the files in gus's home directory we see a readme.txt and the flag

readme.txt
```
hello, admin.

as you can see your site has been hacked, any attempt of fixing it is futile, as we removed you from the sudoers and we changed the root password.

~Nicolas Fritzges
```

Flag
```
THM{s4v3_y0uR_Cr3d5_b0i}
```
In the other users home folder we can find a .ssh file, its password protected. 
Using ssh2john we can crack the password

```
python3 ssh2john.py id_rsa > hash
```

## Root

Now we can ssh into the box as badbyte, running 'sudo -l'
shows

![image](https://user-images.githubusercontent.com/5285547/123194178-f88ee380-d49d-11eb-828f-5116bfd1e779.png)

The path to root is clear now and to the last flag!

```
sudo /opt/BadByte/shell 
```

![image](https://user-images.githubusercontent.com/5285547/123194519-89fe5580-d49e-11eb-93aa-f24b0cc8441f.png)


flag
```
THM{im_the_shell_master}
```
