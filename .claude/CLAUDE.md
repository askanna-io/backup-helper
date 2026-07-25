# Backup Helper

Docker-based tool for PostgreSQL backups and remote storage sync via rclone. Used in AskAnna's Docker Stack.

## Project structure

- `backup_scripts/` - Shell scripts (backup, restore, remote storage operations)
- `docker/` - Dockerfile, entrypoint.sh
- `cron/` - Crontab for scheduled backups via supercronic
- `.gitlab-ci.yml` - CI/CD pipeline (build, verify, publish, release, renovate)
- `renovate.json` - Automated dependency update tracking

## Git

- Commit messages: imperative mood, capitalize first letter (e.g. "Fix daily cronjob")
- Releases: annotated semver tags (e.g. `git tag -a 1.5.0 -m "- Add feature X"`)
- Branch naming: `fix/`, `improve/`, `feature/` prefixes
- Main is protected: all changes via merge requests
- Every MR must add entries under `## Unreleased` in `CHANGELOG.md`

## Docker

- Base image: `debian:trixie-slim` (digest pinned)
- Multi-arch: linux/amd64 + linux/arm64
- Build context is project root: `docker buildx build --file docker/Dockerfile .`
- Supercronic version + SHA256 checksums tracked together by a Renovate custom manager (`github-release-attachments` datasource) in renovate.json
- rclone version tracked by Renovate via datasource comment in Dockerfile

## CI/CD (GitLab)

- Scheduled pipeline (weekly, Sunday): builds with `--no-cache` + runs Renovate
- Tag pushes (semver): build image, verify, create GitLab release, publish to GitHub

## Shell scripts

- Scripts in `backup_scripts/` have no `.sh` extension
- Shared functions in `backup_scripts/_sourced/`
- Scripts run as the `app` user (UID/GID 1000) inside the container
