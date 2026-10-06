param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

function Show-Error {
    param([string]$Message)

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        'Install New Recovery Client',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

function Register-ContextMenu {
    param(
        [string]$SubKeyPath,
        [string]$LauncherPath
    )

    $Key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($SubKeyPath)
    try {
        $Key.SetValue('', 'New Recovery Client', [Microsoft.Win32.RegistryValueKind]::String)
        $Key.SetValue('Icon', 'shell32.dll,3', [Microsoft.Win32.RegistryValueKind]::String)

        $CommandKey = $Key.CreateSubKey('command')
        try {
            # Quote the .cmd path because %LOCALAPPDATA% can theoretically contain spaces.
            $CommandKey.SetValue('', '"' + $LauncherPath + '"', [Microsoft.Win32.RegistryValueKind]::String)
        }
        finally {
            $CommandKey.Close()
        }
    }
    finally {
        $Key.Close()
    }
}

try {
    $InstallDir = Join-Path $env:LOCALAPPDATA 'NewRecoveryClient'
    $SourceRunner = Join-Path $PSScriptRoot 'New-RecoveryClient.ps1'
    $TargetRunner = Join-Path $InstallDir 'New-RecoveryClient.ps1'
    $ConfigPath = Join-Path $InstallDir 'ClientsRoot.txt'
    $LauncherPath = Join-Path $InstallDir 'Launch-New-Recovery-Client.cmd'

    if (-not (Test-Path -LiteralPath $SourceRunner)) {
        throw "Missing file: $SourceRunner"
    }

    $Dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $Dialog.Description = 'Choose the permanent Clients folder. New client folders will always be created here.'
    $Dialog.ShowNewFolderButton = $true

    if ($Dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        exit 0
    }

    $ClientsRoot = $Dialog.SelectedPath

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Copy-Item -LiteralPath $SourceRunner -Destination $TargetRunner -Force
    Set-Content -LiteralPath $ConfigPath -Value $ClientsRoot -Encoding UTF8

    $LauncherContents = @"
@echo off
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0New-RecoveryClient.ps1"
"@

    Set-Content -LiteralPath $LauncherPath -Value $LauncherContents -Encoding ASCII

    # Explorer folder-background menu.
    Register-ContextMenu `
        -SubKeyPath 'Software\Classes\Directory\Background\shell\NewRecoveryClient' `
        -LauncherPath $LauncherPath

    # Explorer menu when right-clicking a folder.
    Register-ContextMenu `
        -SubKeyPath 'Software\Classes\Directory\shell\NewRecoveryClient' `
        -LauncherPath $LauncherPath

    # Desktop background menu.
    Register-ContextMenu `
        -SubKeyPath 'Software\Classes\DesktopBackground\Shell\NewRecoveryClient' `
        -LauncherPath $LauncherPath

    # Start Menu shortcut as a second invocation method.
    $StartMenuPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
    $ShortcutPath = Join-Path $StartMenuPath 'New Recovery Client.lnk'

    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $LauncherPath
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.IconLocation = 'shell32.dll,3'
    $Shortcut.Save()

    [System.Windows.Forms.MessageBox]::Show(
        "Installed successfully.`r`n`r`nClient root:`r`n$ClientsRoot`r`n`r`nYou can now use:`r`n- Right-click in File Explorer`r`n- Right-click the Desktop`r`n- Start Menu > New Recovery Client`r`n`r`nOn Windows 11 the right-click command may be under 'Show more options'.",
        'Install New Recovery Client',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}
catch {
    Show-Error "Installation failed.`r`n`r`n$($_.Exception.Message)"
    exit 1
}
