<div align="center">

# 🛡️ Quantum USB Guardian (QUG)

### Advanced USB Malware Detection, File Recovery & Digital Forensics Suite

A lightweight Windows Endpoint Security solution built with **PowerShell**, **WPF**, and **Microsoft Defender**.

<p>
  <img src="https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-5391FE?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Version-v1.0-success?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/Status-Stable-brightgreen?style=for-the-badge" alt="Status">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License">
</p>

### Made By **Abdullah_16**

*Cybersecurity • Digital Forensics • Windows Endpoint Protection*

</div>



#  Overview

**Quantum USB Guardian (QUG)** is a lightweight Windows-based USB security utility developed to detect, analyze, and remove common USB-borne threats while preserving legitimate user files.

The project focuses on protecting removable storage devices against shortcut viruses (`.lnk`), hidden-file attacks, malicious scripts, suspicious executables, and Autorun-based malware. It combines heuristic threat detection, automated file recovery, Microsoft Defender integration, and forensic report generation into a single easy-to-use graphical application.

Designed for students, cybersecurity enthusiasts, and IT professionals, Quantum USB Guardian simplifies USB incident response through an intuitive WPF dashboard while providing detailed forensic reports for further analysis.



#  Objectives

- Detect malicious files commonly found on infected USB drives.
- Recover files hidden by malware.
- Identify suspicious scripts and executables using heuristic analysis.
- Integrate Microsoft Defender for secondary malware verification.
- Generate forensic reports with SHA-256 hashes and dynamic risk scores.
- Provide a simple graphical interface for USB threat remediation.

---

#  Key Highlights

- Hidden File Recovery
- Heuristic Threat Scanning
- Microsoft Defender Integration
- HTML Forensic Report Generation
- SHA-256 File Hashing
- Safe File Removal Confirmation
- Modern PowerShell WPF Dashboard



# Table of Contents

