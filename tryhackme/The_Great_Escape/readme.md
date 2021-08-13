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



