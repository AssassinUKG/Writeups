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


