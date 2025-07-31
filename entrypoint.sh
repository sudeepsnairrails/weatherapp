#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Create tmp directories if they don't exist
mkdir -p /app/tmp/pids
mkdir -p /app/tmp/sockets
mkdir -p /app/log

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@" 