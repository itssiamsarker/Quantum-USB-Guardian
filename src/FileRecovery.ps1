# ==============================================================================
# Quantum USB Guardian (QUG) - Module 02: Hidden File Recovery Engine
# Developed for: QUG Architecture Core
# ==============================================================================

function Invoke-QUGHiddenFileRecovery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDriveLetter # e.g. "E:"
    )

    process {
        # Formatting Drive Letter
        $drive = $TargetDriveLetter.TrimEnd('\').TrimEnd(':') + ":"
        $drivePath = "$drive\"

        Write-Host "[*] Checking target drive path: $drivePath" -ForegroundColor Cyan

        if (-not (Test-Path -Path $drivePath)) {
            Write-Error "Drive $drivePath does not exist or is not connected."
            return $false
        }

        Write-Host "[*] Starting Hidden File Recovery & Attribute Repair..." -ForegroundColor Yellow

        try {
            # Execute native Windows attrib command to clear System, Hidden, and Read-Only flags
            # /s = Process matching files in the current folder and all subfolders.
            # /d = Process folders as well.
            $attribArgs = "-h -r -s `"$drivePath\*.*`" /s /d"
            
            $process = Start-Process -FilePath "attrib.exe" -ArgumentList $attribArgs -NoNewWindow -Wait -PassThru

            if ($process.ExitCode -eq 0) {
                Write-Host "[+] Attribute repair executed successfully!" -ForegroundColor Green
            } else {
                Write-Warning "[!] Attrib command executed with exit code: $($process.ExitCode)"
            }

            # Scanning recovered hidden items for logging purpose
            $recoveredItems = Get-ChildItem -Path $drivePath -Force -Recurse -ErrorAction SilentlyContinue | 
                              Where-Object { $_.Attributes -notmatch "Hidden" }

            $recoveredCount = $recoveredItems.Count

            Write-Host "[+] Recovery Complete!" -ForegroundColor Green
            Write-Host "[+] Processed/Restored items count: $recoveredCount" -ForegroundColor White

            return [PSCustomObject]@{
                Drive             = $drive
                Status            = "Success"
                ProcessedItems    = $recoveredCount
                Timestamp         = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            }
        }
        catch {
            Write-Error "Failed to recover hidden files: $_"
            return $null
        }
    }
}

# ==============================================================================
# Execution / Testing Execution Block
# ==============================================================================
Clear-Host
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host " QUG MODULE 02: HIDDEN FILE RECOVERY ENGINE " -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Example Test Execution
$testDrive = Read-Host "Enter your USB Drive Letter to Repair (e.g. E:)"

if ($testDrive) {
    $result = Invoke-QUGHiddenFileRecovery -TargetDriveLetter $testDrive
    if ($result) {
        $result | Format-Table -AutoSize
    }
} else {
    Write-Host "[-] Drive letter input skipped." -ForegroundColor Red
}