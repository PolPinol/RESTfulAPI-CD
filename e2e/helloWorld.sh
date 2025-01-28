#!/usr/bin/env bash
#
# Usage: ./e2e/helloWorld.sh <IMAGE>
# Example: ./e2e/helloWorld.sh "docker.io/polpinol98/restfulapiapp:1.0.25"
#
# Make sure this script is executable: chmod +x ./e2e/helloWorld.sh
#

set -euo pipefail

IMAGE="${1:-}"

if [ -z "$IMAGE" ]; then
  echo "ERROR: No image provided."
  echo "Usage: $0 <image:tag>"
  exit 1
fi

echo "Starting E2E tests for image: $IMAGE"

# Run the container in detached mode, mapping host port 8081 -> container 8080
CONTAINER_ID=$(docker run -d --rm -p 8081:8080 "$IMAGE")

# Give the container a few seconds to become ready
echo "Waiting for the container to be ready..."
sleep 5

# Check the HTTP status code for /hello
echo "Checking /hello endpoint..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8081/hello")

if [[ "$HTTP_STATUS" -ne 200 ]]; then
  echo "ERROR: /hello returned HTTP status $HTTP_STATUS instead of 200."
  echo "---- Container Logs ----"
  docker logs "$CONTAINER_ID" || true
  echo "------------------------"
  docker stop "$CONTAINER_ID" >/dev/null
  exit 1
fi

echo "E2E test passed! /hello endpoint returned 200."

# Clean up container
docker stop "$CONTAINER_ID" >/dev/null
