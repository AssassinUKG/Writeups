# Juno
![image](https://user-images.githubusercontent.com/5285547/127665309-5fc9ea90-4ec2-4013-9444-69084d4d478c.png)

IP: 10.150.150.224  
Links:  
https://online.pwntilldawn.com/
https://www.wizlynxgroup.com/


## Nmap (Enum phase)

```
PORT   STATE SERVICE
80/tcp open  http
```

Not much here apart from a webpage with default apache, Time for fuzzing!! 

## Ffuf

```
ffuf -w /usr/share/seclists/Discovery/Web-Content/raft-large-files-lowercase.txt   -u http://10.150.150.224/FUZZ -mc all -fc 404,403

login.php               [Status: 200, Size: 1213, Words: 400, Lines: 55]
index.html              [Status: 200, Size: 10701, Words: 3427, Lines: 369]
.                       [Status: 200, Size: 10701, Words: 3427, Lines: 369]
const.php               [Status: 200, Size: 0, Words: 1, Lines: 1]
```

## Login page

Going to the login page presents a pin protected login, after brute forcing i got no where. 
Then I noticed a .apk file download. Looks like we need to reverse engineer the apk.  
(This was not the case but i left this here for information purpouses)

Decompile and Recompile

```
apktool -r d app.apk

d2j-dex2jar ~/scratch/android/JunoClient.apk  #jd-gui

apktool -r b app.apk

keytool -genkey -v -keystore my-release-key.keystore -alias alias_name \
-keyalg RSA -keysize 2048 -validity 10000

jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore JunoClient.apk alias_name

jarsigner -verify -verbose -certs JunoClient.apk 
```

```
#Line 91 change value
  if-eqz v2, :cond_0
```

## MobSF (nice tool) 

I failed at the reverse engineering manually and had to seek a nudge. I got told of a software to try out next called MobSF

MobSF: https://github.com/MobSF/Mobile-Security-Framework-MobSF

### Instructions Install.

```
git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git
cd Mobile-Security-Framework-MobSF
./setup.sh
```

### To Run the tool.

```
./run 127.0.0.1:9999
```

Then open a webpage to be presented with the tools interface where you can now upload an android file to be inspected. 

![image](https://user-images.githubusercontent.com/5285547/127664226-9f10f964-9cc7-443a-a863-c28f3263f40d.png)

Drag and drop the JunoClient.apk file onto the webpage to start the analysis. 

![image](https://user-images.githubusercontent.com/5285547/127664350-b1aac5a4-10df-4c7b-ab53-f6a9d5df2433.png)

Having already manually tring to do this, I had decompiled the apk file and already seen parts of the code I thought would be a good start. 

Namily FLAG43 (seen in the code base) and youknowhat variables. 

Using search on the webpage I qucklyu found them both. 

![image](https://user-images.githubusercontent.com/5285547/127664564-74eac0e4-f76c-4b92-b1ff-0b0073e8da12.png)

![image](https://user-images.githubusercontent.com/5285547/127664625-49d32ca2-2949-4bc3-8086-cd595338a4c6.png)  
*Cut off on purpous

With the correct pin we can now log in to the webpage. 

![image](https://user-images.githubusercontent.com/5285547/127664704-f829530e-ed8b-4ff9-b871-adcf8ec586b7.png)

We are presented with the last 2 flags. 

![image](https://user-images.githubusercontent.com/5285547/127664747-5a6fd238-3fd2-41e0-8eb8-663c58c44947.png)

One is encoded the other is not. 
For the encoded one, I worked out that the ASCII shift cypher is being used so we can decompile it.  
Then grab the last flag from the box! 

![image](https://user-images.githubusercontent.com/5285547/127664872-d0eeaead-6fa3-401d-9ff6-d7eabccec8f3.png)

I hope you enjoyed this one, I did!! 




