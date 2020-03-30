Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -name "fDenyTSConnections" -value 0

Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

$ifaceinfo = Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceIndex $ifaceinfo.InterfaceIndex -NetworkCategory Private 

winrm quickconfig -q
winrm s "winrm/config" '@{MaxTimeoutms="1800000"}'
winrm s "winrm/config/winrs" '@{MaxMemoryPerShellMB="2048"}'
winrm s "winrm/config/service" '@{AllowUnencrypted="true"}'
winrm s "winrm/config/service/auth" '@{Basic="true"}'

Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"

sc.exe config winrm start= auto

exit 0
