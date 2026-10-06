# Security

## Supported versions

The latest release is the supported version.

## Reporting a vulnerability

Do not include sensitive client information, real recovery data, credentials, or private filesystem paths in a public issue.

When reporting a security concern, provide:
- the affected version;
- the Windows version;
- reproduction steps using non-sensitive test data;
- the expected and actual behavior.

## Security model

The utility:
- installs per-user;
- stores configuration in `%LOCALAPPDATA%`;
- uses `HKEY_CURRENT_USER`;
- does not require network access;
- does not transmit client names or paths;
- does not delete client data during uninstall.

The scripts are plain text and are intended to be auditable.
