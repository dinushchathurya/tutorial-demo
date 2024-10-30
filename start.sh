#!/bin/bash
set -euo pipefail

check_env() {
    if [ -z "${GITHUB_PAT:-}" ]; then
        echo "Environment variable GITHUB_PAT is required but not set"
        exit 1
    fi

    if [ -z "${GITHUB_REPO:-}" ]; then
        echo "Environment variable GITHUB_REPO is required but not set"
        exit 1
    fi
}

register_runner() {
    local github_token=$(curl -sL \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_PAT" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/$GITHUB_REPO/actions/runners/registration-token | jq -r .token)

    ./config.sh --unattended --url https://github.com/$GITHUB_REPO --token $github_token
}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended
}

check_env
trap cleanup EXIT

register_runner
./run.sh