- [Overview](#-overview)
- [Objectives](#-objectives)
- [Key Highlights](#-key-highlights)
- [Features](#-features)
- [System Architecture](#️-system-architecture)
- [Workflow](#-workflow)
- [Project Structure](#-project-structure)
- [Installation](#️-installation)
- [Usage](#-usage)
- [Screenshots](#-screenshots)
- [Forensic Report](#-forensic-report)
- [Roadmap](#️-roadmap)
- [System Requirements](#-system-requirements)
- [Current Limitations](#️-current-limitations)
- [Future Improvements](#-future-improvements)
- [Contributing](#-contributing)
- [Security](#-security)
- [License](#-license)
- [Author](#-author)
- [Acknowledgements](#-acknowledgements)
- [Disclaimer](#️-disclaimer)

---

> **Current Release:** **Version 1.0**  
> **Project Status:** ✅ Stable Development Release
>
> # Features

| Feature | Description |
|----------|-------------|
| 📂 Hidden File Recovery | Restores files hidden by malware using Windows attribute recovery. |
| 🔍 Heuristic Threat Scanner | Identifies suspicious scripts, shortcuts, and potentially malicious executables. |
| ⚠️ Shortcut Virus Detection | Detects `.lnk` shortcut malware and related malicious payloads. |
| 📄 Autorun Detection | Finds suspicious `autorun.inf` files commonly used by USB malware. |
| 🛡️ Microsoft Defender Integration | Launches Microsoft Defender for additional malware verification. |
| 📊 Forensic HTML Reporting | Generates an HTML report summarizing scan findings and calculated risk score. |
| 🔐 SHA-256 Hash Generation | Creates SHA-256 hashes for detected files to support analysis. |
| ❓ Safe Deletion Confirmation | Requests user confirmation before removing detected items. |
| 🖥️ WPF Dashboard | Modern graphical interface built with Windows Presentation Foundation (WPF). |

---

#  System Architecture

```text
                    +--------------------------------+
                    |        USB Device Inserted     |
                    +---------------+----------------+
                                    |
                                    ▼
                    +--------------------------------+
                    |      USB Detection Module      |
                    +---------------+----------------+
                                    |
                                    ▼
                    +--------------------------------+
                    |     File Recovery Module       |
                    | (Hidden/System Attribute Fix)  |
                    +---------------+----------------+
                                    |
                                    ▼
                    +--------------------------------+
                    |   Heuristic Threat Scanner     |
                    +---------------+----------------+
                                    |
                                    ▼
                    +--------------------------------+
                    | Microsoft Defender Integration |
                    +---------------+----------------+
                                    |
                                    ▼
                    +--------------------------------+
                    |  Forensic Report Generator     |
                    +---------------+----------------+
                                    |
                                    ▼
                    +--------------------------------+
                    |     HTML Security Report       |
                    +--------------------------------+
```

---

#  Workflow

```text
USB Device Connected
          │
          ▼
Detect USB Drive
          │
          ▼
Recover Hidden Files
          │
          ▼
Heuristic Threat Scan
          │
          ▼
Detect Suspicious Files
          │
          ▼
Ask User Confirmation
          │
     ┌────┴────┐
     │         │
   Delete    Ignore
     │         │
     └────┬────┘
          ▼
Microsoft Defender Scan
          │
          ▼
Generate HTML Report
          │
          ▼
Scan Completed
```

---

#  Project Structure

```text
Quantum-USB-Guardian/
│
├── src/
│   ├── QUG_MainApp.ps1
│   ├── USBDetector.ps1
│   ├── ThreatScanner.ps1
│   ├── FileRecovery.ps1
│   ├── DefenderEngine.ps1
│   └── ForensicReport.ps1
│
├── docs/
│   ├── Technical_Report.txt
│   ├── Project_Report.pdf
│   └── screenshots/
│
├── assets/
│   ├── banner.png
│   ├── logo.png
│   └── icons/
│
├── README.md
├── LICENSE
├── CHANGELOG.md
├── .gitignore
└── VERSION
```

---

#  Core Modules

| Module | Responsibility |
|---------|----------------|
| **QUG_MainApp.ps1** | Main application entry point and GUI controller |
| **USBDetector.ps1** | Detects connected removable drives |
| **ThreatScanner.ps1** | Performs heuristic malware scanning |
| **FileRecovery.ps1** | Restores files hidden by malware |
| **DefenderEngine.ps1** | Integrates with Microsoft Defender |
| **ForensicReport.ps1** | Generates forensic HTML reports |

---

#  Technologies Used

| Technology | Purpose |
|------------|---------|
| PowerShell | Core application logic |
| Windows Presentation Foundation (WPF) | Graphical User Interface |
| Microsoft Defender | Secondary malware verification |
| HTML & CSS | Forensic report generation |
| SHA-256 | File integrity verification |
| Windows File Attributes | Hidden/System file recovery |

---

#  Installation

## Requirements

- Windows 10 / Windows 11
- Windows PowerShell 5.1 or PowerShell 7+
- Microsoft Defender Enabled
- Administrator Privileges

---

## Clone Repository

```powershell
git clone https://github.com/itssiamsarker/Quantum-USB-Guardian.git
```

Navigate to the project directory:

```powershell
cd Quantum-USB-Guardian
```

Run the application:

```powershell
.\src\QUG_MainApp.ps1
```

> **Note:** Run PowerShell as **Administrator** for full functionality.

---

#  Quick Start

1. Connect a USB flash drive.
2. Launch **Quantum USB Guardian**.
3. Select the detected USB drive.
4. Click **Repair & Scan**.
5. Wait for the scan to complete.
6. Review detected threats.
7. Confirm removal if necessary.
8. Open the generated HTML forensic report.

---

#  Usage

### Step 1 — Connect USB Device

Insert the removable USB storage device into your computer.

---

### Step 2 — Launch Application

Start **Quantum USB Guardian** with administrator privileges.

---

### Step 3 — Select USB Drive

Choose the detected removable drive from the dashboard.

---

### Step 4 — Repair & Scan

Click the **Repair & Scan** button.

The application will automatically:

- Recover hidden files
- Detect shortcut viruses
- Scan suspicious scripts
- Identify suspicious executables
- Search for Autorun-based malware

---

### Step 5 — Review Results

Detected items are displayed inside the activity log.

If suspicious files are found, the application requests confirmation before deletion.

---

### Step 6 — Generate Report

After the scan completes, an HTML forensic report is generated automatically.

---

#  Example Scan Process

```text
[✓] USB Device Detected

↓

[✓] Hidden Files Restored

↓

[✓] Shortcut Virus Scan

↓

[✓] Suspicious Files Found

↓

[✓] User Confirmation

↓

[✓] Microsoft Defender Scan

↓

[✓] HTML Report Generated

↓

Completed Successfully
```

---

#  Forensic Report

Each completed scan generates an HTML report containing:

- Scan Date & Time
- USB Drive Information
- Total Files Scanned
- Suspicious Files
- Deleted Items
- SHA-256 Hashes
- Risk Score
- Microsoft Defender Status
- Scan Summary

---

#  Screenshots

> Screenshots will be added in future updates.

### Main Dashboard

```
docs/screenshots/dashboard.png
```

---

### Threat Detection

```
docs/screenshots/threat_detection.png
```

---

### HTML Report

```
docs/screenshots/report.png
```

---

#  Roadmap

## Version 1.0

- [x] USB Device Detection
- [x] Hidden File Recovery
- [x] Heuristic Malware Scanner
- [x] Microsoft Defender Integration
- [x] HTML Forensic Reports
- [x] SHA-256 File Hashing
- [x] WPF Dashboard

---

## Upcoming Features

- [ ] Quarantine System
- [ ] Signature-Based Detection
- [ ] Automatic Threat Definition Updates
- [ ] Dark Mode Interface
- [ ] Multi-language Support
- [ ] Drag & Drop USB Scan
- [ ] Scan History Viewer
- [ ] PDF Report Export
- [ ] Cloud Threat Intelligence
- [ ] Real-time USB Monitoring

---

#  System Requirements

| Requirement | Supported |
|------------|-----------|
| Operating System | Windows 10 / Windows 11 |
| PowerShell | Version 5.1 or 7.x |
| Windows Defender | Enabled |
| Administrator Privileges | Required |
| Internet Connection | Optional (for Defender updates) |

---

#  Current Limitations

While Quantum USB Guardian provides an effective defense against common USB-borne threats, the current version has several limitations:

- Windows-only application.
- Designed primarily for removable USB storage devices.
- Heuristic detection may not identify every newly emerging malware family.
- Relies on Microsoft Defender for secondary malware verification.
- Does not currently include real-time USB monitoring.
- Cloud-based threat intelligence is not yet implemented.

---

#  Future Improvements

The following enhancements are planned for future releases:

- Real-Time USB Monitoring
- Threat Quarantine System
- Automatic Signature Updates
- Digital Signature Verification
- Cloud Threat Intelligence
- Offline Threat Database
- Scheduled USB Scanning
- Multi-Language Support
- Dark Mode
- Scan History Database
- PDF & JSON Report Export
- Email Notification Support
- Plugin Architecture
- Portable Standalone Edition

---

#  Contributing

Contributions are welcome!

If you would like to improve Quantum USB Guardian:

1. Fork this repository.
2. Create a new feature branch.
3. Commit your changes.
4. Push your branch.
5. Open a Pull Request.

Suggestions, bug reports, and feature requests are always appreciated.

---

#  Security

If you discover a security issue or vulnerability related to this project, please open a GitHub Issue or submit a responsible disclosure with detailed reproduction steps.

---

#  License

This project is licensed under the **MIT License**.

See the **LICENSE** file for additional information.

---

#  Author

<div align="center">

## Abdullah Ibn Hasan 

### Department Of Cyber Security Engineering, UFTB

Cybersecurity Enthusiast • Windows Security Research • Digital Forensics

</div>

---

#  Acknowledgements

Special thanks to:

- Microsoft PowerShell
- Windows Presentation Foundation (WPF)
- Microsoft Defender
- Open-source cybersecurity community
- Everyone supporting defensive security research

---

#  Disclaimer

Quantum USB Guardian (QUG) is intended for **educational, defensive security, malware analysis, and digital forensic purposes only**.

This software is designed to help detect and remove common USB-borne threats while assisting users in recovering legitimate files affected by malware.

The developer does **not** guarantee detection of all malware variants and shall **not** be held responsible for any misuse, data loss, or damage resulting from improper use of this software.

Always test the application in a controlled environment before deploying it on production systems.

---

<div align="center">

##  If you found this project useful, consider giving it a Star!

### Thank you for visiting the Quantum USB Guardian repository.

🛡️ Stay Safe • Stay Secure • Keep Learning

</div>
