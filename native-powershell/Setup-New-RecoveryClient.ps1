param(
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

$AppName = 'New Recovery Client'
$InstallDir = Join-Path $env:LOCALAPPDATA 'NewRecoveryClient'
$RuntimePath = Join-Path $InstallDir 'New-RecoveryClient.ps1'
$LauncherPath = Join-Path $InstallDir 'Launch-New-Recovery-Client.cmd'
$ConfigPath = Join-Path $InstallDir 'ClientsRoot.txt'
$LogPath = Join-Path $InstallDir 'NewRecoveryClient.log'
$ShortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\New Recovery Client.lnk'

$RegistrySubKeys = @(
    'Software\Classes\Directory\Background\shell\NewRecoveryClient',
    'Software\Classes\Directory\shell\NewRecoveryClient',
    'Software\Classes\DesktopBackground\Shell\NewRecoveryClient'
)

function Show-Info {
    param([string]$Message)
    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $AppName,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Show-ErrorBox {
    param([string]$Message)
    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $AppName,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

function Remove-ContextMenu {
    foreach ($SubKey in $RegistrySubKeys) {
        try {
            [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($SubKey, $false)
        }
        catch {
            # Continue removing the rest.
        }
    }
}

function Install-ContextMenu {
    param([string]$CommandLauncher)

    foreach ($SubKey in $RegistrySubKeys) {
        $Key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($SubKey)
        try {
            $Key.SetValue('', 'New Recovery Client', [Microsoft.Win32.RegistryValueKind]::String)
            $Key.SetValue('Icon', 'shell32.dll,3', [Microsoft.Win32.RegistryValueKind]::String)

            $CommandKey = $Key.CreateSubKey('command')
            try {
                $CommandKey.SetValue('', '"' + $CommandLauncher + '"', [Microsoft.Win32.RegistryValueKind]::String)
            }
            finally {
                $CommandKey.Close()
            }
        }
        finally {
            $Key.Close()
        }
    }
}

if ($Uninstall) {
    try {
        Remove-ContextMenu

        if (Test-Path -LiteralPath $ShortcutPath) {
            Remove-Item -LiteralPath $ShortcutPath -Force
        }

        if (Test-Path -LiteralPath $InstallDir) {
            Remove-Item -LiteralPath $InstallDir -Recurse -Force
        }

        Show-Info "New Recovery Client has been removed.`r`n`r`nYour actual Clients folder and recovery data were not deleted."
        exit 0
    }
    catch {
        Show-ErrorBox "Uninstall failed.`r`n`r`n$($_.Exception.Message)"
        exit 1
    }
}

try {
    $Dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $Dialog.Description = 'Choose the permanent Clients folder. Every new client will be created inside this folder.'
    $Dialog.ShowNewFolderButton = $true

    if ($Dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        exit 0
    }

    $ClientsRoot = $Dialog.SelectedPath

    if ([string]::IsNullOrWhiteSpace($ClientsRoot)) {
        throw 'No Clients folder was selected.'
    }

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Set-Content -LiteralPath $ConfigPath -Value $ClientsRoot -Encoding UTF8

    $RuntimeScript = @'
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

$InstallDir = Join-Path $env:LOCALAPPDATA 'NewRecoveryClient'
$ConfigPath = Join-Path $InstallDir 'ClientsRoot.txt'
$LogPath = Join-Path $InstallDir 'NewRecoveryClient.log'

function Write-Log {
    param([string]$Message)
    try {
        $Stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        Add-Content -LiteralPath $LogPath -Value "[$Stamp] $Message" -Encoding UTF8
    }
    catch {}
}

try {
    Write-Log 'Launcher started.'

    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "Configuration file not found: $ConfigPath. Re-run the installer."
    }

    $ClientsRoot = (Get-Content -LiteralPath $ConfigPath -Raw).Trim()

    if ([string]::IsNullOrWhiteSpace($ClientsRoot)) {
        throw 'The configured Clients folder is blank. Re-run the installer.'
    }

    $ClientName = [Microsoft.VisualBasic.Interaction]::InputBox(
        'Enter the client name:',
        'New Recovery Client',
        ''
    )

    if ([string]::IsNullOrWhiteSpace($ClientName)) {
        Write-Log 'Cancelled by user.'
        exit 0
    }

    foreach ($Character in [System.IO.Path]::GetInvalidFileNameChars()) {
        $ClientName = $ClientName.Replace([string]$Character, '')
    }

    $ClientName = $ClientName.Trim()
    while ($ClientName.EndsWith('.')) {
        $ClientName = $ClientName.Substring(0, $ClientName.Length - 1).TrimEnd()
    }

    if ([string]::IsNullOrWhiteSpace($ClientName)) {
        throw 'The client name is invalid after removing unsupported Windows filename characters.'
    }

    $ReservedNames = @(
        'CON','PRN','AUX','NUL',
        'COM1','COM2','COM3','COM4','COM5','COM6','COM7','COM8','COM9',
        'LPT1','LPT2','LPT3','LPT4','LPT5','LPT6','LPT7','LPT8','LPT9'
    )

    if ($ReservedNames -contains $ClientName.ToUpperInvariant()) {
        throw "'$ClientName' is a reserved Windows folder name."
    }

    if (-not (Test-Path -LiteralPath $ClientsRoot)) {
        New-Item -ItemType Directory -Path $ClientsRoot -Force | Out-Null
        Write-Log "Created Clients root: $ClientsRoot"
    }

    $ClientPath = Join-Path $ClientsRoot $ClientName

    if (Test-Path -LiteralPath $ClientPath) {
        $Response = [System.Windows.Forms.MessageBox]::Show(
            "This client folder already exists:`r`n`r`n$ClientPath`r`n`r`nCreate any missing standard folders inside it?",
            'New Recovery Client',
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($Response -ne [System.Windows.Forms.DialogResult]::Yes) {
            Write-Log "Existing client folder skipped: $ClientPath"
            exit 0
        }
    }
    else {
        New-Item -ItemType Directory -Path $ClientPath -Force | Out-Null
        Write-Log "Created client folder: $ClientPath"
    }

    $Folders = @(
        'Already on card',
        'Disk Drill',
        'FS-Long',
        'FS-Short',
        'RS'
    )

    foreach ($Folder in $Folders) {
        $FolderPath = Join-Path $ClientPath $Folder
        if (-not (Test-Path -LiteralPath $FolderPath)) {
            New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
            Write-Log "Created folder: $FolderPath"
        }
    }

    Write-Log "Completed successfully: $ClientPath"
    Start-Process -FilePath 'explorer.exe' -ArgumentList ('"{0}"' -f $ClientPath)
}
catch {
    $Message = $_.Exception.Message
    Write-Log "ERROR: $Message"

    [System.Windows.Forms.MessageBox]::Show(
        "New Recovery Client failed.`r`n`r`n$Message`r`n`r`nLog file:`r`n$LogPath",
        'New Recovery Client',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null

    exit 1
}
'@

    Set-Content -LiteralPath $RuntimePath -Value $RuntimeScript -Encoding UTF8

    $LauncherContents = @"
@echo off
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0New-RecoveryClient.ps1"
"@
    Set-Content -LiteralPath $LauncherPath -Value $LauncherContents -Encoding ASCII

    Remove-ContextMenu
    Install-ContextMenu -CommandLauncher $LauncherPath

    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $LauncherPath
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.IconLocation = 'shell32.dll,3'
    $Shortcut.Save()

    Show-Info "Installed successfully.`r`n`r`nClients root:`r`n$ClientsRoot`r`n`r`nLaunch it from:`r`n- File Explorer right-click menu`r`n- Desktop right-click menu`r`n- Start Menu > New Recovery Client`r`n`r`nOn Windows 11 it may appear under 'Show more options'."
}
catch {
    Show-ErrorBox "Installation failed.`r`n`r`n$($_.Exception.Message)"
    exit 1
}
