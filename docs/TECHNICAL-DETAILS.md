# Technical Details

## Runtime

The project uses:

- Windows PowerShell;
- Windows Forms for dialogs;
- `Microsoft.VisualBasic.Interaction.InputBox` for the client-name prompt;
- current-user Windows Registry keys for Explorer integration;
- a Windows shell shortcut for the Start Menu.

No third-party runtime or application is required.

## Installation path

```text
%LOCALAPPDATA%\NewRecoveryClient\
```

Installed files:

```text
New-RecoveryClient.ps1
Launch-New-Recovery-Client.cmd
ClientsRoot.txt
```

Generated after use:

```text
NewRecoveryClient.log
```

## Registry keys

The installer creates the following current-user keys:

```text
HKCU\Software\Classes\Directory\Background\shell\NewRecoveryClient
HKCU\Software\Classes\Directory\shell\NewRecoveryClient
HKCU\Software\Classes\DesktopBackground\Shell\NewRecoveryClient
```

Each key calls the launcher stored under `%LOCALAPPDATA%\NewRecoveryClient`.

The installer uses the .NET `Microsoft.Win32.Registry` API instead of relying on PowerShell registry-provider default-value behavior.

## Start Menu shortcut

The installer creates:

```text
%APPDATA%\Microsoft\Windows\Start Menu\Programs\New Recovery Client.lnk
```

## Destination behavior

The folder that is right-clicked is **not** used as the destination.

The permanent destination is read from:

```text
%LOCALAPPDATA%\NewRecoveryClient\ClientsRoot.txt
```

This ensures the structure is always:

```text
Configured Clients Root
└── Entered Client Name
    ├── Already on card
    ├── Disk Drill
    ├── FS-Long
    ├── FS-Short
    └── RS
```

## Existing-data behavior

The utility creates missing directories only.

It does not:
- delete client folders;
- delete files;
- overwrite recovery output;
- rename existing client data.

## Error handling

Execution uses `$ErrorActionPreference = 'Stop'` so failures enter the main exception handler.

Runtime failures:
- are shown in a Windows error dialog;
- are written to the log file when possible.

## Uninstall

The uninstaller removes:
- all three current-user context-menu registry keys;
- the Start Menu shortcut;
- `%LOCALAPPDATA%\NewRecoveryClient`.

It intentionally does not access or remove the configured Clients directory.
