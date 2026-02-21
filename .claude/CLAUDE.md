# Backup Helper

Docker-based tool for PostgreSQL backups and Google Cloud Storage sync. Used in AskAnna's Docker Stack.

## Project structure

- `backup_scripts/` - Shell scripts (backup, restore, GCS operations)
- `docker/` - Dockerfile, entrypoint.sh, requirements.txt
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

- Base image: `python:3.13-slim`
- Multi-arch: linux/amd64 + linux/arm64
- Build context is project root: `docker buildx build --file docker/Dockerfile .`
- Python deps in `docker/requirements.txt` (tracked by Renovate)
- Supercronic version tracked by Renovate via datasource comment in Dockerfile

## CI/CD (GitLab)

- Scheduled pipeline (weekly, Sunday): builds with `--no-cache` + runs Renovate
- Tag pushes (semver): build image, verify, create GitLab release, publish to GitHub

## Shell scripts

- Scripts in `backup_scripts/` have no `.sh` extension
- Shared functions in `backup_scripts/_sourced/`
- Scripts run as `backup` user inside the container
