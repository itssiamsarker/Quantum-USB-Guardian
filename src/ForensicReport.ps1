# ==============================================================================
# Quantum USB Guardian (QUG) - Module 05: Logging, Risk Score & Report Engine
# Developed for: QUG Architecture Core
# ==============================================================================

function New-QUGSecurityReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$USBDetails,
        
        [Parameter(Mandatory = $false)]
        [array]$ThreatsFound = @(),
        
        [Parameter(Mandatory = $false)]
        [int]$CleanedItemsCount = 0,

        [Parameter(Mandatory = $false)]
        [string]$OutputDir = "$env:USERPROFILE\Desktop\QUG_Reports"
    )

    process {
        Write-Host "[*] Calculating USB Risk Score and generating security report..." -ForegroundColor Cyan

        # Create Output Directory if it doesn't exist
        if (-not (Test-Path -Path $OutputDir)) {
            New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
        }

        # ----------------------------------------------------------------------
        # 1. USB Risk Score Calculation Logic (0 to 100)
        # ----------------------------------------------------------------------
        $riskScore = 0

        foreach ($threat in $ThreatsFound) {
            switch ($threat.Severity) {
                "High"   { $riskScore += 30 }
                "Medium" { $riskScore += 15 }
                "Low"    { $riskScore += 5 }
            }
        }

        if ($CleanedItemsCount -gt 0) { $riskScore += 10 }
        if ($riskScore -gt 100) { $riskScore = 100 }

        $riskLevel = "SAFE"
        $riskColor = "#2ea44f" # Green

        if ($riskScore -ge 70) {
            $riskLevel = "CRITICAL"
            $riskColor = "#cb2431" # Red
        } elseif ($riskScore -ge 30) {
            $riskLevel = "MODERATE"
            $riskColor = "#dbab09" # Yellow
        }

        $timeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $reportBaseName = "QUG_Report_$($USBDetails.DriveLetter.Replace(':',''))_$timeStamp"
        $htmlFilePath = Join-Path -Path $OutputDir -ChildPath "$reportBaseName.html"
        $txtFilePath  = Join-Path -Path $OutputDir -ChildPath "$reportBaseName.txt"

        # ----------------------------------------------------------------------
        # 2. HTML Report Generation
        # ----------------------------------------------------------------------
        $threatRowsHTML = ""
        if ($ThreatsFound.Count -gt 0) {
            foreach ($t in $ThreatsFound) {
                $threatRowsHTML += "<tr>
                    <td>$($t.FileName)</td>
                    <td>$($t.ThreatType)</td>
                    <td><span class='badge severity-$($t.Severity.ToLower())'>$($t.Severity)</span></td>
                    <td class='code'>$($t.SHA256Hash)</td>
                </tr>"
            }
        } else {
            $threatRowsHTML = "<tr><td colspan='4' style='text-align:center; color:#2ea44f;'>No malicious artifacts or suspicious scripts detected.</td></tr>"
        }

        $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Quantum USB Guardian - Security Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #0d1117; color: #c9d1d9; margin: 20px; }
        .container { max-width: 900px; margin: auto; background: #161b22; padding: 25px; border-radius: 8px; border: 1px solid #30363d; }
        h1 { color: #58a6ff; border-bottom: 1px solid #30363d; padding-bottom: 10px; margin-top: 0; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px; }
        .card { background: #21262d; padding: 15px; border-radius: 6px; border: 1px solid #30363d; }
        .score-box { text-align: center; padding: 10px; border-radius: 6px; background: #21262d; border: 1px solid #30363d; }
        .score-value { font-size: 42px; font-weight: bold; color: $riskColor; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 10px; border: 1px solid #30363d; text-align: left; }
        th { background-color: #21262d; color: #58a6ff; }
        .badge { padding: 3px 8px; border-radius: 4px; font-weight: bold; font-size: 12px; }
        .severity-high { background: #cb2431; color: #fff; }
        .severity-medium { background: #dbab09; color: #000; }
        .severity-low { background: #2ea44f; color: #fff; }
        .code { font-family: monospace; font-size: 11px; color: #8b949e; word-break: break-all; }
        .footer { margin-top: 25px; text-align: center; font-size: 12px; color: #8b949e; border-top: 1px solid #30363d; padding-top: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🛡️ Quantum USB Guardian — Forensic Report</h1>
        
        <div class="grid">
            <div class="card">
                <h3>Drive Information</h3>
                <p><strong>Drive Letter:</strong> $($USBDetails.DriveLetter)</p>
                <p><strong>Volume Label:</strong> $($USBDetails.VolumeName)</p>
                <p><strong>File System:</strong> $($USBDetails.FileSystem)</p>
                <p><strong>Capacity:</strong> $($USBDetails.TotalSizeGB) GB (Free: $($USBDetails.FreeSpaceGB) GB)</p>
            </div>
            
            <div class="score-box">
                <h3>USB Risk Score</h3>
                <div class="score-value">$riskScore / 100</div>
                <p>Status: <strong style="color: $riskColor;">$riskLevel</strong></p>
                <p>Cleaned Artifacts: <strong>$CleanedItemsCount</strong></p>
            </div>
        </div>

        <h3>Threat Analysis & Audit Logs</h3>
        <table>
            <thead>
                <tr>
                    <th>File Name</th>
                    <th>Detection Type</th>
                    <th>Severity</th>
                    <th>SHA-256 Hash</th>
                </tr>
            </thead>
            <tbody>
                $threatRowsHTML
            </tbody>
        </table>

        <div class="footer">
            Generated by Quantum USB Guardian (QUG) | Time: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        </div>
    </div>
</body>
</html>
"@

        # Write HTML File
        $htmlContent | Out-File -FilePath $htmlFilePath -Encoding utf8

        # ----------------------------------------------------------------------
        # 3. Text Report Generation
        # ----------------------------------------------------------------------
        $txtContent = @"
================================================================================
                    QUANTUM USB GUARDIAN — FORENSIC REPORT
================================================================================
Timestamp    : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Drive        : $($USBDetails.DriveLetter) ($($USBDetails.VolumeName))
FileSystem   : $($USBDetails.FileSystem)
Total Size   : $($USBDetails.TotalSizeGB) GB
Free Space   : $($USBDetails.FreeSpaceGB) GB
Risk Score   : $riskScore / 100 ($riskLevel)
Cleaned Items: $CleanedItemsCount
================================================================================
DETECTED THREATS / SUSPICIOUS ARTIFACTS:
"@
        if ($ThreatsFound.Count -gt 0) {
            foreach ($t in $ThreatsFound) {
                $txtContent += "`n- Name: $($t.FileName) | Type: $($t.ThreatType) | Severity: $($t.Severity) | Hash: $($t.SHA256Hash)"
            }
        } else {
            $txtContent += "`n[+] No threats or suspicious files detected."
        }

        $txtContent | Out-File -FilePath $txtFilePath -Encoding utf8

        Write-Host "[+] Security Reports generated successfully!" -ForegroundColor Green
        Write-Host "    -> HTML Report: $htmlFilePath" -ForegroundColor Yellow
        Write-Host "    -> TXT Report : $txtFilePath" -ForegroundColor Yellow

        return @{
            RiskScore = $riskScore
            RiskLevel = $riskLevel
            HTMLPath  = $htmlFilePath
            TXTPath   = $txtFilePath
        }
    }
}

# ==============================================================================
# Testing Execution Block
# ==============================================================================
Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " QUG MODULE 05: LOGGING, RISK SCORE & REPORT ENGINE       " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Mock Data for Testing Module 05 Directly
$mockUSB = [PSCustomObject]@{
    DriveLetter = "G:"
    VolumeName  = "CYSE_DRIVE"
    FileSystem  = "NTFS"
    TotalSizeGB = 14.91
    FreeSpaceGB = 10.20
}

$mockThreats = @(
    [PSCustomObject]@{
        FileName   = "compile.bat"
        ThreatType = "Executable Script (.bat)"
        Severity   = "High"
        SHA256Hash = "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
    }
)

$reportResult = New-QUGSecurityReport -USBDetails $mockUSB -ThreatsFound $mockThreats -CleanedItemsCount 1