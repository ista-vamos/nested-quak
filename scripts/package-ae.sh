#!/usr/bin/env bash
# Build the CAV AE submission zip from the current source tree.
#
# SHA256SUMS is intentionally not placed inside the zip. Generate it beside the
# final zip and upload both files to Zenodo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ARTIFACT_NAME="quak-cav26-artifact"
DOCKER_IMAGE_TAR="$REPO_ROOT/quak-nqa-docker-image.tar.gz"
OUTPUT_ZIP="$REPO_ROOT/quak-cav26-artifact.zip"
STAGE_PARENT=""
KEEP_STAGE=0
CREATED_STAGE_PARENT=0

usage() {
  cat <<'EOF'
Usage: scripts/package-ae.sh [options]

Options:
  --docker-image-tar PATH  Docker image archive to include.
                           Default: ./quak-nqa-docker-image.tar.gz
  --output PATH            Output zip path.
                           Default: ./quak-cav26-artifact.zip
  --artifact-name NAME     Root directory name inside the zip.
                           Default: quak-cav26-artifact
  --stage-parent DIR       Parent directory for the temporary staging tree.
                           Default: a new directory under /tmp
  --keep-stage             Leave the staging tree on disk after packaging.
  -h, --help               Show this help.

The script copies docs/AE_README.md to README_AE.md at the artifact root,
copies the Docker image archive as quak-nqa-docker-image.tar.gz, and stages a
source/ snapshot with source code, docs, samples, scripts, and reference paper
results. SHA256SUMS is not included in the zip; create it beside the final zip.
EOF
}

die() {
  echo "package-ae: $*" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

copy_file() {
  local src="$1"
  local dst="$2"
  [[ -f "$REPO_ROOT/$src" ]] || die "missing required file: $src"
  mkdir -p "$(dirname "$dst")"
  cp -p "$REPO_ROOT/$src" "$dst"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --docker-image-tar)
      [[ $# -ge 2 ]] || die "--docker-image-tar requires a path"
      DOCKER_IMAGE_TAR="$2"
      shift 2
      ;;
    --output)
      [[ $# -ge 2 ]] || die "--output requires a path"
      OUTPUT_ZIP="$2"
      shift 2
      ;;
    --artifact-name)
      [[ $# -ge 2 ]] || die "--artifact-name requires a name"
      ARTIFACT_NAME="$2"
      shift 2
      ;;
    --stage-parent)
      [[ $# -ge 2 ]] || die "--stage-parent requires a directory"
      STAGE_PARENT="$2"
      shift 2
      ;;
    --keep-stage)
      KEEP_STAGE=1
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

need_command git
need_command zip

[[ -f "$DOCKER_IMAGE_TAR" ]] || die "missing Docker image archive: $DOCKER_IMAGE_TAR"
[[ -f "$REPO_ROOT/docs/AE_README.md" ]] || die "missing docs/AE_README.md"

DOCKER_IMAGE_TAR="$(cd "$(dirname "$DOCKER_IMAGE_TAR")" && pwd)/$(basename "$DOCKER_IMAGE_TAR")"
mkdir -p "$(dirname "$OUTPUT_ZIP")"
OUTPUT_ZIP="$(cd "$(dirname "$OUTPUT_ZIP")" && pwd)/$(basename "$OUTPUT_ZIP")"

if [[ -z "$STAGE_PARENT" ]]; then
  STAGE_PARENT="$(mktemp -d /tmp/quak-ae-package.XXXXXX)"
  CREATED_STAGE_PARENT=1
else
  mkdir -p "$STAGE_PARENT"
  STAGE_PARENT="$(cd "$STAGE_PARENT" && pwd)"
fi

STAGE_ROOT="$STAGE_PARENT/$ARTIFACT_NAME"
SOURCE_ROOT="$STAGE_ROOT/source"
rm -rf "$STAGE_ROOT"
mkdir -p "$SOURCE_ROOT"

copy_file "docs/AE_README.md" "$STAGE_ROOT/README_AE.md"
copy_file "LICENSE" "$STAGE_ROOT/LICENSE"
cp -p "$DOCKER_IMAGE_TAR" "$STAGE_ROOT/quak-nqa-docker-image.tar.gz"

git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "source snapshot packaging requires a git working tree"

while IFS= read -r -d '' path; do
  mkdir -p "$(dirname "$SOURCE_ROOT/$path")"
  cp -p "$REPO_ROOT/$path" "$SOURCE_ROOT/$path"
done < <(
  git -C "$REPO_ROOT" ls-files -z -- \
    CMakeLists.txt \
    Dockerfile \
    README.md \
    LICENSE \
    experiment.py \
    experiment_small.py \
    examples \
    samples \
    scripts \
    src \
    docs/AE_README.md \
    docs/CLI.md \
    results/csv_to_latex_figures.py \
    results/paper
)

# Include this script in mechanics checks before it has been committed.
copy_file "scripts/package-ae.sh" "$SOURCE_ROOT/scripts/package-ae.sh"

[[ -f "$SOURCE_ROOT/results/csv_to_latex_figures.py" ]] \
  || die "source snapshot is missing results/csv_to_latex_figures.py"
[[ -d "$SOURCE_ROOT/results/paper" ]] \
  || die "source snapshot is missing results/paper"

rm -f "$OUTPUT_ZIP"
(
  cd "$STAGE_PARENT"
  zip -rq "$OUTPUT_ZIP" "$ARTIFACT_NAME"
)

echo "Created $OUTPUT_ZIP"
echo "Staged artifact root: $STAGE_ROOT"
echo
echo "Next checksum step, after Docker image and zip are final:"
echo "  sha256sum $(basename "$OUTPUT_ZIP") quak-nqa-docker-image.tar.gz > SHA256SUMS"
echo "Upload SHA256SUMS beside the zip on Zenodo; it is not included inside the zip."

if [[ "$KEEP_STAGE" -eq 0 ]]; then
  if [[ "$CREATED_STAGE_PARENT" -eq 1 ]]; then
    rm -rf "$STAGE_PARENT"
  else
    rm -rf "$STAGE_ROOT"
  fi
else
  echo "Kept staging directory: $STAGE_PARENT"
fi
