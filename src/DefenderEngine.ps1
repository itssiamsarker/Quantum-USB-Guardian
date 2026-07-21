# ==============================================================================
# Quantum USB Guardian (QUG) - Module 04: USB Cleaner & Defender Integrator
# Developed for: QUG Architecture Core
# ==============================================================================

function Invoke-QUGCleaner {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDriveLetter,
        
        [Parameter(Mandatory = $false)]
        [array]$ThreatList = @()
    )

    process {
        $drive = $TargetDriveLetter.TrimEnd('\').TrimEnd(':') + ":"
        $drivePath = "$drive\"

        Write-Host "[*] Starting USB Cleaning Operations on $drivePath..." -ForegroundColor Cyan

        $cleanedCount = 0
        $errorsCount  = 0

        if ($ThreatList.Count -eq 0) {
            Write-Host "[*] No pre-scanned threat list provided. Scanning for auto-cleanable artifacts..." -ForegroundColor Yellow
            
            $itemsToDelete = Get-ChildItem -Path $drivePath -Recurse -Force -ErrorAction SilentlyContinue | 
                             Where-Object { 
                                 $_.Name -ieq "autorun.inf" -or 
                                 $_.Extension -ieq ".lnk" -or 
                                 @('.vbs', '.bat', '.js', '.hta', '.wsf') -contains $_.Extension.ToLower()
                             }
            
            foreach ($item in $itemsToDelete) {
                try {
                    Remove-Item -Path $item.FullName -Force -ErrorAction Stop
                    Write-Host "[+] Deleted suspicious item: $($item.FullName)" -ForegroundColor Green
                    $cleanedCount++
                }
                catch {
                    Write-Warning "[-] Failed to delete item: $($item.FullName). Error: $_"
                    $errorsCount++
                }
            }
        }
        else {
            foreach ($threat in $ThreatList) {
                try {
                    if (Test-Path -Path $threat.FilePath) {
                        Remove-Item -Path $threat.FilePath -Force -ErrorAction Stop
                        Write-Host "[+] Successfully Removed: $($threat.FileName)" -ForegroundColor Green
                        $cleanedCount++
                    }
                }
                catch {
                    Write-Warning "[-] Unable to delete file: $($threat.FileName). Error: $_"
                    $errorsCount++
                }
            }
        }

        Write-Host "[+] Cleaning Complete. Removed: $cleanedCount items. Failed: $errorsCount" -ForegroundColor Green
        return @{ CleanedCount = $cleanedCount; ErrorCount = $errorsCount }
    }
}


function Start-QUGDefenderScan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDriveLetter
    )

    process {
        $drive = $TargetDriveLetter.TrimEnd('\').TrimEnd(':') + ":"
        $drivePath = "$drive\"

        Write-Host "`n[*] Triggering Microsoft Defender Custom USB Scan on $drivePath..." -ForegroundColor Cyan

        # Path to Microsoft Defender Utility CLI Engine
        $mpCmdPath = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"

        if (-not (Test-Path -Path $mpCmdPath)) {
            # Fallback path for x86/64 bit variations
            $mpCmdPath = "C:\ProgramData\Microsoft\Windows Defender\Platform\*\MpCmdRun.exe"
            $resolvedPath = Resolve-Path $mpCmdPath -ErrorAction SilentlyContinue | Select-Object -Last 1
            if ($resolvedPath) { $mpCmdPath = $resolvedPath.Path }
        }

        if (Test-Path -Path $mpCmdPath) {
            Write-Host "[*] Microsoft Defender Engine Found ($mpCmdPath)" -ForegroundColor Yellow
            Write-Host "[*] Running Custom Scan on $drivePath..." -ForegroundColor Yellow

            # MpCmdRun Arguments: -Scan -ScanType 3 (Custom Scan) -File DrivePath
            $scanArgs = "-Scan -ScanType 3 -File `"$drivePath`""

            $process = Start-Process -FilePath $mpCmdPath -ArgumentList $scanArgs -NoNewWindow -Wait -PassThru

            if ($process.ExitCode -eq 0) {
                Write-Host "[+] Microsoft Defender Scan Completed: No threats detected by Defender." -ForegroundColor Green
                return $true
            }
            elseif ($process.ExitCode -eq 2) {
                Write-Host "[!] Microsoft Defender Scan Completed: Threats were detected and handled by Defender!" -ForegroundColor Red
                return $true
            }
            else {
                Write-Warning "[!] Defender Scan finished with exit code: $($process.ExitCode). (Ensure PowerShell is Administrator)"
                return $false
            }
        }
        else {
            Write-Warning "[-] MpCmdRun.exe not found on this system. Defender scan skipped."
            return $false
        }
    }
}

# ==============================================================================
# Execution Block
# ==============================================================================
Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " QUG MODULE 04: USB CLEANER & DEFENDER INTEGRATOR ENGINE " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$testDrive = Read-Host "Enter USB Drive Letter to Clean & Scan (e.g. E:)"

if ($testDrive) {
    # Step 1: Run Cleaner
    $cleanResult = Invoke-QUGCleaner -TargetDriveLetter $testDrive
    
    # Step 2: Trigger Microsoft Defender Scan
    $defenderResult = Start-QUGDefenderScan -TargetDriveLetter $testDrive
} else {
    Write-Host "[-] Execution cancelled. No drive letter provided." -ForegroundColor Red
}