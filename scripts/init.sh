#!/usr/bin/env bash
set -u

SCRIPT_CONTEXT="init"
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${WORKSPACE_ROOT}/scripts/lib.sh"

SRC_ROOT="${WORKSPACE_ROOT}/src"
SERVICES_FILE="${WORKSPACE_ROOT}/manifests/service_repos.sh"

SERVICE_ENV_EXAMPLE_FILE=".env.example"
SERVICE_ENV_FILE=".env"

NETWORK_NAME="iot-hub-nw"

clone_repo() {
  local name="$1"
  local repo_url="$2"

  target_dir="${SRC_ROOT}/${name}"

  if [ -d "${target_dir}/.git" ]; then
    return
  fi

  if [ -d "${target_dir}" ] && [ ! -d "${target_dir}/.git" ]; then
    log "Directory exists but is not a git repository, skipping: ${target_dir}"
    return
  fi

  log "Cloning ${name}..."
  git clone "$repo_url" "$target_dir" || fail "Failed to clone ${name}"
}

ensure_service_env_file() {
  local service_name="$1"
  local env_example_path="${SRC_ROOT}/${service_name}/${SERVICE_ENV_EXAMPLE_FILE}"
  local env_path="${SRC_ROOT}/${service_name}/${SERVICE_ENV_FILE}"

  if [ -f "$env_path" ]; then
    return
  fi

  if [ -f "$env_example_path" ]; then
    cp "$env_example_path" "$env_path"
    log "Created ${SERVICE_ENV_FILE} from ${SERVICE_ENV_EXAMPLE_FILE} for ${service_name}"
    return
  fi

  log "No ${SERVICE_ENV_EXAMPLE_FILE} found for ${service_name}, skipping env creation"
}

clone_services_repos() {
  mkdir -p "$SRC_ROOT"

  for entry in "${SERVICE_REPOS[@]}"; do
    IFS="|" read -r service service_repo_url <<< "$entry"
    clone_repo "$service" "$service_repo_url"
    ensure_service_env_file "$service"
  done
}

create_network() {
  if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    log "Creating Docker network: ${NETWORK_NAME}"
    docker network create "$NETWORK_NAME" >/dev/null || fail "Failed to create network ${NETWORK_NAME}"
  fi
}

load_services() {
  require_file "$SERVICES_FILE"
  source "$SERVICES_FILE"
}

main() {
  require_command git
  require_command docker

  load_services
  clone_services_repos
  create_network

  log "Environment is ready"
}

main "$@"
