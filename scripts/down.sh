#!/usr/bin/env bash
set -euo pipefail

SCRIPT_CONTEXT="down"
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${WORKSPACE_ROOT}/scripts/lib.sh"

SERVICES_FILE="${WORKSPACE_ROOT}/manifests/services.sh"
INFRA_COMPOSE="${WORKSPACE_ROOT}/compose/infra.yml"
SHARED_COMPOSE="${WORKSPACE_ROOT}/compose/shared.yml"
GATEWAY_COMPOSE="${WORKSPACE_ROOT}/compose/gateway.yml"
WORKSPACE_ENV_FILE="${WORKSPACE_ROOT}/.env"

SRC_ROOT="${WORKSPACE_ROOT}/src"
SERVICE_COMPOSE_FILE="compose/runtime.yml"
SERVICE_ENV_FILE=".env"

load_services() {
  require_file "$SERVICES_FILE"
  source "$SERVICES_FILE"
}

compose_has_resources() {
  local compose_file="$1"
  local env_file="$2"

  docker compose \
    --env-file "$env_file" \
    -f "$compose_file" \
    ps -a -q 2>/dev/null | grep -q .
}

stop_stack() {
  local compose_file="$1"
  local env_file="$2"
  local stack_name="$3"

  require_file "$compose_file"
  require_file "$env_file"

  if ! compose_has_resources "$compose_file" "$env_file"; then
    return 0
  fi

  log "Stopping ${stack_name} containers..."
  docker compose \
    --env-file "$env_file" \
    -f "$compose_file" \
    down --remove-orphans >/dev/null
}

stop_services() {
  local service_name
  local compose_file
  local env_file

  for service_name in "${SERVICES[@]}"; do
    compose_file="${SRC_ROOT}/${service_name}/${SERVICE_COMPOSE_FILE}"
    env_file="${SRC_ROOT}/${service_name}/${SERVICE_ENV_FILE}"

    stop_stack "$compose_file" "$env_file" "service '${service_name}'"
  done
}

main() {
  require_command docker
  require_file "$WORKSPACE_ENV_FILE"
  require_file "$INFRA_COMPOSE"
  require_file "$SHARED_COMPOSE"

  load_services

  stop_services
  stop_stack "$GATEWAY_COMPOSE" "$WORKSPACE_ENV_FILE" "gateway"
  stop_stack "$SHARED_COMPOSE" "$WORKSPACE_ENV_FILE" "shared"
  stop_stack "$INFRA_COMPOSE" "$WORKSPACE_ENV_FILE" "infrastructure"

  log "Containers are stopped"
}

main "$@"