# Installation

## Recommended installation

1. Download the repository ZIP from GitHub, or clone the repository.
2. Extract the ZIP to a normal folder.
3. Double-click:

   ```text
   Install.cmd
   ```

4. A folder picker appears.
5. Select the permanent folder under which all client folders should be created.

Example:

```text
D:\Clients
```

6. The installer copies the runtime files to:

```text
%LOCALAPPDATA%\NewRecoveryClient\
```

7. The installer adds **New Recovery Client** to:
   - File Explorer folder-background context menus;
   - File Explorer folder context menus;
   - the Desktop background context menu;
   - the Windows Start Menu.

## Windows 11 context menu

Windows 11 commonly places traditional context-menu commands under:

```text
Right-click
└── Show more options
    └── New Recovery Client
```

The Start Menu shortcut is provided so the utility can still be launched without using the Explorer context menu.

## Administrator rights

The installer writes under the current user's profile and `HKEY_CURRENT_USER`, so administrator rights are normally not required.

## Reinstall or change the destination

Run `Install.cmd` again.

Choose the new permanent Clients folder. The existing runtime files and configuration will be replaced.

## Where the destination is stored

The selected Clients root is saved in:

```text
%LOCALAPPDATA%\NewRecoveryClient\ClientsRoot.txt
```

You can inspect this file to confirm the configured destination.
