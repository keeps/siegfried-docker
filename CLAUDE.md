# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A Docker packaging project for [siegfried](https://github.com/richardlehane/siegfried), a third-party file-format identification tool (`sf`). There is no application source code here — the only logic is in the `Dockerfile` and the GitHub Actions workflow that builds and publishes it. Images are published to `ghcr.io/keeps/siegfried`.

## Building and testing

```sh
# Build a specific siegfried version (SIEGFRIED_VERSION must be a real upstream tag, e.g. v1.11.7)
./build.sh 1.11.7
# or directly:
docker build --build-arg SIEGFRIED_VERSION=v1.11.7 -t ghcr.io/keeps/siegfried:v1.11.7 .

# Run as a server
docker run -v $PWD:$PWD -p 5138:5138 -e SIEGFRIED_HOST=0.0.0.0 -d --name siegfried ghcr.io/keeps/siegfried:v1.11.7
curl "http://localhost:5138/identify/$(echo -n $PWD | base64 -w0)?base64=true"
docker stop siegfried

# Run as a one-off command
docker run -v $PWD:$PWD --rm ghcr.io/keeps/siegfried:v1.11.7 sf $PWD
```

There is no test suite; validating a change means building the image and running it as above (or the equivalent, if driving it from `mcp__claude-in-chrome` / the `run` skill isn't applicable here since this isn't a web app).

## Dockerfile architecture

Multi-stage build:
1. **`build` stage** (`golang:1.26.0-alpine`): `go install`s `sf` at `SIEGFRIED_VERSION`, then runs `sf -update` as root to fetch the PRONOM signature file into `/root/.local/share/siegfried/`.
2. **Final stage** (`alpine:3.22`): creates the non-root `SIEGFRIED_USER`/`SIEGFRIED_UID`, and copies only the compiled `sf` binary and the signature file from the build stage — the Go toolchain and module cache never reach the final image.

`CMD` uses `exec` inside a shell (`CMD ["sh", "-c", "exec sf -serve $SIEGFRIED_HOST:$SIEGFRIED_PORT"]`) so `sf` becomes PID 1 and receives `SIGTERM` directly — required for `docker stop` to shut it down promptly instead of waiting out the kill timeout.

Build args (`SIEGFRIED_VERSION`, `SIEGFRIED_USER`, `SIEGFRIED_UID`) and runtime env vars (`SIEGFRIED_HOST`, `SIEGFRIED_PORT`, `USER`, `HOME`) are documented in `README.md` — keep that file in sync if either changes.

## CI/CD (`.github/workflows/build.yml`)

One workflow, two triggers:
- **`schedule`** (daily): checks `richardlehane/siegfried`'s latest GitHub release via `gh api`, and if that version isn't already published to `ghcr.io/keeps/siegfried` (checked via `docker buildx imagetools inspect`, not the packages API — the default `GITHUB_TOKEN` can't list org package versions), builds and pushes it.
- **`workflow_dispatch`**: manual run with an optional `version` input, for rebuilding a specific (possibly older) version — always builds regardless of whether it's already published.

Tagging is version-first: the built version is always tagged `vX.Y.Z`; the `latest` tag is only added when the version being built equals the current upstream-latest release (`docker/metadata-action`'s `enable=` per-tag flag). This is deliberate — never make the `latest` tag move unconditionally, or a manual rebuild of an old version will regress it.

Builds are multi-arch (`linux/amd64,linux/arm64`) via QEMU + Buildx, pushed to `ghcr.io` using `secrets.GITHUB_TOKEN` (not a DockerHub credential, despite older workflow history mentioning DockerHub — this project only publishes to GHCR).
