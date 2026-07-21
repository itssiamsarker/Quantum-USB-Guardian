# ==============================================================================
# Quantum USB Guardian (QUG) - Module 03: Threat & Script Scanner Engine
# Developed for: QUG Architecture Core
# ==============================================================================

function Start-QUGScanEngine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDriveLetter # e.g. "E:"
    )

    process {
        $drive = $TargetDriveLetter.TrimEnd('\').TrimEnd(':') + ":"
        $drivePath = "$drive\"

        if (-not (Test-Path -Path $drivePath)) {
            Write-Error "Target drive $drivePath not found!"
            return $null
        }

        Write-Host "[*] Initiating QUG Threat Scanner on $drivePath..." -ForegroundColor Cyan

        # Suspicious File Extensions to Scan
        $scriptExtensions = @('.vbs', '.bat', '.cmd', '.js', '.ps1', '.hta', '.wsf')
        $execExtensions   = @('.exe', '.scr', '.dll')
        
        $threatList = @()

        # Fetch all items from USB
        $allItems = Get-ChildItem -Path $drivePath -Recurse -Force -ErrorAction SilentlyContinue

        foreach ($item in $allItems) {
            $threatType = $null
            $severity   = "Low"

            # 1. Autorun.inf Check
            if ($item.Name -ieq "autorun.inf") {
                $threatType = "Autorun Configuration (Potential Autorun Exploit)"
                $severity   = "High"
            }
            # 2. Fake LNK / Shortcut Virus Check
            elseif ($item.Extension -ieq ".lnk") {
                $threatType = "Shortcut Virus (.lnk File)"
                $severity   = "Medium"
            }
            # 3. Malicious Script Files Check
            elseif ($scriptExtensions -contains $item.Extension.ToLower()) {
                $threatType = "Executable Script ($($item.Extension))"
                $severity   = "High"
            }
            # 4. Executable Files Check
            elseif ($execExtensions -contains $item.Extension.ToLower()) {
                $threatType = "Executable Binary ($($item.Extension))"
                $severity   = "Medium"
            }

            # If a threat is identified, compute SHA256 Hash and record details
            if ($threatType) {
                $hash = (Get-FileHash -Path $item.FullName -Algorithm SHA256 -ErrorAction SilentlyContinue).Hash

                $threatDetails = [PSCustomObject]@{
                    FileName     = $item.Name
                    FilePath     = $item.FullName
                    ThreatType   = $threatType
                    Severity     = $severity
                    SizeBytes    = $item.Length
                    SHA256Hash   = if ($hash) { $hash } else { "N/A" }
                    CreationTime = $item.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                }

                $threatList += $threatDetails
            }
        }

        Write-Host "[+] Scan Completed!" -ForegroundColor Green
        Write-Host "[!] Total Threats Identified: $($threatList.Count)" -ForegroundColor Yellow

        return $threatList
    }
}

# ==============================================================================
# Execution / Testing Execution Block
# ==============================================================================
Clear-Host
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  QUG MODULE 03: MALWARE & SCRIPT SCANNER   " -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$testDrive = Read-Host "Enter USB Drive Letter to Scan (e.g. E:)"

if ($testDrive) {
    $scanResults = Start-QUGScanEngine -TargetDriveLetter $testDrive

    if ($scanResults.Count -gt 0) {
        Write-Host "`n[!] Threat Summary Detected:" -ForegroundColor Red
        $scanResults | Format-Table FileName, ThreatType, Severity, SHA256Hash -AutoSize
    } else {
        Write-Host "`n[+] No suspicious scripts, shortcuts, or autorun files detected." -ForegroundColor Green
    }
} else {
    Write-Host "[-] Scan cancelled. No drive entered." -ForegroundColor Red
}