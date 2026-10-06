param()

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

$InstallDir = Join-Path $env:LOCALAPPDATA 'NewRecoveryClient'
$ConfigPath = Join-Path $InstallDir 'ClientsRoot.txt'
$LogPath = Join-Path $InstallDir 'NewRecoveryClient.log'

function Write-Log {
    param([string]$Message)

    try {
        $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        Add-Content -LiteralPath $LogPath -Value "[$Timestamp] $Message" -Encoding UTF8
    }
    catch {
        # Logging must never prevent the main operation.
    }
}

function Show-Error {
    param([string]$Message)

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        'New Recovery Client',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

try {
    Write-Log 'Launcher started.'

    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "Configuration file not found: $ConfigPath. Run Install.cmd again."
    }

    $ClientsRoot = (Get-Content -LiteralPath $ConfigPath -Raw).Trim()

    if ([string]::IsNullOrWhiteSpace($ClientsRoot)) {
        throw 'The configured Clients folder is blank. Run Install.cmd again.'
    }

    Write-Log "Configured Clients root: $ClientsRoot"

    $ClientName = [Microsoft.VisualBasic.Interaction]::InputBox(
        'Enter the client name:',
        'New Recovery Client',
        ''
    )

    if ([string]::IsNullOrWhiteSpace($ClientName)) {
        Write-Log 'Cancelled by user.'
        exit 0
    }

    # Remove characters Windows does not allow in folder names.
    foreach ($Character in [System.IO.Path]::GetInvalidFileNameChars()) {
        $ClientName = $ClientName.Replace([string]$Character, '')
    }

    # Windows folder names cannot end with a period or space.
    $ClientName = $ClientName.Trim()
    while ($ClientName.EndsWith('.')) {
        $ClientName = $ClientName.Substring(0, $ClientName.Length - 1).TrimEnd()
    }

    if ([string]::IsNullOrWhiteSpace($ClientName)) {
        throw 'The client name is invalid after removing unsupported Windows filename characters.'
    }

    $ReservedNames = @(
        'CON', 'PRN', 'AUX', 'NUL',
        'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
        'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'
    )

    if ($ReservedNames -contains $ClientName.ToUpperInvariant()) {
        throw "'$ClientName' is a reserved Windows folder name. Use a different client name."
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

    Show-Error "New Recovery Client failed.`r`n`r`n$Message`r`n`r`nLog file:`r`n$LogPath"
    exit 1
}
