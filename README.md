# New Recovery Client

A lightweight Windows utility that creates the same recovery-folder structure for every new client.

The project was built for a workflow where all jobs live under one permanent **Clients** folder and each new client gets the same set of recovery folders.

## Editions

This repository ships two editions of the same workflow:

1. **Standard edition** (this directory) — multi-file: separate installer, runtime, and uninstaller scripts, plus a reference `template/`, full `docs/`, and CI. This is the primary edition.
2. **Native PowerShell edition** (`native-powershell/`) — a single self-contained script (`Setup-New-RecoveryClient.ps1`) that installs, runs, and uninstalls from one file. Fewer files, identical folder layout and safety behavior. See its own [README](native-powershell/README.md).

Both editions create the identical folder structure and share the same safety rules (never delete client data, per-user only, no network access). Pick the standard edition for the extra documentation and CI, or the Native PowerShell edition for a minimal single-script install.

## Folder structure

If your permanent root is:

```text
D:\Clients
```

and you enter:

```text
John Smith
```

the utility creates:

```text
D:\Clients\
└── John Smith\
    ├── Already on card\
    ├── Disk Drill\
    ├── FS-Long\
    ├── FS-Short\
    └── RS\
```

After creation, the client's folder opens automatically in File Explorer.

## Features

- Windows Explorer right-click command: **New Recovery Client**
- Works when right-clicking:
  - empty space inside a folder;
  - an actual folder;
  - the Windows desktop background.
- Start Menu shortcut included as an alternate launcher.
- Permanent configurable `Clients` root.
- Client-name prompt for every new job.
- Automatically creates the standard recovery-folder layout.
- Existing client folders are handled safely:
  - no existing files are deleted;
  - the utility asks before filling in missing standard folders.
- Invalid Windows filename characters are removed.
- Reserved Windows names such as `CON`, `NUL`, and `COM1` are rejected.
- Runtime log for troubleshooting.
- Current-user installation; administrator rights are normally not required.
- Full uninstall support.


## How the right-click menu works

During installation, the utility adds a Windows Explorer context-menu entry named:

```text
New Recovery Client
```

You can invoke it in three places:

1. Right-click an empty area inside a File Explorer folder.
2. Right-click an actual folder in File Explorer.
3. Right-click the Windows desktop background.

On Windows 11, custom context-menu items commonly appear under the classic menu:

```text
Right-click
└── Show more options
    └── New Recovery Client
```

Selecting **New Recovery Client** does **not** create the project inside the folder you right-clicked.

The right-click item is only a convenient launcher.

The actual destination is always the permanent **Clients** folder that you selected when you ran `Install.cmd`.

For example, if you configured:

```text
D:\Clients
```

then you can right-click anywhere that the command is available, enter:

```text
John Smith
```

and the result will still be:

```text
D:\Clients\
└── John Smith\
    ├── Already on card\
    ├── Disk Drill\
    ├── FS-Long\
    ├── FS-Short\
    └── RS\
```

### What the installer adds

The installer creates current-user Windows context-menu entries for:

```text
Folder background
Folder itself
Desktop background
```

It also creates a Start Menu shortcut named:

```text
New Recovery Client
```

This gives you two ways to launch the tool:

```text
Right-click > New Recovery Client
```

or:

```text
Start Menu > New Recovery Client
```

### Why the Start Menu shortcut is included

Windows 11 sometimes hides traditional Explorer extensions under **Show more options**.

The Start Menu shortcut provides a backup launcher if you do not want to use the classic right-click menu.

You can also run:

```text
Test-New-Recovery-Client.cmd
```

from the repository folder to test the installed script directly.

### Registry entries used

The installer adds the following entries under the current Windows user:

```text
HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\NewRecoveryClient

HKEY_CURRENT_USER\Software\Classes\Directory\shell\NewRecoveryClient

HKEY_CURRENT_USER\Software\Classes\DesktopBackground\Shell\NewRecoveryClient
```

Because these are stored under `HKEY_CURRENT_USER`, administrator rights are normally not required.

### Removing the right-click menu

Run:

```text
Uninstall.cmd
```

This removes:

- the File Explorer right-click entries;
- the Desktop right-click entry;
- the Start Menu shortcut;
- the installed helper scripts and configuration.

It does **not** delete your `Clients` folder or any client recovery data.

### If the right-click option does not appear

First try:

```text
Right-click > Show more options
```

If it still does not appear:

1. Run `Install.cmd` again.
2. Close and reopen File Explorer.
3. Try **Start Menu > New Recovery Client**.
4. Run `Test-New-Recovery-Client.cmd`.

If the Start Menu or test launcher works, the folder-creation script itself is working and the problem is limited to the Explorer context-menu registration or display.


## Quick install

1. Download or clone this repository.
2. If using the ZIP, extract it first.
3. Double-click **`Install.cmd`**.
4. Choose the permanent folder that contains all clients, for example:

   ```text
   D:\Clients
   ```

5. Open File Explorer and right-click.
6. On Windows 11, choose **Show more options** if necessary.
7. Click **New Recovery Client**.
8. Enter the client's name.

You can also launch **New Recovery Client** from the Windows Start Menu.

## Quick test

After installation, run:

```text
Test-New-Recovery-Client.cmd
```

If the test works but the Explorer menu is missing, the folder-creation script is working and only the Explorer context-menu registration needs troubleshooting.

## Change the Clients destination

Run `Install.cmd` again and select the new permanent Clients folder.

## Uninstall

Run:

```text
Uninstall.cmd
```

Uninstalling removes the context-menu entries, Start Menu shortcut, installed script, configuration, and log.

It **does not delete any client folders or client data**.

## Installed files

The application installs into:

```text
%LOCALAPPDATA%\NewRecoveryClient\
```

The main installed files are:

```text
New-RecoveryClient.ps1
Launch-New-Recovery-Client.cmd
ClientsRoot.txt
NewRecoveryClient.log
```

The log is created after the utility is run.

## Documentation

- [Installation](docs/INSTALLATION.md)
- [Usage](docs/USAGE.md)
- [Folder structure](docs/FOLDER-STRUCTURE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Technical details](docs/TECHNICAL-DETAILS.md)
- [Post Haste background](docs/POST-HASTE.md)
- [Contributing](CONTRIBUTING.md)
- [Security](SECURITY.md)
- [Changelog](CHANGELOG.md)

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or newer
- Windows Explorer
- Permission to write to the selected Clients directory

## Project history

The original workflow was explored using **Post Haste** (https://www.digitalrebellion.com/posthaste/), a project-template application by Digital Rebellion. The final Windows implementation in this repository does not require Post Haste. It creates the folder layout directly from the Windows right-click menu.

See [docs/POST-HASTE.md](docs/POST-HASTE.md) for the original template approach.

## Forking and modifying (for AI agents)

This repository includes [AGENTS.md](AGENTS.md) — a developer guide with a full architecture breakdown, the safety invariants that must never break, and a copy-paste prompt you can hand to any AI agent (Copilot, Claude Code, Codex, Cursor, etc.) to fork and modify the project.

## License

MIT. See [LICENSE](LICENSE).
