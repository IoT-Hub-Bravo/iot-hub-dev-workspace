# IoT Hub Dev Workspace

Development workspace repository for bootstrapping and running the IoT Hub multi-repository environment locally.

## Purpose

The `iot-hub-dev-workspace` repository provides a standardized local development environment for the IoT Hub microservices system.

It is designed to help developers clone service repositories into a consistent workspace structure, run them together locally, and validate cross-service integration during development.

## Responsibilities

- define the standard local workspace layout
- provide local Docker Compose configuration for multi-service development
- provide scripts for bootstrapping the workspace
- document how service repositories should be cloned and organized locally
- support local integration testing across multiple microservices
- simplify local developer onboarding

## Scope

This repository is focused on local development convenience and integration.

It includes:
- local Docker Compose files
- bootstrap scripts for cloning service repositories
- helper scripts for starting and stopping the stack
- local environment templates
- documentation for workspace setup and usage

## Repository structure

This repository is expected to work with a local structure similar to:

- `src/` — local directories for cloned microservice repositories
- `scripts/` — bootstrap and helper scripts
- `docs/` — local development documentation

The `src/` directory is intended to contain nested microservice repositories and should not be tracked as part of this repository.
