
#Set the time zone 
set-timezone "Central Standard Time"

$SERVER_IP="192.168.0.31"
$PREFIX_LENGTH=24
$DEFAULT_GATEWAY="192.168.0.1"
$DNS_IPs=”8.8.8.8”

#Create a new rule and allow all traffic In and out:
New-NetFireWallRule -DisplayName "Allow All Traffic" -Direction OutBound -Action Allow 
New-NetFireWallRule -DisplayName "Allow All Traffic" -Direction InBound -Action Allow
    
#Disable IPV6
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6

#***************Assign static IP Adress*******************
$ADAPTER=get-netadapter
get-netipaddress -InterfaceIndex $ADAPTER.ifIndex
get-netipaddress -InterfaceAlias $ADAPTER.Name

#Reserve an IP addres for it 
New-NetIPAddress -InterfaceAlias $ADAPTER.Name -IPAddress $SERVER_IP -AddressFamily IPv4 -PrefixLength $PREFIX_LENGTH -DefaultGateway $DEFAULT_GATEWAY
Set-DnsClientServerAddress -InterfaceIndex $ADAPTER.ifIndex -ServerAddresses ($SERVER_IP,$DNS_IPs)

#Verify above settings
get-NetIPConfiguration -InterfaceAlias $ADAPTER.Name

#"ServerCore.AppCompatibility" installs teh following components:
# Microsoft Management Console (mmc.exe)
# Event Viewer (Eventvwr.msc)
# Performance Monitor (PerfMon.exe)
# Resource Monitor (Resmon.exe)
# Device Manager (Devmgmt.msc)
# File Explorer (Explorer.exe)
# Disk Management (Diskmgmt.msc)
# Failover Cluster Manager (CluAdmin.msc)
Add-WindowsCapability -Online -Name ServerCore.AppCompatibility~~~~0.0.1.0

Restart-Computer -Force

#*********************Optionally install SSH client and server****************
#Install Open SSH:
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the sshd service
Start-Service sshd

#Set the service to start automatically
Set-Service -Name sshd -StartupType 'Automatic'

#This will make Powershell the default shell ssh to server: 	
New-ItemProperty -path "HKLM:\software\openssh" -Name Defaultshell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType string -force 

#***********************************Install AD*****************************************************************************
#This section can be run from an SSH session, of course you can run them from Hyper-V client connection or remote desktop

$DOMAIN_NAME="acme.pri"
$NEW_SERVER_NAME="DC1"

#Optionally change your domain controller name
Rename-Computer -NewName $NEW_SERVER_NAME -Restart

#Install the "AD-Domain-Services"  
Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools

#Setup the "ACME" Forest and Domain 
Install-ADDSForest -DomainName $DOMAIN_NAME -InstallDNS

ssh administrator@$DOMAIN_NAME@$SERVER_IP
    #Or
    ssh $DOMAIN_NAME\administrator@$SERVER_IP

#*****Note: 
    #After AD is installed, go to Win10 machine and perform tasks (see "Win-10-Prep-And-Tasks.ps1" script)
#******

$SERVER_IP="192.168.0.31"
nslookup dc1   
nslookup dc1.acme.pri 
nslookup 192.168.0.31  #See if "Server unknown" shows up. 
    #Should work after worked after setting this:
    ipconfig -registerdns
        nslookup $SERVER_IP 

#After setting up domain
runas /user:$DOMAIN_NAME\administrator powershell

#TO REMOVE DC
uninstall-addsdomaincontroller -domainname $DOMAIN_NAME -credential



