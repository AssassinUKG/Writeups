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

## Task 11

## Task 12

## Task 13

## Task 14

## Task 15

## Task 16

## Task 17

## Task 18

## Task 19

## Task 20

