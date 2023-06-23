# Parameters
param (
    [string]$webApp1Name,
	[string]$webApp1HostName,
	[string]$webApp2Name,
	[string]$webApp2HostName
 )

 # Install Internet Information Services and Components
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Create Website #1
New-Item -Path "$env:systemdrive\inetpub\wwwroot\$webApp1Name" -ItemType Directory
New-Item -ItemType File -Name "index.html" -Path "$env:systemdrive\inetpub\wwwroot\$webApp1Name"
New-IISSite -Name webApp1 -PhysicalPath "$env:systemdrive\inetpub\wwwroot\webApp1" -BindingInformation "*:80:$webApp1HostName"

# Create Website #2
New-Item -Path "$env:systemdrive\inetpub\wwwroot\$webApp2Name" -ItemType Directory
New-Item -ItemType File -Name "index.html" -Path "$env:systemdrive\inetpub\wwwroot\$webApp2Name"
New-IISSite -Name webApp2 -PhysicalPath "$env:systemdrive\inetpub\wwwroot\webApp2" -BindingInformation "*:80:$webApp2HostName"