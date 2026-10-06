# Contributing

Contributions are welcome.

## Development guidelines

Keep the utility:
- simple;
- Windows-native;
- easy to audit;
- dependency-light;
- safe around existing client data.

Avoid adding behavior that deletes or overwrites existing recovery data.

## Pull requests

A pull request should include:
1. a clear description of the change;
2. the Windows versions tested;
3. whether installation, context-menu registration, folder creation, and uninstall were tested;
4. documentation updates when behavior changes.

## Folder-layout changes

Changes to the standard client-folder structure should update:
- `New-RecoveryClient.ps1`;
- `README.md`;
- `docs/FOLDER-STRUCTURE.md`;
- `template/`;
- `CHANGELOG.md`.
