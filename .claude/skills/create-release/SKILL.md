---
name: create-release
description: Use when creating a new release, tagging a version, or preparing release notes for this project
---

# Release

## Overview

Guide the release process: determine version, finalize changelog, create MR, tag, and push to trigger CI pipeline.

CI automatically builds the Docker image, verifies it, creates a GitLab release with the tag annotation, and publishes to GitHub.

## Process

### 1. Review changes since last release

```bash
# Current version
git tag --sort=-v:refname | head -1

# Commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

Review the `## Unreleased` section in `CHANGELOG.md` - it should already contain all changes.

### 2. Determine next version

Follow semver based on changes:
- **patch** (1.0.0 → 1.0.1): bug fixes, dependency updates, config changes
- **minor** (1.1.1 → 1.2.0): new features, new backup targets, new CI jobs
- **major** (1.2.3 → 2.0.0): breaking changes to backup/restore workflow

Ask the user to confirm the version.

### 3. Write release notes

Compose the tag annotation from the `Unreleased` entries. Match existing style:

```
- Fix downloading large files from GCS by installing the required Python tools for crcmod
```

Use `- ` prefix per change. Keep it short and descriptive.

### 4. Finalize CHANGELOG.md

Rename `## Unreleased` to `## <version>` and add a new empty `## Unreleased` section above it.

### 5. Create release MR

Main is protected, so changes go through a merge request:

```bash
git checkout -b release/<version>
git add CHANGELOG.md
git commit -m "Release <version>"
git push -u origin release/<version>
```

Create MR targeting main. After merge, continue to step 6.

### 6. Tag and push

After the MR is merged, tag the merge commit on main:

```bash
git checkout main
git pull
git tag -a <version> -m "<release notes>"
git push origin <version>
```

This triggers the CI pipeline which:
- Builds multi-arch Docker image tagged with the version
- Verifies the image
- Creates a GitLab release with the tag annotation
- Publishes to GitHub

### 7. Verify

- Check CI pipeline status
- Check that GitLab release was created with correct notes and image link
