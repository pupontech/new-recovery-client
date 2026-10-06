param()

$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Windows.Forms

$RegistrySubKeys = @(
    'Software\Classes\Directory\Background\shell\NewRecoveryClient',
    'Software\Classes\Directory\shell\NewRecoveryClient',
    'Software\Classes\DesktopBackground\Shell\NewRecoveryClient'
)

foreach ($SubKey in $RegistrySubKeys) {
    try {
        [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($SubKey, $false)
    }
    catch {
        # Keep uninstalling the remaining components.
    }
}

$ShortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\New Recovery Client.lnk'
if (Test-Path -LiteralPath $ShortcutPath) {
    Remove-Item -LiteralPath $ShortcutPath -Force
}

$InstallDir = Join-Path $env:LOCALAPPDATA 'NewRecoveryClient'
if (Test-Path -LiteralPath $InstallDir) {
    Remove-Item -LiteralPath $InstallDir -Recurse -Force
}

[System.Windows.Forms.MessageBox]::Show(
    'New Recovery Client has been uninstalled. Existing client folders and recovery data were not touched.',
    'Uninstall New Recovery Client',
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information
) | Out-Null
