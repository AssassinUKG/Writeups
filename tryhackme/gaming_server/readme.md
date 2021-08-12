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

![image](https://user-images.githubusercontent.com/5285547/129214557-5d0b3f7a-cb10-4cf1-805c-82c70550ea9d.png)

![image](https://user-images.githubusercontent.com/5285547/129214980-5b939017-51a2-48bf-88dc-35f561b778a1.png)

After fuzzing and finding an intresting file, about.php. I checked the source code to see. 

![image](https://user-images.githubusercontent.com/5285547/129215745-66c5f4e4-8339-4b6b-a085-a2664553e6df.png)

Looks like we may be able to upload a file here even a php one (rev shell! :)

