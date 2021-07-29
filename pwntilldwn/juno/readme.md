# Juno


IP: 10.150.150.224
link: https://online.pwntilldawn.com/

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

Decompile and Recompile

```
apktool d app.apk

d2j-dex2jar ~/scratch/android/JunoClient.apk  #jd-gui

apktool b app.apk

keytool -genkey -v -keystore my-release-key.keystore -alias alias_name \
-keyalg RSA -keysize 2048 -validity 10000

jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore JunoClient.apk alias_name

jarsigner -verify -verbose -certs JunoClient.apk 
```
