# Folder Structure

The required workflow is:

```text
Clients
└── Client Name
    ├── Already on card
    ├── Disk Drill
    ├── FS-Long
    ├── FS-Short
    └── RS
```

`Clients` is the permanent root selected during installation.

`Client Name` is entered each time the utility is invoked.

The five subfolders are fixed in the current version.

## Included reference template

The repository contains a visual/reference copy under:

```text
template\
└── Clients\
    └── Client Name\
        ├── Already on card\
        ├── Disk Drill\
        ├── FS-Long\
        ├── FS-Short\
        └── RS\
```

Each empty folder contains a `.gitkeep` file so Git can preserve the structure.
