# New Recovery Client — Native PowerShell Edition

This is the simplified native Windows version of the workflow.

It does **not** require Post Haste or any third-party program.

The installer is a single self-contained PowerShell script that:

1. asks you to choose your permanent `Clients` folder;
2. installs the runtime script under your Windows user profile;
3. adds **New Recovery Client** to the Windows right-click menu;
4. adds a Start Menu shortcut;
5. stores the chosen Clients location;
6. provides an uninstall mode.

## What it creates

If your permanent Clients folder is:

```text
D:\Clients
```

and you enter:

```text
John Smith
```

the result is:

```text
D:\Clients\
└── John Smith\
    ├── Already on card\
    ├── Disk Drill\
    ├── FS-Long\
    ├── FS-Short\
    └── RS\
```

The new client folder opens automatically after it is created.

---

## Installation

### Easiest method

1. Extract the ZIP.
2. Double-click:

```text
Install.cmd
```

3. Choose your permanent `Clients` folder.
4. Installation is complete.

No administrator rights should normally be required because everything is installed for the current Windows user.

### PowerShell-only method

You can also run the installer directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File .\Setup-New-RecoveryClient.ps1
```

---

## Using the right-click menu

After installation, the utility adds:

```text
New Recovery Client
```

to three Windows locations:

- right-clicking empty space inside a File Explorer folder;
- right-clicking a folder;
- right-clicking the desktop background.

On Windows 11, it will usually appear here:

```text
Right-click
└── Show more options
    └── New Recovery Client
```

### Important: the folder you right-click does not become the destination

The right-click menu is only a launcher.

All new clients are always created inside the permanent `Clients` folder you selected during installation.

For example, even if you right-click the Desktop, if the configured root is:

```text
D:\Clients
```

and you enter:

```text
Jane Doe
```

the utility creates:

```text
D:\Clients\Jane Doe\
```

with the standard five subfolders.

---

## Start Menu launcher

The installer also creates:

```text
Start Menu > New Recovery Client
```

This is useful if you do not want to use the classic Windows 11 right-click menu.

---

## What happens when you create a client

The utility:

1. prompts for the client's name;
2. removes unsupported Windows filename characters;
3. rejects reserved Windows names such as `CON`, `NUL`, and `COM1`;
4. creates the client folder;
5. creates the five standard recovery folders;
6. opens the client folder in File Explorer.

If the client already exists, the utility asks whether it should create any missing standard folders.

Existing client files are not deleted or overwritten.

---

## Changing the Clients folder

Run:

```text
Install.cmd
```

again and select a different root.

The saved destination will be replaced.

---

## Uninstall

Double-click:

```text
Uninstall.cmd
```

or run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File .\Setup-New-RecoveryClient.ps1 -Uninstall
```

Uninstall removes:

- Explorer right-click entries;
- Desktop right-click entry;
- Start Menu shortcut;
- installed helper files;
- saved configuration;
- runtime log.

It does **not** delete your actual `Clients` folder or any recovery data.

---

## Installed location

The utility installs its working files here:

```text
%LOCALAPPDATA%\NewRecoveryClient\
```

Files include:

```text
New-RecoveryClient.ps1
Launch-New-Recovery-Client.cmd
ClientsRoot.txt
NewRecoveryClient.log
```

The log appears after the utility has been run.

---

## Registry entries

The installer uses current-user registry entries:

```text
HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\NewRecoveryClient

HKEY_CURRENT_USER\Software\Classes\Directory\shell\NewRecoveryClient

HKEY_CURRENT_USER\Software\Classes\DesktopBackground\Shell\NewRecoveryClient
```

Because these are under `HKEY_CURRENT_USER`, the installer normally does not need administrator privileges.

---

## Troubleshooting

### The right-click option is missing

First check:

```text
Right-click > Show more options
```

If it is still missing:

1. run `Install.cmd` again;
2. close and reopen File Explorer;
3. use the Start Menu shortcut;
4. check the runtime log.

### Nothing happens when I click it

Try:

```text
Start Menu > New Recovery Client
```

Then inspect:

```text
%LOCALAPPDATA%\NewRecoveryClient\NewRecoveryClient.log
```

### Wrong destination

Run `Install.cmd` again and choose the correct Clients folder.

You can also verify the configured destination here:

```text
%LOCALAPPDATA%\NewRecoveryClient\ClientsRoot.txt
```

---

## Files in this package

```text
Setup-New-RecoveryClient.ps1
Install.cmd
Uninstall.cmd
README.md
LICENSE
```

`Setup-New-RecoveryClient.ps1` is the actual self-contained installer/uninstaller.

`Install.cmd` and `Uninstall.cmd` are only convenience launchers.

---

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or newer
- File Explorer
- write access to the selected Clients folder

No third-party application is required.

---

## Security and privacy

The script runs locally.

It does not:

- connect to the Internet;
- upload client names;
- send filesystem information anywhere;
- install a service;
- require an online account.

All configuration is stored locally under your Windows user profile.
