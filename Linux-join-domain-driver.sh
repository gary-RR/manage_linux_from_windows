ssh gary@192.168.0.27

VM_IP=192.168.0.27

DOMAIN_SUFFIX=".acme.pri"
NEW_VM_NAME=$(hostname)$DOMAIN_SUFFIX

sudo apt-get upgrade -y
sudo apt-get update -y

#Realmd: Enables discovery and joining identity domains. It configures Linux system services such as sssd or winbind 
         #to do the actual network authentication and user account lookups
#SSSD:   Stands for System Security Services Daemon and it’s actually a collection of daemons that handle authentication, authorization, 
         #and user and group information from a variety of network sources. At its core it has support for Active Directory, LDAP, Kerberos
#libnss-sss: provides an nss and pam interface toward the system and a pluggable backend system to connect to multiple different account sources
#libpam-sss: Pam module for the System Security Services Daemon 
#adcli — Tool: for performing actions on an Active Directory domain
#samba-common-bin:  Common files used by both the Samba server and client to provide interop between Linux and Windows 
#oddjob: is a D-Bus service which performs particular tasks for clients which connect to it and issue requests using the system-wide message bus.
#oddjob-mkhomedir: To create and populates home directorie
#packagekit: A package manager
sudo apt -y install realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit -y 

NETPLAN_NAME=$(ls /etc/netplan)
    #Add AD's DNS IP address to "nameservers" list:
    sudo nano /etc/netplan/$NETPLAN_NAME
        sudo netplan apply

#Rename the VM to add Domain suffix to the name    
sudo hostnamectl set-hostname $NEW_VM_NAME

#Realm is a command line tool that can be used to manage enrollment in kerberos realms, like Active Directory domains or IPA domains
#Check if we are able to connect to "discover" the domain realm
realm discover acme.pri

sudo realm join --user=administrator acme.pri -v

sudo realm list

#Modify pam to automatically create a home directory for AD users
sudo pam-auth-update

id administrator@acme.pri

#You can optionally lock down access to the VM only to a specific AD group:
    sudo realm permit -g 'domain admins'@acme.pri

#Add domain administrators to "sudo" group
sudo adduser administrator@acme.pri sudo
#Verify
grep -w sudo /etc/group

#Log-in with AD creds
ssh administrator@acme.pri@$VM_IP

#Leave AD
sudo realm leave acme.pri --user=administrator


