# CAV Artifact TODO

This is the remaining CAV 2026 artifact runbook. It assumes the resolved
packaging policy: `SHA256SUMS` is **not** inside the artifact zip; it is
uploaded beside the zip on Zenodo.

Do the steps in order. If any source-facing file changes after Step 0
(`docs/AE_README.md`, `Dockerfile`, scripts, source, samples, tests, or
results/paper), go back to Step 0 and rerun the affected build, validation, and
packaging steps.

## 0. Finish Metadata And Source Inputs

- [ ] Review and keep the current artifact-preparation changes.
  - `docs/AE_README.md`
  - `docs/CAV_ARTIFACT_TODO.md`
  - `scripts/package-ae.sh`

- [ ] Make sure `scripts/package-ae.sh` is tracked before the final clean
  checkout/build. The script stages the source snapshot and should be part of
  the submitted source.

- [ ] Treat `quak-nqa-linux-amd64.tar.gz` as an old non-final local archive.
  Do not upload it and do not include it in the final package.

- [ ] Create a Zenodo draft and reserve the **version DOI** before the final
  Docker build. The Docker image copies `docs/AE_README.md`, so the DOI and
  artifact version must be in the README before building the image.

- [ ] Fill final metadata in `docs/AE_README.md`.
  - Artifact version, for example `v1.0-cav26-ae`.
  - Zenodo version DOI, not the concept DOI.
  - Checksum policy/location: `SHA256SUMS` uploaded beside the artifact zip.

- [ ] Confirm the AE README has no unresolved placeholders.
  ```bash
  ! grep -nE 'pending|TODO|TBD' docs/AE_README.md
  ```

- [ ] Record the exact source state used for the final build.
  ```bash
  git status --short --branch
  git rev-parse HEAD
  ```
  The final build should be from a clean, intentional state. Untracked scratch
  archives are acceptable only if they are explicitly excluded from packaging.

## 1. Final Native Build And Tests

- [ ] Use a fresh out-of-tree build directory for final native verification.
  This avoids relying on the existing `build/` directory.
  ```bash
  cmake -S . -B build-ae-final -DCMAKE_BUILD_TYPE=Release
  cmake --build build-ae-final --target tests experiments -j4
  ctest --test-dir build-ae-final --output-on-failure
  cmake --build build-ae-final --target smoke-test-full -j4
  ```

- [ ] Record the final native results.
  - CTest pass count.
  - CTest runtime.
  - `smoke-test-full` pass count and runtime.

## 2. Final Docker Build

- [ ] Rebuild the Docker image from the finalized source state.
  ```bash
  docker build -t quak-nqa . 2>&1 | tee docker-build-final.log
  ```

- [ ] Confirm the Docker build log includes the builder-stage CTest run.
  ```bash
  grep -F 'ctest --test-dir build --output-on-failure' docker-build-final.log
  ```
  A successful Docker build should mean the builder stage compiled the tool,
  built tests and experiments, and passed CTest.

- [ ] Keep `docker-build-final.log` as a local validation note only. Do not
  package it unless the artifact policy is intentionally changed.

## 3. Docker Runtime Verification

- [ ] Verify the runtime image immediately after the final Docker rebuild.
  ```bash
  docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
  docker run --rm quak-nqa python3 /quak/experiment.py --help
  docker run --rm quak-nqa python3 /quak/experiment_small.py --help
  ```

- [ ] Record the Docker smoke-test result.
  Expected ending:
  ```text
  SMOKE PASSED (quick) -- 16/16 checks, <time>s wall
  ```

## 4. Experiment Validation

- [ ] Run the small representative experiment subset at least once.
  Use the final native experiment binary.
  ```bash
  python3 experiment_small.py \
    --exe ./build-ae-final/quak-experiment-single \
    --outdir results/small
  ```

- [ ] Check the produced small CSV files.
  - CSV files should be non-empty.
  - No row should have status `INCONSISTENT`.
  - Timeout or memory-limit statuses should be understood before proceeding.

- [ ] Optionally run the full experiment suite for maximum final confidence.
  This is the expensive run.
  ```bash
  python3 experiment.py \
    --exe ./build-ae-final/quak-experiment-single \
    --outdir results/full
  ```

- [ ] If the full run is performed, regenerate tables from the produced full
  CSV directory.
  ```bash
  python3 results/csv_to_latex_figures.py results/full --no-compile
  ```

- [ ] Compare regenerated table structure and benchmark coverage with
  `results/paper/`.
  Exact runtimes may differ by machine. CSV names, columns, status categories,
  and benchmark coverage should match the reference outputs.

- [ ] Do not package `results/small/` or `results/full/` unless the artifact
  policy is intentionally changed. The packaging script includes the reference
  `results/paper/` files and the table-generation script.

## 5. Save And Verify The Docker Archive

- [ ] Save the rebuilt image with the exact filename expected by the README and
  packaging script.
  ```bash
  docker save quak-nqa | gzip > quak-nqa-docker-image.tar.gz
  ```

- [ ] Verify the saved Docker archive loads and runs.
  ```bash
  docker load < quak-nqa-docker-image.tar.gz
  docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
  ```

## 6. macOS / Apple Check

- [ ] On macOS, run a native source build if a machine is available.
  ```bash
  cmake -S . -B build-ae-final -DCMAKE_BUILD_TYPE=Release
  cmake --build build-ae-final --target tests experiments -j4
  ctest --test-dir build-ae-final --output-on-failure
  ```

