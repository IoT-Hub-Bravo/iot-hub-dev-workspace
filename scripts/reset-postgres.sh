#!/usr/bin/env bash
set -euo pipefail

SCRIPT_CONTEXT="reset-postgres"
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${WORKSPACE_ROOT}/scripts/lib.sh"

PROJECT_NAME="$(echo "${COMPOSE_SHARED_NAME:-iot-hub-shared}" | tr '[:upper:]' '[:lower:]')"
DB_VOLUME="${PROJECT_NAME}_db_data"

DOWN_SCRIPT="${WORKSPACE_ROOT}/scripts/down.sh"
GENERATE_POSTGRES_SCRIPT="${WORKSPACE_ROOT}/scripts/generate-postgres-init.sh"


generate_postgres_init() {
  require_file "$GENERATE_POSTGRES_SCRIPT"

  log "Generating PostgreSQL init SQL..."
  "$GENERATE_POSTGRES_SCRIPT"
}

volume_exists() {
  docker volume inspect "$DB_VOLUME" >/dev/null 2>&1
}

confirm_reset() {
  log "Shared compose project: ${PROJECT_NAME}"
  log "Postgres volume: ${DB_VOLUME}"
  log "About to delete PostgreSQL volume. Type 'YES' to confirm:"
  read -r confirm

  if [ "$confirm" != "YES" ]; then
    log "Cancelled"
    exit 1
  fi
}

stop_stack() {
  require_file "$DOWN_SCRIPT"

  log "Stopping containers..."
  "$DOWN_SCRIPT"
}

remove_volume() {
  log "Removing volume '${DB_VOLUME}'..."
  docker volume rm "$DB_VOLUME"
}

main() {
  require_command docker

  if ! volume_exists; then
    fail "Postgres volume not found: ${DB_VOLUME}"
  fi

  confirm_reset
  stop_stack
  remove_volume
  generate_postgres_init

  log "Postgres reset completed successfully. Run 'up.sh' to start the stack again"
}

main "$@"
