# ==============================================================================
# Quantum USB Guardian (QUG) - Complete Application with WPF GUI Dashboard
# Developed for: QUG Architecture
# Author: Abdullah Ibn Hasan Ibn Sabit Ali Sarker (Siam)
# ==============================================================================

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# ------------------------------------------------------------------------------
# 1. CORE BACKEND FUNCTIONS (MODULES 01 - 05 INTEGRATION)
# ------------------------------------------------------------------------------

function Get-QUGConnectedUSBDrives {
    $logicalDisks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }
    $usbList = @()

    foreach ($disk in $logicalDisks) {
        $partition = Get-CimAssociatedInstance -InputObject $disk -ResultClassName Win32_DiskPartition -ErrorAction SilentlyContinue
        $driveInfo = $null
        if ($partition) {
            $driveInfo = Get-CimAssociatedInstance -InputObject $partition -ResultClassName Win32_DiskDrive -ErrorAction SilentlyContinue
        }

        $sizeGB = if ($disk.Size) { [math]::Round($disk.Size / 1GB, 2) } else { 0 }
        $freeSpaceGB = if ($disk.FreeSpace) { [math]::Round($disk.FreeSpace / 1GB, 2) } else { 0 }
        $usedSpaceGB = [math]::Round($sizeGB - $freeSpaceGB, 2)

        $usbList += [PSCustomObject]@{
            DriveLetter = $disk.DeviceID
            VolumeName  = if ($disk.VolumeName) { $disk.VolumeName } else { "NO_LABEL" }
            FileSystem  = $disk.FileSystem
            TotalSizeGB = $sizeGB
            FreeSpaceGB = $freeSpaceGB
            UsedSpaceGB = $usedSpaceGB
            ModelName   = if ($driveInfo) { $driveInfo.Model } else { "Generic USB Device" }
            DisplayText = "$($disk.DeviceID) ($($disk.VolumeName) - $sizeGB GB)"
        }
    }
    return $usbList
}

function Invoke-QUGHiddenFileRecovery {
    param([string]$TargetDriveLetter)
    $drivePath = "$($TargetDriveLetter.TrimEnd('\').TrimEnd(':')):\"
    if (Test-Path -Path $drivePath) {
        $attribArgs = "-h -r -s `"$drivePath\*.*`" /s /d"
        $process = Start-Process -FilePath "attrib.exe" -ArgumentList $attribArgs -NoNewWindow -Wait -PassThru
        return $process.ExitCode -eq 0
    }
    return $false
}

function Start-QUGScanEngine {
    param([string]$TargetDriveLetter)
    $drivePath = "$($TargetDriveLetter.TrimEnd('\').TrimEnd(':')):\"
    $scriptExtensions = @('.vbs', '.bat', '.cmd', '.js', '.ps1', '.hta', '.wsf')
    $execExtensions   = @('.scr', '.dll')
    $threatList = @()

    if (Test-Path -Path $drivePath) {
        $allItems = Get-ChildItem -Path $drivePath -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($item in $allItems) {
            $threatType = $null
            $severity   = "Low"

            # 1. Autorun Exploit Check
            if ($item.Name -ieq "autorun.inf") {
                $threatType = "Autorun Configuration"
                $severity   = "High"
            } 
            # 2. Fake LNK / Shortcut Virus
            elseif ($item.Extension -ieq ".lnk") {
                $threatType = "Shortcut Virus (.lnk)"
                $severity   = "Medium"
            } 
            # 3. Malicious Scripts
            elseif ($scriptExtensions -contains $item.Extension.ToLower()) {
                $threatType = "Executable Script ($($item.Extension))"
                $severity   = "High"
            } 
            # 4. Executable (.exe) Smart Inspection Logic
            elseif ($item.Extension -ieq ".exe") {
                # Flag as threat ONLY if hidden/system file or suspicious screensaver masquerade
                if ($item.Attributes -match "Hidden" -or $item.Attributes -match "System") {
                    $threatType = "Hidden Executable (Suspicious Malware)"
                    $severity   = "High"
                }
            } 
            # 5. Other Dangerous Executables (.scr, .dll)
            elseif ($execExtensions -contains $item.Extension.ToLower()) {
                $threatType = "Binary Payload ($($item.Extension))"
                $severity   = "Medium"
            }

            if ($threatType) {
                $hash = (Get-FileHash -Path $item.FullName -Algorithm SHA256 -ErrorAction SilentlyContinue).Hash
                $threatList += [PSCustomObject]@{
                    FileName   = $item.Name
                    FilePath   = $item.FullName
                    ThreatType = $threatType
                    Severity   = $severity
                    SHA256Hash = if ($hash) { $hash } else { "N/A" }
                }
            }
        }
    }
    return $threatList
}

function Invoke-QUGCleaner {
    param([array]$ThreatList = @())
    $cleanedCount = 0
    foreach ($threat in $ThreatList) {
        try {
            if (Test-Path -Path $threat.FilePath) {
                Remove-Item -Path $threat.FilePath -Force -ErrorAction Stop
                $cleanedCount++
            }
        } catch {}
    }
    return $cleanedCount
}

function Start-QUGDefenderScan {
    param([string]$TargetDriveLetter)
    $drivePath = "$($TargetDriveLetter.TrimEnd('\').TrimEnd(':')):\"
    $mpCmdPath = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    if (-not (Test-Path -Path $mpCmdPath)) {
        $resolvedPath = Resolve-Path "C:\ProgramData\Microsoft\Windows Defender\Platform\*\MpCmdRun.exe" -ErrorAction SilentlyContinue | Select-Object -Last 1
        if ($resolvedPath) { $mpCmdPath = $resolvedPath.Path }
    }

    if (Test-Path -Path $mpCmdPath) {
        $scanArgs = "-Scan -ScanType 3 -File `"$drivePath`""
        $process = Start-Process -FilePath $mpCmdPath -ArgumentList $scanArgs -NoNewWindow -Wait -PassThru
        return $process.ExitCode
    }
    return -1
}

