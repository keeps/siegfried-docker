# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Unified `build.yml` CI workflow that checks daily for new upstream siegfried
  releases and builds/publishes automatically, with `workflow_dispatch` kept
  for manual/backfill builds of a specific version.

### Changed

- Rebuilt the Dockerfile as a multi-stage build: the final image now ships
  only the compiled `sf` binary and its signature file instead of the full Go
  toolchain, shrinking it from ~529 MB to ~20 MB.
- `latest` is now only tagged when the version being built matches the
  current upstream-latest siegfried release, so a manual rebuild of an older
  version can no longer regress it.
- Updated `README.md` run examples to use `ghcr.io/keeps/siegfried` instead
  of the unmaintained Docker Hub image reference.

### Fixed

- `latest` tag on `ghcr.io/keeps/siegfried`, which had been stuck on v1.10.2
  since December 2023, retagged to the current release.
- Container now runs `sf` as PID 1 (via `exec` in the `CMD`), so it receives
  `SIGTERM` directly and shuts down promptly on `docker stop` instead of
  waiting out the kill timeout.

### Removed

- `docker.yaml` and `manual.yml` workflows, replaced by `build.yml`.
  `docker.yaml` triggered on a `repository_dispatch` event nothing sent, and
  `manual.yml` never tagged `latest` — together this is why `latest` had
  gone stale.