- [ ] On macOS, load the packaged Docker image and run the quick smoke test.
  ```bash
  docker load < quak-nqa-docker-image.tar.gz
  docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
  ```

- [ ] On Apple Silicon, check both Docker paths if possible.
  - Packaged `linux/amd64` image through Docker Desktop emulation.
  - Local Docker rebuild from `source/` for a native platform image:
    ```bash
    cd source
    docker build -t quak-nqa .
    docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
    ```

- [ ] If the macOS check requires changing `docs/AE_README.md`, go back to
  Step 0 and rerun the affected build, validation, and packaging steps. The
  runtime image must contain the final README wording.

## 7. Build And Inspect The Artifact Zip

- [ ] Create the final artifact zip with the packaging script.
  ```bash
  scripts/package-ae.sh
  ```

- [ ] Save the zip listing for inspection.
  ```bash
  zipinfo -1 quak-cav26-artifact.zip | sort > /tmp/quak-ae-zip-files.txt
  ```

- [ ] Confirm every required file is present.
  ```bash
  required=(
    quak-cav26-artifact/README_AE.md
    quak-cav26-artifact/LICENSE
    quak-cav26-artifact/quak-nqa-docker-image.tar.gz
    quak-cav26-artifact/source/CMakeLists.txt
    quak-cav26-artifact/source/Dockerfile
    quak-cav26-artifact/source/README.md
    quak-cav26-artifact/source/experiment.py
    quak-cav26-artifact/source/experiment_small.py
    quak-cav26-artifact/source/scripts/package-ae.sh
    quak-cav26-artifact/source/scripts/smoke-test.sh
    quak-cav26-artifact/source/docs/AE_README.md
    quak-cav26-artifact/source/docs/CLI.md
    quak-cav26-artifact/source/results/csv_to_latex_figures.py
    quak-cav26-artifact/source/results/paper/benchmark_tables.tex
    quak-cav26-artifact/source/results/paper/benchmark_tables.pdf
  )
  for path in "${required[@]}"; do
    grep -qxF "$path" /tmp/quak-ae-zip-files.txt || {
      echo "missing from artifact zip: $path"
      exit 1
    }
  done
  ```

- [ ] Confirm required source directories are represented.
  ```bash
  for prefix in source/src/ source/samples/ source/examples/ source/results/paper/; do
    grep -q "^quak-cav26-artifact/$prefix" /tmp/quak-ae-zip-files.txt || {
      echo "missing source subtree: $prefix"
      exit 1
    }
  done
  ```

- [ ] Confirm no forbidden local or self-referential files are present.
  ```bash
  forbidden='(^|/)SHA256SUMS$|(^|/)build/|(^|/)\.git/|quak-nqa-linux-amd64\.tar\.gz|source/results/(small|full)/|source/docs/(CAV_ARTIFACT_TODO|MERGE_TODO|MERGE_OVERRIDES)\.md|__pycache__|docker-build-final\.log'
  if grep -E "$forbidden" /tmp/quak-ae-zip-files.txt; then
    echo "forbidden file found in artifact zip"
    exit 1
  fi
  echo "zip inspection passed"
  ```

- [ ] Confirm the submitted top-level README matches the source README.
  ```bash
  tmpdir="$(mktemp -d)"
  unzip -q quak-cav26-artifact.zip \
    quak-cav26-artifact/README_AE.md \
    quak-cav26-artifact/source/docs/AE_README.md \
    -d "$tmpdir"
  cmp -s \
    "$tmpdir/quak-cav26-artifact/README_AE.md" \
    "$tmpdir/quak-cav26-artifact/source/docs/AE_README.md"
  ```

## 8. Compute External Checksums

- [ ] Generate the external checksum file only after the final zip and final
  Docker archive are fixed.
  ```bash
  sha256sum quak-cav26-artifact.zip quak-nqa-docker-image.tar.gz > SHA256SUMS
  ```

- [ ] Verify the checksum file.
  ```bash
  sha256sum -c SHA256SUMS
  ```

- [ ] Keep `SHA256SUMS` beside the zip for Zenodo upload. Do not rebuild the
  zip after this step unless the checksum file is regenerated.

## 9. Upload To Zenodo

- [ ] Upload `quak-cav26-artifact.zip`.
- [ ] Upload `SHA256SUMS` beside the zip.
- [ ] Confirm the Zenodo record uses the version DOI recorded in
  `docs/AE_README.md`.
- [ ] Download the uploaded archive once.
- [ ] Verify the downloaded archive checksum against `SHA256SUMS`.

## Final Stop Conditions

The artifact is ready to submit only when all of these are true:

- [ ] `docs/AE_README.md` has final version, version DOI, and checksum policy.
- [ ] Native final build and CTest passed from `build-ae-final/`.
- [ ] Docker final build passed and its builder stage ran CTest.
- [ ] Docker runtime smoke test passed from the final image.
- [ ] `experiment.py --help` and `experiment_small.py --help` passed in Docker.
- [ ] Small experiment validation was run at least once.
- [ ] macOS / Apple result is known and README wording matches it.
- [ ] Final zip was built by `scripts/package-ae.sh`.
- [ ] Final zip inspection found required files and no forbidden files.
- [ ] External `SHA256SUMS` verifies locally.
- [ ] Zenodo upload was downloaded and checksum-verified.