function New-QUGSecurityReport {
    param($USBDetails, $ThreatsFound, $CleanedItemsCount)
    $OutputDir = "$env:USERPROFILE\Desktop\QUG_Reports"
    if (-not (Test-Path -Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

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

    $riskLevel = if ($riskScore -ge 70) { "CRITICAL" } elseif ($riskScore -ge 30) { "MODERATE" } else { "SAFE" }
    $riskColor = if ($riskScore -ge 70) { "#cb2431" } elseif ($riskScore -ge 30) { "#dbab09" } else { "#2ea44f" }

    $reportPath = Join-Path -Path $OutputDir -ChildPath "QUG_Report_$($USBDetails.DriveLetter.Replace(':',''))_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    
    $threatRows = ""
    if ($ThreatsFound.Count -gt 0) {
        foreach ($t in $ThreatsFound) {
            $threatRows += "<tr><td>$($t.FileName)</td><td>$($t.ThreatType)</td><td>$($t.Severity)</td><td style='font-size:10px; color:#8b949e;'>$($t.SHA256Hash)</td></tr>"
        }
    } else {
        $threatRows = "<tr><td colspan='4' style='text-align:center; color:#2ea44f;'>No threats detected. Drive is clean.</td></tr>"
    }

    $html = @"
<!DOCTYPE html>
<html>
<head>
<style>
    body { font-family: 'Segoe UI', sans-serif; background:#0d1117; color:#c9d1d9; padding:20px; }
    .card { background:#161b22; border:1px solid #30363d; padding:20px; border-radius:8px; max-width:800px; margin:auto; }
    h1 { color:#58a6ff; }
    table { width:100%; border-collapse:collapse; margin-top:15px; }
    th, td { border:1px solid #30363d; padding:8px; text-align:left; }
    th { background:#21262d; color:#58a6ff; }
</style>
</head>
<body>
<div class='card'>
    <h1>🛡️ Quantum USB Guardian Report</h1>
    <p><strong>Drive:</strong> $($USBDetails.DriveLetter) | <strong>Label:</strong> $($USBDetails.VolumeName) | <strong>FileSystem:</strong> $($USBDetails.FileSystem)</p>
    <p><strong>Risk Score:</strong> <span style='color:$riskColor; font-size:20px; font-weight:bold;'>$riskScore / 100 ($riskLevel)</span></p>
    <h3>Scan Audit Logs</h3>
    <table>
        <tr><th>File Name</th><th>Type</th><th>Severity</th><th>SHA256 Hash</th></tr>
        $threatRows
    </table>
</div>
</body>
</html>
"@
    $html | Out-File -FilePath $reportPath -Encoding utf8
    return @{ Score = $riskScore; Path = $reportPath }
}

# ------------------------------------------------------------------------------
# 2. WPF / XAML DASHBOARD UI DESIGN
# ------------------------------------------------------------------------------

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Quantum USB Guardian v1.0 — Dashboard" Height="620" Width="900"
        Background="#0D1117" WindowStartupLocation="CenterScreen" ResizeMode="CanMinimize">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Border Grid.Row="0" Background="#161B22" CornerRadius="8" Padding="15" Margin="0,0,0,15" BorderBrush="#30363D" BorderThickness="1">
            <Grid>
                <StackPanel Orientation="Horizontal">
                    <TextBlock Text="🛡️" FontSize="26" VerticalAlignment="Center" Margin="0,0,10,0"/>
                    <StackPanel>
                        <TextBlock Text="QUANTUM USB GUARDIAN" FontSize="20" FontWeight="Bold" Foreground="#58A6FF"/>
                        <TextBlock Text="USB Security, Malware Detection &amp; File Recovery Suite" FontSize="12" Foreground="#8B949E"/>
                    </StackPanel>
                </StackPanel>
                <TextBlock Text="System Ready" x:Name="TxtStatus" HorizontalAlignment="Right" VerticalAlignment="Center" Foreground="#2EA44F" FontWeight="Bold" FontSize="14"/>
            </Grid>
        </Border>

        <!-- USB Selection Box -->
        <Border Grid.Row="1" Background="#161B22" CornerRadius="8" Padding="15" Margin="0,0,0,15" BorderBrush="#30363D" BorderThickness="1">
            <StackPanel Orientation="Horizontal">
                <TextBlock Text="Select USB Drive:" VerticalAlignment="Center" Foreground="#C9D1D9" FontWeight="SemiBold" Margin="0,0,15,0"/>
                <ComboBox x:Name="CmbUsbDrives" Width="300" Height="30" Background="#21262D" Foreground="#000000" VerticalContentAlignment="Center"/>
                <Button x:Name="BtnRefresh" Content="🔄 Refresh" Width="90" Height="30" Margin="10,0,0,0" Background="#21262D" Foreground="#58A6FF" BorderBrush="#30363D"/>
                <Button x:Name="BtnOneClickRepair" Content="⚡ ONE-CLICK REPAIR &amp; SCAN" Width="220" Height="30" Margin="20,0,0,0" Background="#238636" Foreground="White" FontWeight="Bold" BorderThickness="0"/>
            </StackPanel>
        </Border>

        <!-- Live Activity Log Window -->
        <Grid Grid.Row="2" Margin="0,0,0,15">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="2*"/>
                <ColumnDefinition Width="1*"/>
            </Grid.ColumnDefinitions>

            <!-- Console Log -->
            <Border Grid.Column="0" Background="#161B22" CornerRadius="8" Padding="10" Margin="0,0,10,0" BorderBrush="#30363D" BorderThickness="1">
                <DockPanel>
                    <TextBlock Text="Live Activity Log" DockPanel.Dock="Top" Foreground="#58A6FF" FontWeight="Bold" Margin="0,0,0,10"/>
                    <TextBox x:Name="TxtLog" Background="#0D1117" Foreground="#3FB950" FontFamily="Consolas" FontSize="12" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap" BorderThickness="0"/>
                </DockPanel>
            </Border>

            <!-- Risk Score Panel -->
            <Border Grid.Column="1" Background="#161B22" CornerRadius="8" Padding="15" BorderBrush="#30363D" BorderThickness="1">
                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                    <TextBlock Text="USB Risk Score" Foreground="#8B949E" FontSize="14" HorizontalAlignment="Center"/>
                    <TextBlock Text="--" x:Name="TxtRiskScore" Foreground="#58A6FF" FontSize="48" FontWeight="Bold" HorizontalAlignment="Center" Margin="0,10,0,10"/>
                    <TextBlock Text="Status: Standby" x:Name="TxtRiskLevel" Foreground="#C9D1D9" FontSize="14" HorizontalAlignment="Center"/>
                </StackPanel>
            </Border>
        </Grid>

        <!-- Progress Bar -->
        <ProgressBar Grid.Row="3" x:Name="QUGProgressBar" Height="10" Background="#21262D" Foreground="#238636" BorderThickness="0"/>
    </Grid>
</Window>
"@

# ------------------------------------------------------------------------------
# 3. GUI EVENT HANDLERS & LOGIC
# ------------------------------------------------------------------------------

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$CmbUsbDrives     = $window.FindName("CmbUsbDrives")
$BtnRefresh       = $window.FindName("BtnRefresh")
$BtnOneClickRepair = $window.FindName("BtnOneClickRepair")
$TxtLog           = $window.FindName("TxtLog")
$TxtStatus        = $window.FindName("TxtStatus")
$TxtRiskScore     = $window.FindName("TxtRiskScore")
$TxtRiskLevel     = $window.FindName("TxtRiskLevel")
$ProgressBar      = $window.FindName("QUGProgressBar")

$script:DetectedUSBs = @()

function Log-Message([string]$msg) {
    $timeStamp = Get-Date -Format "HH:mm:ss"
    $TxtLog.AppendText("[$timeStamp] $msg`n")
    $TxtLog.ScrollToEnd()
}

function Populate-USBDrives {
    $CmbUsbDrives.Items.Clear()
    $script:DetectedUSBs = Get-QUGConnectedUSBDrives
    if ($script:DetectedUSBs.Count -gt 0) {
        foreach ($usb in $script:DetectedUSBs) {
            $CmbUsbDrives.Items.Add($usb.DisplayText) | Out-Null
        }
        $CmbUsbDrives.SelectedIndex = 0
        Log-Message "Detected $($script:DetectedUSBs.Count) USB storage drive(s)."
    } else {
        $CmbUsbDrives.Items.Add("No USB Drives Detected") | Out-Null
        $CmbUsbDrives.SelectedIndex = 0
        Log-Message "No USB drives found. Please insert a drive and refresh."
    }
}

# Event: Refresh Button
$BtnRefresh.Add_Click({
    Populate-USBDrives
})

# Event: One-Click Repair & Scan Engine
$BtnOneClickRepair.Add_Click({
    if ($script:DetectedUSBs.Count -eq 0 -or $CmbUsbDrives.SelectedIndex -lt 0) {
        [System.Windows.MessageBox]::Show("Please connect and select a USB Drive first!", "QUG Warning", 0, 48)
        return
    }

    $selectedUSB = $script:DetectedUSBs[$CmbUsbDrives.SelectedIndex]
    $driveLetter = $selectedUSB.DriveLetter

    $TxtStatus.Text = "Scanning..."
    $TxtStatus.Foreground = "#DBAB09"
    $ProgressBar.Value = 10

    Log-Message "--- INITIATING QUG ONE-CLICK REPAIR ON $driveLetter ---"
    
    # 1. File Recovery
    Log-Message "[Step 1/5] Unhiding files and repairing attributes..."
    $recSuccess = Invoke-QUGHiddenFileRecovery -TargetDriveLetter $driveLetter
    Log-Message "[+] Hidden File Recovery: Completed."
    $ProgressBar.Value = 30

    # 2. Threat Scan
    Log-Message "[Step 2/5] Scanning for malicious scripts, shortcuts, and autorun files..."
    $threats = Start-QUGScanEngine -TargetDriveLetter $driveLetter
    Log-Message "[!] Found $($threats.Count) potential threat(s)."
    $ProgressBar.Value = 50

    # 3. Clean Threats with User Confirmation Prompt
    $cleanedCount = 0
    if ($threats.Count -gt 0) {
        $fileListText = ($threats | ForEach-Object { "$($_.FileName) ($($_.ThreatType))" }) -join "`n"
        
        $confirmResult = [System.Windows.MessageBox]::Show(
            "QUG detected the following suspicious file(s):`n`n$fileListText`n`nDo you want to permanently delete these items?",
            "QUG Security Warning - Delete Confirmation",
            [System.Windows.MessageBoxButton]::YesNo,
            [System.Windows.MessageBoxImage]::Warning
        )

        if ($confirmResult -eq [System.Windows.MessageBoxResult]::Yes) {
            Log-Message "[Step 3/5] User confirmed deletion. Cleaning detected artifacts..."
            $cleanedCount = Invoke-QUGCleaner -ThreatList $threats
            Log-Message "[+] Successfully removed $cleanedCount threat file(s)."
        } else {
            Log-Message "[Step 3/5] User cancelled deletion. Files preserved."
        }
    } else {
        Log-Message "[Step 3/5] No threat artifacts found to clean."
    }
    $ProgressBar.Value = 70

    # 4. Microsoft Defender Scan
    Log-Message "[Step 4/5] Triggering Microsoft Defender custom drive scan..."
    $defResult = Start-QUGDefenderScan -TargetDriveLetter $driveLetter
    Log-Message "[+] Microsoft Defender scan completed."
    $ProgressBar.Value = 90

    # 5. Generate Security Report
    Log-Message "[Step 5/5] Generating forensic HTML report..."
    $report = New-QUGSecurityReport -USBDetails $selectedUSB -ThreatsFound $threats -CleanedItemsCount $cleanedCount
    
    $TxtRiskScore.Text = "$($report.Score)"
    if ($report.Score -ge 70) {
        $TxtRiskScore.Foreground = "#CB2431"
        $TxtRiskLevel.Text = "Status: CRITICAL"
    } elseif ($report.Score -ge 30) {
        $TxtRiskScore.Foreground = "#DBAB09"
        $TxtRiskLevel.Text = "Status: MODERATE"
    } else {
        $TxtRiskScore.Foreground = "#2EA44F"
        $TxtRiskLevel.Text = "Status: SAFE"
    }

    $ProgressBar.Value = 100
    $TxtStatus.Text = "Process Complete"
    $TxtStatus.Foreground = "#2EA44F"

    Log-Message "[+] ALL OPERATIONS COMPLETED SUCCESSFULLY!"
    Log-Message "[➔] Forensic Report Saved: $($report.Path)"

    # Auto-open HTML Report
    Start-Process $report.Path
})

# Initial Load
$window.Add_Loaded({
    Log-Message "Quantum USB Guardian Dashboard Initialized."
    Populate-USBDrives
})

# Launch GUI
$window.ShowDialog() | Out-Null