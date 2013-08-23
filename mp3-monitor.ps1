#***********************************************************************
# "mp3-monitor.ps1"
#
# Written by Eric Chen
#
# 2010.02.10 ver 2 (Service Version)
# If you edit please keep my name or at the very least original author's.
# As of this writing I am unsure if script will work with all scenarios,
# however it has worked for me on Dell laptops running Windows 7 x64.
# -----------------------------------------------------------------------
# Service Installation:
# Aquire and install the Windows 2003 Resource Kit OR the srvany.exe.
# Use sc.exe and srvany.exe to create a service....
#   sc create SwitchWifiAuto binPath= "C:\Program Files (x86)\Windows Resource Kits\Tools\srvany.exe" DisplayName= "Switch Wifi Automatically"
# Edit registry entry for SwitchWifiAuto, add a key and a string value...
#   HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SwitchWifiAuto\Parameters]
#   "Application"="C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy RemoteSigned -File C:\\SwitchWifiAuto\\switch-wifi-srv.ps1"
#************************************************************************

# Define variables
$SourceDirectory = ""
$TargetDirectory = ""
$LogFile = $SourceDirectory + "Mp3.Monitor.Log.txt"
$ExtensionArray = ".mp3",".m4a"

function ContainsAny( [string]$s, [string[]]$items ) {
  $matchingItems = @($items | where { $s.Contains( $_ ) })
  [bool]$matchingItems
}

# Don't let the log file get too big...
if (("{0:N2}" -f ((Get-Item $LogFile).Length/1MB)) -gt 5)
{
    Remove-Item $LogFile
}

# Check if log file exists
# If not - create it
if ((Test-Path $LogFile) -eq "False")
{
	New-Item $LogFile -type file
}

# initialize the items variable with the
# contents of a directory
$items = Get-ChildItem -Path $SourceDirectory


# enumerate the items array
foreach ($item in $items)
{
        # if the item is NOT a directory, then process it.
        if (($item.Attributes -ne "Directory") -and (ContainsAny $item.Name $ExtensionArray))
        {
            # Log the movements
            Write-Host "FOUND FILE" + $item.Name
            $DateNow = (Get-Date).ToString()
		    Add-Content $LogFile "Moved $($item.FullName) to $($TargetDirectory) @ $($DateNow)"
        }
        # if the item is a directory and contains music files, AKA you found an album
        # Move the folder
        if ($item.Attributes -eq "Directory")
        {
            $ChildDirectory = $SourceDirectory + $item.Name
            $itemChildren = Get-ChildItem($ChildDirectory)
            $AllItemsAreMP3 = "True"
            
            # Check if there are mp3 files in the folder
            foreach($itemChild in $itemChildren)
            {
                if(!$itemChild.Name.Contains($ExtensionList))
                {
                    $AllItemsAreMP3 = "False"
                }
            }
            
            if($AllItemsAreMP3 -eq "True")
            {
                Write-Host "FOUND DIRECTORY" + $itemChild.Name
                $SourceFolder = $SourceDirectory + $Item.Name
                Move-Item $ChildDirectory $TargetDirectory
                # Log the movements
                $DateNow = (Get-Date).ToString()
		        Add-Content $LogFile "Moved $($ChildDirectory) with $($itemChild.Name)to $($TargetDirectory) @ $($DateNow)"
            }
        }
        
}

# Move mp3 files to TargetDirectory
foreach ($ext in $ExtensionArray)
{
    $SourceFile = $SourceDirectory + "*" + $ext
    Move-Item $SourceFile $TargetDirectory
}
