#***************************************Tasks on Windows 1o machine***********************************************************************************
#1- Change the local "Administrator"'s password to match the domain controller's "Administrator" account
    #This is needed as we need to use the DNS user interface (installed as a step below) to add "Reverse lookup zone" on 
    #the DNS server installed on teh domain controller. Since the computer has not join the domain yet, we use this trick
    #to pefrom tasks that require admin access on the domain controller form the work station.  

#2- Open VM's IP V4 adaptor setting and set the DNS to the domain controller IP address that hosts the DNS server. Also disable IPV6
    #1.1- Under "Advanced\DNS\Check "Register this connection's addresses in DNS"


#3- Install DNS client (RSAT DNS) and Active Directory tools:
    # Get-WindowsCapability -Online | where name -like rsat*
    # Add-WindowsCapability -Online -name "<Tool name>"
    # #Or Install all of them
        # Get-WindowsCapability -Online | where name -like rsat* | Add-WindowsCapability -Online
Add-WindowsCapability -Online -name "Rsat.Dns.Tools~~~~0.0.1.0"
Add-WindowsCapability -Online -name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"

#4-DNS Settings
    #Open DNS client tool and connect to the domain controller
    #Set DNS Dynamic updates to both secure and nonesecure 
    #Create a "Reverse Lookup Zone" and set the subnet to your sunbet (e.g."192.168.0").

#5- Add the client Win10 mchine to the new domain
Add-Computer -Domainname ACME -Restart
    #Optionally you could rename teh PC athe same time:
    Add-Computer -NewName <New Computer Name> -Domainname <Domain Name> -Restart



    