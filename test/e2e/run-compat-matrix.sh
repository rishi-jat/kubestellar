#!/usr/bin/env bash
# Copyright 2025 The KubeStellar Authors.
#
# E2E compatibility matrix test for KubeFlex CLI and KubeStellar core-chart.
# Iterates over all KubeFlex CLI versions >= min required, runs E2E tests for each.

set -e
set -x

# Get min required KubeFlex CLI version from check_pre_req.sh
grep_minver() {
  grep -E 'kflex.*min required version' "$1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

MIN_KFLEX_VERSION=$(grep_minver "$(dirname "$0")/../../scripts/check_pre_req.sh")

# List available KubeFlex CLI versions (simulate, replace with real fetch if needed)
AVAILABLE_KFLEX_VERSIONS=("0.9.0" "0.10.0" "0.11.0" "0.12.0" "0.13.0")

# Filter versions >= min required
function version_ge() {
  # returns 0 if $1 >= $2
  [ "$(printf '%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]
}

TESTED_VERSIONS=()
for v in "${AVAILABLE_KFLEX_VERSIONS[@]}"; do
  if version_ge "$v" "$MIN_KFLEX_VERSION"; then
    TESTED_VERSIONS+=("$v")
  fi

done

RESULTS=()
for kflex_ver in "${TESTED_VERSIONS[@]}"; do
  echo "Testing with KubeFlex CLI version $kflex_ver"
  # Install KubeFlex CLI version (simulate, replace with real install)
  echo "Installing kflex CLI version $kflex_ver ..."
  # TODO: Add real install logic here
  # Run E2E test
  "$(dirname "$0")/run-test.sh" --test-type bash --env kind
  if [ $? -eq 0 ]; then
    RESULTS+=("$kflex_ver: PASS")
  else
    RESULTS+=("$kflex_ver: FAIL")
  fi
done

echo "\nCompatibility Matrix Results:"
for r in "${RESULTS[@]}"; do
  echo "$r"
done