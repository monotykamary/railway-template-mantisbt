# MantisBT on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/mantisbt?referralCode=ZqgrJ0)

Deploy MantisBT 2.28.4 with generated administrator and database passwords, private MariaDB, persistent configuration, and daily backups. The adapter installs the schema before exposing Caddy and removes the installer directory.

This maintenance release pins Caddy 2.11.9. MantisBT 2.28.4 and MariaDB 13.0.2 remain unchanged; this is not a database-major upgrade.

Sign in as `administrator` with `MANTIS_ADMIN_PASSWORD`. Use one application replica because configuration uses an attached volume.

Upstream: https://github.com/mantisbt/mantisbt/tree/release-2.28.4 (GPL-2.0-or-later). Container source: https://github.com/xlrl/docker-mantisbt/tree/2.28.4 (MIT). Not affiliated with Railway.
