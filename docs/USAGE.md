# Usage

## Normal workflow

1. Right-click in File Explorer, on a folder, or on the Windows desktop.
2. Choose **New Recovery Client**.
3. On Windows 11, use **Show more options** if required.
4. Enter the client name.
5. The utility creates the client's folder under the configured Clients root.
6. The standard recovery folders are created inside it.
7. The new client folder opens automatically.

## Example

Configured root:

```text
D:\Clients
```

Entered client name:

```text
John Smith
```

Created structure:

```text
D:\Clients\John Smith\
├── Already on card\
├── Disk Drill\
├── FS-Long\
├── FS-Short\
└── RS\
```

## Existing client

If:

```text
D:\Clients\John Smith
```

already exists, the utility asks whether it should create any missing standard folders.

Choosing **Yes** only adds missing folders. Existing files and folders are left alone.

Choosing **No** cancels the operation.

## Client-name cleanup

Windows does not allow some characters in folder names. Unsupported filename characters are removed automatically.

Windows reserved names such as:

```text
CON
PRN
AUX
NUL
COM1
LPT1
```

are rejected.

## Start Menu

If you do not want to use the right-click menu, search the Start Menu for:

```text
New Recovery Client
```

## Test launcher

From the repository folder, run:

```text
Test-New-Recovery-Client.cmd
```

This directly invokes the installed runtime script.
