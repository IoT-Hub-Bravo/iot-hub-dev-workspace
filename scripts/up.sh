#!/usr/bin/env bash
set -euo pipefail

SCRIPT_CONTEXT="up"
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${WORKSPACE_ROOT}/scripts/lib.sh"

SERVICES_FILE="${WORKSPACE_ROOT}/manifests/services.sh"
INFRA_COMPOSE="${WORKSPACE_ROOT}/compose/infra.yml"
SHARED_COMPOSE="${WORKSPACE_ROOT}/compose/shared.yml"
WORKSPACE_ENV_FILE="${WORKSPACE_ROOT}/.env"

SRC_ROOT="${WORKSPACE_ROOT}/src"
SERVICE_COMPOSE_FILE="compose/runtime.yml"
SERVICE_ENV_FILE=".env"

GENERATE_POSTGRES_SCRIPT="${WORKSPACE_ROOT}/scripts/generate-postgres-init.sh"


start_compose_stack() {
  local compose_file="$1"
  local stack_name="$2"

  require_file "$compose_file"

  log "Starting ${stack_name} containers..."
  docker compose --env-file "$WORKSPACE_ENV_FILE" -f "$compose_file" up -d --build
}

start_service() {
  local service_name="$1"
  local compose_file="${SRC_ROOT}/${service_name}/${SERVICE_COMPOSE_FILE}"
  local service_env_file="${SRC_ROOT}/${service_name}/${SERVICE_ENV_FILE}"

  require_file "$compose_file"
  require_file "$service_env_file"

  log "Starting service '${service_name}'..."
  docker compose --env-file "$service_env_file" -f "$compose_file" up -d --build
}

start_all_services() {
  log "Starting all services..."

  for service_name in "${SERVICES[@]}"; do
    start_service "$service_name"
  done
}

service_exists() {
  local target_service="$1"
  local service_name

  for entry in "${SERVICES[@]}"; do
    IFS="|" read -r service_name repo_url <<< "$entry"
    if [ "$service_name" = "$target_service" ]; then
      return 0
    fi
  done

  return 1
}

start_selected_services() {
  log "Starting selected services: $*"
  local service_name

  for service_name in "$@"; do
    if ! service_exists "$service_name"; then
      fail "Unknown service: ${service_name}"
    fi
  done

  for service_name in "$@"; do
    start_service "$service_name"
  done
}

ensure_postgres_init_file() {
  if [ -f "${WORKSPACE_ROOT}/docker/postgres/generated/01-init-databases.sql" ]; then
    log "PostgreSQL init SQL already exists, skipping generation"
  else
    log "PostgreSQL init SQL not found, generating..."
    "$GENERATE_POSTGRES_SCRIPT"
  fi
}

load_services() {
  require_file "$SERVICES_FILE"
  source "$SERVICES_FILE"
}

validate_workspace_files() {
  require_file "$WORKSPACE_ENV_FILE"
  require_file "$INFRA_COMPOSE"
  require_file "$SHARED_COMPOSE"
}


main() {
  require_command docker
  load_services
  validate_workspace_files

  ensure_postgres_init_file

  start_compose_stack "$INFRA_COMPOSE" "infrastructure"
  start_compose_stack "$SHARED_COMPOSE" "shared"

  if [ "$#" -eq 0 ]; then
    start_all_services
  else
    start_selected_services "$@"
  fi

  log "Services are up"
}

main "$@"
