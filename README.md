# RAR-backup-batch-file
batch file w/RAR in order to backup files

profile-based automation tool for WinRAR. It allows you to manage multiple backup sources with support for **Full** and **Incremental** backups, automatic date/time stamping, and custom exclusion lists.

---
# WinRAR Batch Backup Automation
A flexible Windows batch script to automate compressed backups using WinRAR. It features dynamic profile selection, exclusion management, and automated incremental/full backup workflows.
## 🚀 Features
* **Dynamic Profiles:** Automatically detects `.txt` files in the `Scripts/` folder as backup profiles.
* **Two Backup Modes:**
* **Full:** Archives all specified files.
* **Incremental:** Uses the Windows "Archive Attribute" to only back up files that have changed since the last run.

* **Automatic Exclusions:** Supports profile-specific exclusion lists (e.g., `Work_exclusion.txt`).
* **Smart Naming:** Uses WinRAR switches to append timestamps (`YYYYMMDD-HHMMSS`) to filenames automatically.
* **Error Logging:** Maintains a central `_BackupLog.txt` for all backup operations.
* **Recovery Records:** Includes a 5% recovery record (`-rr5p`) to protect archives against data corruption.

## 📁 Directory Structure
Before running the script, organize your files as follows:

```text
BackupTool/
├── backup_script.bat        # The main batch file
├── Scripts/                 # Place your backup lists here (.txt)
│   ├── WorkDocuments.txt    # Example: List of paths to back up
│   └── Photos.txt
└── Exclusions/              # (Optional) Profile-specific exclusions
    └── WorkDocuments_exclusion.txt
```

## ⚙️ Setup & Configuration

1. **Edit Path Variables:** Open the `.bat` file and update the following lines to match your system:
```batch
set "WINRAR_PATH=C:\Path\To\Rar.exe"
set "BACKUP_DESTINATION=D:\MyBackups"

```

2. **Create a Profile:** Create a `.txt` file inside the `Scripts/` folder. Inside this file, list the folders or files you want to back up (one per line).
3. **Optional Exclusions:** To skip specific files/folders, create a file in `Exclusions/` named `[ProfileName]_exclusion.txt`.

## 🛠 Usage

1. Run `backup_script.bat`.
2. **Select Profile:** Choose from the list of detected `.txt` files.
3. **Select Type:**
* Choose **[1]** for Incremental (faster, only changed files).
* Choose **[2]** for Full (complete snapshot).


4. **Review:** Once finished, the script will log the result and open the destination folder.

## 🔍 WinRAR Switches Used

| Switch | Description |
| --- | --- |
| `-m5` | Set compression level to Best. |
| `-ep1` | Exclude base folder from paths (cleaner internal structure). |
| `-rr5p` | Add 5% recovery record. |
| `-ag` | Generate archive name using current date/time. |
| `-ao` | (Incremental only) Add files with Archive attribute set. |
| `-ac` | (Incremental only) Clear Archive attribute after compression. |

## ⚠️ Requirements

* **WinRAR:** You must have WinRAR installed. It is recommended to point the script to `Rar.exe` (the command-line version) usually found in the WinRAR installation folder.
* **Permissions:** Ensure the script has write access to your `BACKUP_DESTINATION`.

