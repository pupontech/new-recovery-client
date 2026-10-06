# AGENTS.md — AI Developer Guide

This file is for AI coding agents (Copilot, Claude Code, Codex, Cursor, o1, etc.) and for any developer forking this repository. Read it before making changes. It explains what this project is, how it is wired together, what must never break, and it ends with a copy-paste prompt you can hand to any AI to fork and modify the project.

## What this is

**New Recovery Client** is a small, dependency-free Windows PowerShell utility for data-recovery technicians. Every new recovery client needs the same folder skeleton, and this tool creates it with a single right-click + typed name.

It installs a **Windows Explorer context-menu command** (and a Start Menu shortcut) that, when invoked, prompts for a client name and creates this structure under one permanent `Clients` root chosen at install time:

```text
<Clients root>\<Client Name>\
├── Already on card\
├── Disk Drill\
├── FS-Long\
├── FS-Short\
└── RS\
```

## Relationship to Post Haste

This workflow was originally conceived as a project template for **Post Haste** (https://www.digitalrebellion.com/posthaste/), the free folder/project-template application by Digital Rebellion.

This repository re-implements that exact template natively in Windows, so **Post Haste is no longer required**. It is retained only as the conceptual origin of the folder layout. See `docs/POST-HASTE.md` for the background and the original template approach.

## Architecture (what each file does)

| File | Role |
| --- | --- |
| `Install.ps1` / `Install.cmd` | Copies the runtime into `%LOCALAPPDATA%\NewRecoveryClient\`, writes the chosen `Clients` root to `ClientsRoot.txt`, registers the three Explorer context-menu keys, and creates the Start Menu shortcut. |
| `New-RecoveryClient.ps1` | The actual runtime. Reads `ClientsRoot.txt`, prompts for the client name, sanitizes it, creates the client folder and the five standard subfolders (missing ones only), then opens the folder in Explorer. |
| `Uninstall.ps1` / `Uninstall.cmd` | Removes the three registry keys, the Start Menu shortcut, and the `%LOCALAPPDATA%\NewRecoveryClient` folder. **Never touches client data.** |
| `Test-New-Recovery-Client.cmd` | Test launcher that runs the installed runtime directly. |
| `template/` | A visual/reference copy of the folder skeleton (empty folders kept alive with `.gitkeep`). |
| `docs/` | Human-facing docs: installation, usage, folder structure, troubleshooting, technical details, and Post Haste background. |
| `.github/workflows/powershell-syntax.yml` | CI that parses every `.ps1` file on push/PR to catch syntax errors. |
| `VERSION`, `CHANGELOG.md`, `RELEASE-CHECKLIST.md` | Versioning and release bookkeeping. |

## Hard invariants — never break these

These are the project's safety rules. Any change that violates one is wrong:

1. **Never delete or overwrite existing client data.** The utility creates *missing* folders only; existing folders/files are never removed or renamed.
2. **Per-user only.** Everything lives under `%LOCALAPPDATA%` and `HKEY_CURRENT_USER`; administrator rights must not become a requirement.
3. **No network access, no data transmission.** Client names and paths stay on the machine.
4. **Dependency-light and auditable.** Plain PowerShell + built-in .NET APIs only; no third-party runtime.
5. **Uninstall must remain non-destructive** to the configured `Clients` directory.

## Where to change common things

- **Add/remove/rename a standard folder** → edit the `$Folders` array in `New-RecoveryClient.ps1` (line ~111), then update `README.md`, `docs/FOLDER-STRUCTURE.md`, `template/` (add/remove the matching `.gitkeep` folder), and `CHANGELOG.md`. This is also spelled out in `CONTRIBUTING.md`.
- **Change the context-menu label or icon** → edit `Register-ContextMenu` in `Install.ps1` and update `README.md` and `docs/INSTALLATION.md`.
- **Change the install location** → edit the `$InstallDir` line in both `Install.ps1` and `New-RecoveryClient.ps1`, and update `docs/TECHNICAL-DETAILS.md`.
- **Change the prompt/dialog wording** → edit the `MessageBox`/`InputBox` calls in `New-RecoveryClient.ps1` and `Install.ps1`.

## How to test a change

1. Parse-check every script: `Get-ChildItem -Recurse -Filter *.ps1 | % { [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$err); $err }` — or just push and let the CI workflow do it.
2. On Windows: run `Install.cmd`, then `Test-New-Recovery-Client.cmd`, then right-click in Explorer and on the desktop.
3. Verify existing-client behavior (a pre-existing client folder must prompt, not overwrite) and uninstall (client data must survive).
4. Follow `RELEASE-CHECKLIST.md` before tagging a release.

---

## Copy-paste modification prompt

Give the block below to any AI agent after forking this repo. It is self-contained: it describes the project, the files, and the invariants, so the agent does not need this conversation.

````text
You are working on "New Recovery Client", a dependency-free Windows PowerShell
utility that creates a standard folder structure for each new data-recovery
client. It installs a Windows Explorer right-click command ("New Recovery
Client") and a Start Menu shortcut; invoking either prompts for a client name
and creates this skeleton under a permanent "Clients" root the user chose at
install time:

    <Clients root>\<Client Name>\
    ├── Already on card\
    ├── Disk Drill\
    ├── FS-Long\
    ├── FS-Short\
    └── RS\

Key files:
- Install.ps1 / Install.cmd — copies runtime to %LOCALAPPDATA%\NewRecoveryClient,
  writes ClientsRoot.txt, registers the three HKCU Explorer context-menu keys,
  and creates the Start Menu shortcut.
- New-RecoveryClient.ps1 — the runtime: reads ClientsRoot.txt, prompts for the
  client name (InputBox), sanitizes it (strips invalid filename chars, trims
  trailing dots/spaces, rejects reserved names like CON/NUL/COM1), creates the
  client folder and the five standard subfolders (missing ones only), then opens
  the folder in Explorer.
- Uninstall.ps1 / Uninstall.cmd — removes the registry keys, Start Menu shortcut,
  and the %LOCALAPPDATA%\NewRecoveryClient folder. Never touches client data.
- Test-New-Recovery-Client.cmd — runs the installed runtime directly.
- template/ — reference copy of the folder skeleton (empty folders use .gitkeep).
- docs/ — installation, usage, folder structure, troubleshooting, technical
  details, and Post Haste background.
- .github/workflows/powershell-syntax.yml — CI parses every .ps1 on push/PR.

The folder layout originated as a Post Haste project template
(https://www.digitalrebellion.com/posthaste/); the repo re-implements it natively,
so Post Haste is not required.

Hard invariants (do not violate):
1. Never delete or overwrite existing client data — create missing folders only.
2. Per-user only: %LOCALAPPDATA% and HKEY_CURRENT_USER; no admin requirement.
3. No network access; never transmit client names or paths.
4. Dependency-light: plain PowerShell + built-in .NET APIs only.
5. Uninstall must remain non-destructive to the configured Clients directory.

When you change the standard folder list, update ALL of: the $Folders array in
New-RecoveryClient.ps1, README.md, docs/FOLDER-STRUCTURE.md, template/ (matching
.gitkeep folders), and CHANGELOG.md.

Test by parse-checking every .ps1 (the CI workflow does this automatically), then
on Windows running Install.cmd, Test-New-Recovery-Client.cmd, the Explorer
right-click, an existing-client prompt, and Uninstall.cmd (confirming client data
survives).

Now perform the requested modification, keeping the invariants above.
````
