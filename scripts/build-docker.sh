#!/usr/bin/env bash
# Build the QuAK-NQA Docker image from a source checkout or artifact source/
# snapshot, then run the reviewer quick smoke test by default.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE_NAME="quak-nqa"
RUN_SMOKE=1

usage() {
  cat <<'EOF'
Usage: scripts/build-docker.sh [options]

Options:
  -t, --tag NAME   Docker image tag to build. Default: quak-nqa
  --no-smoke       Build the image but skip the quick smoke test.
  -h, --help       Show this help.

This script is intended for the CAV artifact source rebuild path. It should be
run from the artifact source/ directory or from the repository root:

  scripts/build-docker.sh

By default it runs:

  docker build -t quak-nqa .
  docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
EOF
}

die() {
  echo "build-docker: $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--tag)
      [[ $# -ge 2 ]] || die "$1 requires an image tag"
      IMAGE_NAME="$2"
      shift 2
      ;;
    --no-smoke)
      RUN_SMOKE=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

command -v docker >/dev/null 2>&1 || die "docker is required"
[[ -f "$SOURCE_ROOT/Dockerfile" ]] || die "missing Dockerfile in $SOURCE_ROOT"

echo "==> Building Docker image '$IMAGE_NAME' from $SOURCE_ROOT"
docker build -t "$IMAGE_NAME" "$SOURCE_ROOT"

if [[ "$RUN_SMOKE" -eq 1 ]]; then
  echo "==> Running quick smoke test in '$IMAGE_NAME'"
  docker run --rm "$IMAGE_NAME" /quak/scripts/smoke-test.sh --quick
fi
