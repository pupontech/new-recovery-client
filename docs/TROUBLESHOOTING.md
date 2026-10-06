# Troubleshooting

## The right-click option is missing

On Windows 11, first check:

```text
Right-click > Show more options
```

If it is still missing:

1. Run `Install.cmd` again.
2. Close all File Explorer windows.
3. Reopen File Explorer.
4. Search the Start Menu for **New Recovery Client**.
5. Run `Test-New-Recovery-Client.cmd`.

If the Start Menu shortcut or test launcher works, the main utility is functioning and the problem is limited to Explorer's context-menu display.

## Nothing happens when I click the right-click command

Try:

```text
Start Menu > New Recovery Client
```

or:

```text
Test-New-Recovery-Client.cmd
```

Then inspect the runtime log:

```text
%LOCALAPPDATA%\NewRecoveryClient\NewRecoveryClient.log
```

## The wrong Clients directory is used

Run:

```text
Install.cmd
```

again and select the correct permanent root.

You can verify the current setting by opening:

```text
%LOCALAPPDATA%\NewRecoveryClient\ClientsRoot.txt
```

## PowerShell is blocked

This utility launches Windows PowerShell with:

```text
-ExecutionPolicy Bypass
```

for the utility process only.

In tightly managed business environments, Group Policy or endpoint-security software may still block local scripts. In that case, contact the system administrator or review the applicable security policy.

## The client folder already exists

This is expected behavior.

The utility asks whether it should add any missing standard subfolders. It does not delete or replace existing files.

## A network/NAS folder does not work

The selected root must be reachable by the current Windows user at the time the script runs.

For mapped drives:
- make sure the drive is connected;
- make sure the same user account can access it.

For UNC paths, use a location that is visible through the Windows folder picker and for which the current user has write permission.

## Log file

Runtime activity is logged to:

```text
%LOCALAPPDATA%\NewRecoveryClient\NewRecoveryClient.log
```

The log is the first place to check after an execution error.
