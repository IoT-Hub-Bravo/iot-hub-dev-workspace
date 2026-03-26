# IoT Hub Dev Workspace — Getting Started

## Overview

`iot-hub-dev-workspace` is the local development workspace for the IoT Hub microservices system.

This repository does not contain the business code of all microservices directly.
Instead, it provides:

* shared Docker Compose files for local orchestration
* helper scripts for bootstrapping and running the environment
* a workspace structure that includes all microservice repositories under src/

Each microservice remains an independent Git repository with its own history, branches, and remote origin.


## Repository structure

Typical workspace structure:
```
iot-hub-dev-workspace/
  compose/
    infra.yml
    shared.yml
  manifests/
    services.sh
    service_repos.sh
    postgres_services.sh
  scripts/
    init.sh
    up.sh
    down.sh
    reset-postgres.sh
    generate-postgres-init.sh
  docker/
    postgres/
      generated/
  src/
    <microservice repositories are cloned here>
```


## Clone the workspace repository

Clone the workspace repository first:
```shell
git clone <workspace-repository-url>
cd iot-hub-dev-workspace
```


## Make scripts executable

Before first use, make the scripts executable:
```shell
chmod +x scripts/*.sh
```


## Run the initialization script

Initialize the workspace by running:
```shell
./scripts/init.sh
```

### What `init.sh` does

The script prepares the local development environment.

It performs the following actions:

1. Clones all configured microservice repositories into `src/`
2. Skips repositories that are already cloned
3. Creates `.env` files from `.env.example` for services where applicable
4. Creates the shared external Docker network used by the stack

### Expected result

After `init.sh` completes:

* all microservice repositories should exist under `src/`
* the shared Docker network should exist
* services should have a local `.env` file created from `.env.example`


## Configure environment files

After initialization, review and update environment files before starting the stack.

### Workspace-level environment

The workspace uses a root `.env` file for shared Docker Compose configuration.

Typical values here include:

* shared network name
* shared PostgreSQL bootstrap credentials
* shared Redis / Flower configuration
* other workspace-wide Compose variables

Make sure the root `.env` file is present and correctly configured.

### Microservice-level environment files

Each microservice repository under `src/<service>` should contain its own `.env`.

These files are usually created automatically from `.env.example` during `init.sh`, but they still need to be reviewed.

At minimum, check:

* database connection settings
* Redis / broker settings
* Kafka bootstrap server settings
* service ports
* any required secrets or local development values

### Important

`.env.example` is **not** production-ready or even fully runnable without changes.
Each service must be reviewed and configured for the local environment.


## Start the local environment

To start the full local stack:
```shell
./scripts/up.sh
```

To start only selected microservices:
```shell
./scripts/up.sh auth-service device-registry-service
```

### What `up.sh` does

The script:

1. Starts infrastructure containers
2. Starts shared containers
3. Starts all microservices by default, or only selected services if explicitly provided


## Stop the local environment

To stop the currently running stack:
```shell
./scripts/down.sh
```

This script stops:

* all running microservice runtime stacks
* shared containers
* infrastructure containers


## Reset PostgreSQL data

If PostgreSQL needs to be reinitialized from scratch, run:
```shell
./scripts/reset-postgres.sh
```

This script:

1. Stops the running local stack
2. Deletes the PostgreSQL data volume
3. Regenerates the PostgreSQL initialization SQL
4. Leaves the environment stopped

After that, start the stack again manually with:
```shell
./scripts/up.sh
```

### Warning

This operation deletes all local PostgreSQL data.


## PostgreSQL initialization

The workspace generates PostgreSQL initialization SQL based on the configured microservices that require databases.

This is handled by:
```shell
./scripts/generate-postgres-init.sh
```

In normal usage, developers usually do not need to run this script manually.
It is mainly used by the workspace bootstrap/reset flow.
