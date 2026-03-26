# Working with nested microservice repositories

## Overview

`iot-hub-dev-workspace` is a separate repository used for local orchestration and development convenience.

It contains:

* shared Docker Compose files
* helper scripts
* manifests
* local development tooling

At the same time, each microservice inside `src/` is also an independent `Git` repository.

This means the workspace is **not a monorepo**.     
It is a development shell around multiple standalone repositories.


## Core rule

Changes must be committed in the repository where they were made.

### Changing files on the workspace root level

For example:

* `compose/infra.yml`
* `compose/shared.yml`
* `scripts/up.sh`
* `scripts/down.sh`
* `scripts/init.sh`
* `manifests/services.sh`
* `README.md`
* workspace-level docs

then these changes belong to the `iot-hub-dev-workspace` repository.    
You should commit them from the workspace root.

### Changing files inside a microservice

For example:

* `src/auth-service/...`
* `src/device-registry-service/...`
* `src/telemetry-processing-service/...`

then these changes belong to that specific microservice repository.

You must change directory into that service and commit there.


## Example

### Workspace-level change

If you modify:
```shell
compose/shared.yml
scripts/reset-postgres.sh
```

then commit from:
```shell
cd iot-hub-dev-workspace
git status
git add compose/shared.yml scripts/reset-postgres.sh
git commit -m "Improve shared stack and PostgreSQL reset flow"
git push
```

### Microservice-level change
If you modify:

```shell
src/auth-service/app/settings.py
src/auth-service/docker/compose/runtime.yml
```

then commit from:
```shell
cd iot-hub-dev-workspace/src/auth-service
git status
git add app/settings.py docker/compose/runtime.yml
git commit -m "Adjust local runtime configuration"
git push
```

### Important consequence

A commit made in `iot-hub-dev-workspace` does not include source code changes from microservice repositories.  
And a commit made inside `src/auth-service` does not include workspace-level changes.  
These repositories are independent.


## Summary

* Workspace-level files are committed in `iot-hub-dev-workspace`
* Microservice-level files are committed inside the corresponding repository under `src/`
* The workspace is not a monorepo
* Changes across multiple repositories must be committed separately
