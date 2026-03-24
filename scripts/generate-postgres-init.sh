#!/usr/bin/env bash
set -euo pipefail

SCRIPT_CONTEXT="generate-postgres-init"
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${WORKSPACE_ROOT}/scripts/lib.sh"

SERVICES_FILE="${WORKSPACE_ROOT}/manifests/postgres_services.sh"
SRC_ROOT="${WORKSPACE_ROOT}/src"
SERVICE_ENV_FILE=".env"

OUTPUT_DIR="${WORKSPACE_ROOT}/docker/postgres/generated"
OUTPUT_FILE="${OUTPUT_DIR}/01-init-databases.sql"

load_services() {
  require_file "$SERVICES_FILE"
  source "$SERVICES_FILE"
}

write_sql_header() {
  mkdir -p "$OUTPUT_DIR"

  cat > "$OUTPUT_FILE" <<'SQL'
-- generated file; do not edit manually
SQL
}

process_service() {
  local service_name="$1"
  local env_file="${SRC_ROOT}/${service_name}/${SERVICE_ENV_FILE}"

  require_file "$env_file"

  unset DB_NAME DB_USER DB_PASSWORD

  source "$env_file"

  [ -n "${DB_NAME:-}" ] || fail "DB_NAME missing in ${env_file}"
  [ -n "${DB_USER:-}" ] || fail "DB_USER missing in ${env_file}"
  [ -n "${DB_PASSWORD:-}" ] || fail "DB_PASSWORD missing in ${env_file}"

  cat >> "$OUTPUT_FILE" <<SQL

CREATE USER ${DB_USER} WITH ENCRYPTED PASSWORD '${DB_PASSWORD}';
CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
SQL
}

main() {
  load_services
  write_sql_header

  for service_name in "${POSTGRES_SERVICES[@]}"; do
    process_service "$service_name"
  done

  log "Generated ${OUTPUT_FILE}"
}

main "$@"
