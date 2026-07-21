# ==============================================================================
# Quantum USB Guardian (QUG) - Module 01: USB Detection Engine
# Developed for: QUG Architecture Core
# ==============================================================================

function Get-QUGConnectedUSBDrives {
    [CmdletBinding()]
    param()

    process {
        Write-Verbose "Scanning for connected USB storage devices..."
        
        # Querying Removable Drives via CIM (DriveType 2 = Removable)
        $logicalDisks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }
        
        $usbList = @()

        foreach ($disk in $logicalDisks) {
            # Querying associated physical drive details for enhanced info
            $partition = Get-CimAssociatedInstance -InputObject $disk -ResultClassName Win32_DiskPartition -ErrorAction SilentlyContinue
            $driveInfo = $null
            if ($partition) {
                $driveInfo = Get-CimAssociatedInstance -InputObject $partition -ResultClassName Win32_DiskDrive -ErrorAction SilentlyContinue
            }

            # Calculating Size and Free Space in GB/MB
            $sizeGB = if ($disk.Size) { [math]::Round($disk.Size / 1GB, 2) } else { 0 }
            $freeSpaceGB = if ($disk.FreeSpace) { [math]::Round($disk.FreeSpace / 1GB, 2) } else { 0 }
            $usedSpaceGB = [math]::Round($sizeGB - $freeSpaceGB, 2)

            # Constructing USB Object
            $usbDetails = [PSCustomObject]@{
                DriveLetter  = $disk.DeviceID                 # e.g., "E:"
                VolumeName   = if ($disk.VolumeName) { $disk.VolumeName } else { "NO_LABEL" }
                FileSystem   = $disk.FileSystem               # e.g., FAT32, NTFS, exFAT
                TotalSizeGB  = $sizeGB                        # e.g., 14.91 GB
                FreeSpaceGB  = $freeSpaceGB                   # e.g., 10.20 GB
                UsedSpaceGB  = $usedSpaceGB                   # e.g., 4.71 GB
                ModelName    = if ($driveInfo) { $driveInfo.Model } else { "Generic USB Device" }
                DeviceID     = $disk.DeviceID
                Status       = "Ready"
            }

            $usbList += $usbDetails
        }

        if ($usbList.Count -eq 0) {
            Write-Warning "No removable USB storage devices detected."
            return $null
        }

        return $usbList
    }
}

# ==============================================================================
# Execution / Testing Execution Block
# ==============================================================================
Clear-Host
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "   QUG MODULE 01: USB DETECTION ENGINE     " -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$detectedUSB = Get-QUGConnectedUSBDrives

if ($detectedUSB) {
    Write-Host "[+] Connected USB Drives Found:" -ForegroundColor Green
    $detectedUSB | Format-Table -AutoSize
} else {
    Write-Host "[-] Please insert a USB drive to test this module." -ForegroundColor Red
}