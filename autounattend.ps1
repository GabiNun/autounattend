Add-Type -AssemblyName System.Windows.Forms

Write-Host Choice your ISO file

$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = "ISO files (*.iso)|*.iso"
$dialog.Title  = "Select Windows ISO"
$dialog.ShowDialog()

$ISO = $dialog.FileName

$Drive = (Get-DiskImage -ImagePath $ISO | Mount-DiskImage | Get-Volume).DriveLetter + ':'

New-Item Sources -ItemType Directory | Out-Null
Copy-Item -Path "$Drive\*" -Destination Sources -Recurse -Force

irm https://github.com/GabiNun/autounattend/raw/main/autounattend.xml -Out Sources\autounattend.xml
irm https://msdl.microsoft.com/download/symbols/oscdimg.exe/688CABB065000/oscdimg.exe -Out oscdimg.exe

.\oscdimg.exe "-bSources\efi\microsoft\boot\efisys.bin" -u2 Sources autounattend.iso

Remove-Item Sources, oscdimg.exe -Recurse -Force
Dismount-DiskImage -ImagePath $ISO | Out-Null
