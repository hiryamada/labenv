# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# refresh
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv

# install packages
choco install -y googlechrome setdefaultbrowser azure-cli vscode dotnet-7.0-sdk git 

SetDefaultBrowser chrome

# disable Server Manager
schtasks.exe /change /tn "\Microsoft\Windows\Server Manager\ServerManager" /disable
