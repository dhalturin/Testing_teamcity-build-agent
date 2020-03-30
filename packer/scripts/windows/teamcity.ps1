Write-Output "Downloading: $env:JRE_EXE"
Invoke-WebRequest -OutFile "c:\jre.exe" -Uri $env:JRE_EXE

$env:TC_ARCHIVE="$env:TC_SERVER/update/buildAgent.zip"

Write-Output "Downloading: $env:TC_ARCHIVE"
Invoke-WebRequest -OutFile "c:\tc-agent.zip" -Uri $env:TC_ARCHIVE

Write-Output "Setup jre"
$process=Start-Process -Wait -PassThru -WorkingDirectory "c:\" -FilePath "jre.exe" -ArgumentList "/s INSTALL_SILENT=1 STATIC=0 AUTO_UPDATE=0 WEB_JAVA=1 WEB_JAVA_SECURITY_LEVEL=H WEB_ANALYTICS=0 EULA=0 REBOOT=0 NOSTARTMENU=0 SPONSORS=0"
if ($process.ExitCode -gt 0) {
  Throw "Start process: Error $($process.ExitCode)"
}

Write-Output "Unpack tc-agent.zip"
Expand-Archive -DestinationPath "c:\tc-agent" -Path "c:\tc-agent.zip"
cd c:\tc-agent

Write-Output "Set tc server"
(Get-Content -path .\conf\buildAgent.dist.properties -Raw) -replace "serverUrl=(.*)", "serverUrl=$env:TC_SERVER" | Set-Content .\conf\buildAgent.properties

Write-Output "Set wrapper java"
(Get-Content -path .\launcher\conf\wrapper.conf -Raw) -replace "wrapper.java.command=(.*)", "wrapper.java.command=C:\Program Files\Java\jre1.8.0_241\bin\java.exe" | Set-Content .\launcher\conf\wrapper.conf

Write-Output "Exec service.install.bat"
$process=Start-Process -Wait -PassThru -WorkingDirectory "c:\tc-agent\bin" -FilePath "service.install.bat"
if ($process.ExitCode -gt 0) {
  Throw "Start process: Error $($process.ExitCode)"
}

Set-Service -Name TCBuildAgent -StartupType Automatic
