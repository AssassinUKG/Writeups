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




## Task 7

## Task 8

## Task 9

## Task 10

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

