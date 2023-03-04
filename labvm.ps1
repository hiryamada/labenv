# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install packages
choco install -y googlechrome setdefaultbrowser azure-cli vscode dotnet-7.0-sdk git
# choco install -y powershell-core

# refresh
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv

# set default browser to Google Chrome
SetDefaultBrowser.exe chrome group=Administrators

# disable Server Manager
schtasks.exe /change /tn "\Microsoft\Windows\Server Manager\ServerManager" /disable

# Set Processor Scheduling to "Programs" (default: "Background services")
echo 'Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl]
"Win32PrioritySeparation"=dword:00000026
' > PriorityControl.reg
regedit /s PriorityControl.reg

# set Visual Effects to "Adjust for best appearance"
$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
try {
    $s = (Get-ItemProperty -ErrorAction stop -Name visualfxsetting -Path $path).visualfxsetting
    if ($s -ne 1) {
        Set-ItemProperty -Path $path -Name 'VisualFXSetting' -Value 1
    }
}
catch {
    New-ItemProperty -Path $path -Name 'VisualFXSetting' -Value 1 -PropertyType 'DWORD'
}
