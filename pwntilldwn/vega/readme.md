# Vega

![image](https://user-images.githubusercontent.com/5285547/129271964-f9b0b496-735a-4163-92f2-a58d55bed803.png)

PwnTillDwn!!  
IP: 10.150.150.222  
OS: Linux  
Room link: https://online.pwntilldawn.com/Target/Show/3  
Credits:  
https://www.wizlynxgroup.com/  
https://online.pwntilldawn.com/ 


## Enum

I start off with a nmap scan to see whats open on the box. 

nmap

```
PORT      STATE SERVICE
22/tcp    open  ssh
80/tcp    open  http
8089/tcp  open  unknown
10000/tcp open  snet-sensor-mgmt
```

Enumerating the first port (80)

Main page

![image](https://user-images.githubusercontent.com/5285547/129267028-5957db22-1feb-4f75-b740-dc36ee56034d.png)

```
ffuf -u http://10.150.150.222/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-large-files-lowercase.txt -fc 403 -ic

index.php               [Status: 200, Size: 82798, Words: 35702, Lines: 1100]
robots.txt              [Status: 200, Size: 1, Words: 1, Lines: 2]
.cache                  [Status: 301, Size: 317, Words: 20, Lines: 10]
error.log               [Status: 200, Size: 39898, Words: 3781, Lines: 219]
.bashrc                 [Status: 200, Size: 3771, Words: 522, Lines: 118]
.bash_logout            [Status: 200, Size: 220, Words: 35, Lines: 8]
training.html           [Status: 200, Size: 36356, Words: 8770, Lines: 607]
.bash_history           [Status: 200, Size: 2235, Words: 176, Lines: 72]
```

Intresting files seeing user files in the results. 

.bash_histroy  (First flag, flag40)

```
history
sudo apt-get update && apt-get upgrade -y
sudo apt install apache2
sudo systemctl enable apache2
sudo apt install mariadb-server
sudo a2enmod rewrite
sudo nano /etc/apache2/sites-available/magento2.example.com.conf
sudo a2dissite 000-default.conf
flag40=<REDACTED>
sudo systemctl reload apache2
sudo a2ensite magento2.example.com.conf
sudo systemctl reload apache2
cd /tmp/
cd logstalgia-1.0.3/
./configure
sudo passwd root
apt-get install libsdl1.2-dev libsdl-image1.2-dev libpcre3-dev libftgl-dev libpng12-dev libjpeg62-dev make gcc
./configure
make
apt-get install libsdl1.2-dev libsdl-image1.2-dev libpcre3-dev libftgl-dev libpng12-dev libjpeg62-dev make gcc++
apt-get install libsdl1.2-dev libsdl-image1.2-dev libpcre3-dev libftgl-dev libpng12-dev libjpeg62-dev make gcc
apt-get install make
mysql -u root -p
apt-get install grsync
apt-get install unison
unisonsudo systemctl restart apache2
ping 1.1.1.1
ping 8.8.8.8
sudo apt install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb http://mirrors.coreix.net/mariadb/repo/10.2/ubuntu xenial main'
sudo apt update
echo FLAG40=<REDACTED>
sudo apt install mariadb-server -y
netstat -np | grep 22
mysql -u root -p
mysql -u magento -p
sudo apt install php7.0 php7.0-curl php7.0-mysql libapache2-mod-php7.0
sudo nano  /etc/php/7.2/cli/php.ini 
ipconfig
ifconfig
sudo nano  /etc/php/7.2/apache2/php.ini 
sudo nano /etc/apache2/sites-available/magento2.example.com.conf
sudo crontab -u vega -e
sudo systemctl restart apache2
sudo cat /var/log/apache2/error.log 
sudo chown -R www-data:www-data .
sudo nano /etc/apache2/sites-available/magento2.example.com.conf 
sudo /etc/init.d/apache2 restart
sudo nano /etc/apt/sources.list
cd /tmp/
wget http://www.webmin.com/jcameron-key.asc
sudo systemctl reload apache2
cd /tmp/
cd logstalgia-1.0.3/
./configure
cd /home/vega
ls -lah
ifconfig
sudo passwd rootsudo apt-key add jcameron-key.asc
sudo apt update 
sudo apt install webmin 
cd ..
history
mysqldump -u vega --password=<REDACTED> magento2 > dumpmagento.sql
cd /home/vega
ls -lah
ll
sudo su
cd /root/
nano CAM.shortcut
```

We get a username (vega) and password for mysql. 

---

## SSH (User Vega)

Now we try the ssh as vega using the mysql creds, we can also brute force the SSH but it takes a while. 

```
ssh vega@10.150.150.222
# Make sure to correct the password spelling :)
```
Login and grab the user flag.

![image](https://user-images.githubusercontent.com/5285547/129271549-e9293549-e490-49eb-8d54-e7c081d89441.png)


---

## Root

Root is very simple on this box. 

```
sudo su
```

![image](https://user-images.githubusercontent.com/5285547/129271663-13878620-38b1-46c5-ae9f-126b0c585628.png)

Awesome box and good fun.
