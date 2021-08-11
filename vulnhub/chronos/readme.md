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

