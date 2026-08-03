# Deploy and Host MantisBT on Railway

## About Hosting MantisBT

MantisBT is an open-source issue tracker with projects, roles, workflows, custom fields, email notifications, and reporting. This template deploys stable 2.28.4 with generated credentials and private MariaDB.

Sign in as `administrator` with `MANTIS_ADMIN_PASSWORD`.

## Common Use Cases

- Software bug and issue tracking
- Internal support queues
- Project status and release triage

## Dependencies for MantisBT Hosting

### Deployment Dependencies

MantisBT and private MariaDB services each use a daily-backed-up volume. Railway provides HTTPS.

### Implementation Details

The adapter runs the supported installer against the private database, rotates the built-in administrator password through MantisBT core APIs, removes the installer directory, and proxies only after setup. Use one application replica.

## Why Deploy MantisBT on Railway?

Railway provides generated credentials, private networking, HTTPS, persistent storage, backups, health checks, and Git-driven updates.
