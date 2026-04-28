# CAV 2026 Artifact Submission TODO

This is the artifact runbook for **Extending QuAK with Nested Quantitative
Automata**. It replaces the earlier checklist completely.

External source checked: the official CAV 2026 Artifact Evaluation page,
https://conferences.i-cav.org/2026/artifacts/.

Current date: 2026-04-28. CAV lists artifact submission as 2026-04-27 AoE,
smoke testing as 2026-04-28 through 2026-05-03, artifact revision as
2026-05-04 through 2026-05-08, and full review as 2026-05-09 through
2026-05-24. If the artifact was not already submitted by 2026-04-27, contact
the AE chairs or submission site immediately. Otherwise, use this runbook for
smoke-phase fixes, revision-period hardening, and final public Zenodo cleanup.

## Non-Negotiable Target

Submit one CAV artifact zip with two reviewer setup paths:

1. **Path A: prebuilt Docker image.** Fastest path for reviewers. Intended
   artifact type is Docker image, architecture `x86_64` / `linux/amd64`.
   This path must not require network access after the zip is downloaded.
2. **Path B: source rebuild.** The zip also contains a source snapshot that can
   rebuild the Docker image and build natively. This is the practical path for
   macOS and Apple Silicon reviewers. Docker rebuild may require network access
   for Ubuntu packages unless Docker layers are cached; native source build
   requires the listed local tools.

After either setup path, reviewers should interact with the same Docker image
name:

```bash
quak-nqa
```

The main reviewer commands should stay identical:

```bash
docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
docker run --rm -it quak-nqa
docker run --rm -v "$PWD/results-docker:/quak/results" quak-nqa \
  python3 /quak/experiment_small.py --outdir /quak/results/small
```

## Current Repository Observations

These observations were made from the current working tree on 2026-04-28. They
are useful triage data, not final submission evidence.

- Existing out-of-tree `build/` compiled `tests` and `experiments`.
- `ctest --test-dir build --output-on-failure` passed 16/16 tests in 2.66s.
- `cmake --build build --target smoke-test-full -j4` passed 17/17 checks in 3s.
- Smoke test found 160 generated benchmark inputs:
  36 + 36 + 36 response-time files, 36 + 16 resource-consumption files.
- `python3 results/csv_to_latex_figures.py results/paper --no-compile` ran and
  regenerated `results/paper/benchmark_tables.tex` without changing Git status.
- `scripts/build-docker.sh --help`, `scripts/package-ae.sh --help`,
  `python3 experiment.py --help`, and `python3 experiment_small.py --help` run.
- Current modified files include `README.md`, `docs/AE_README.md`,
  `docs/CAV_ARTIFACT_TODO.md`, `experiment.py`, `experiment_small.py`,
  `results/csv_to_latex_figures.py`, and `results/paper/benchmark_tables.pdf`.
  Resolve whether the PDF change is intentional before final packaging.
- No final artifact zip, Docker image tarball, or `SHA256SUMS` file is present
  in the repository root.

Current blockers:

- `docs/AE_README.md` still contains `pending final package` and
  `pending upload`.
- `scripts/package-ae.sh` is designed to fail while `docs/AE_README.md`
  contains `pending`, `TODO`, or `TBD`.
- The final Zenodo version DOI is not recorded in `docs/AE_README.md`.
- The final Docker image has not been rebuilt after final metadata is inserted.
- The prebuilt-image path has not been validated from the final packaged zip.
- The source-Docker rebuild path has not been validated from the final packaged
  zip.
- A clean final native build from a fresh final build directory has not been
  recorded.
- The small representative experiment subset has not been run from the final
  source/image.
- The full paper experiment suite has not been rerun from the final source, or
  explicitly documented as already represented by trusted reference outputs.
- macOS / Apple Silicon validation is not recorded.
- `experiment.py` and `experiment_small.py` now support `--append` resume
  behavior by skipping completed `OK`, `OOT`, and `OOM` rows while rerunning
  problematic statuses.
- `results/csv_to_latex_figures.py` now uses the Python standard-library
  `csv` module, so table generation no longer requires `pandas`.
- `.dockerignore` excludes `results/`, and the runtime Docker image currently
  does not copy `results/csv_to_latex_figures.py` or `results/paper/`. That is
  acceptable only if the README clearly says table regeneration is a source
  workflow, not a prebuilt-runtime-image workflow. For the strongest Reusable
  artifact, prefer making table generation work in Docker too.

## CAV Requirements To Satisfy

The CAV submission form needs:

- [ ] CAV'26 paper ID and title.
- [ ] Paper abstract.
- [ ] Paper PDF accepted for CAV'26.
- [ ] Download URL for the artifact zip. For the Available badge, this should
  be the version DOI URL.
- [ ] SHA256 checksum of the **zip artifact package**.
- [ ] Artifact type: Docker image.
- [ ] Architecture: `x86_64` / `linux/amd64` for the prebuilt image. Mention
  that source rebuild has been tested separately for macOS / Apple Silicon if
  that validation is done.
- [ ] External connectivity statement:
  - prebuilt Docker image path: no network after download;
  - native source build: no network once C++/CMake/Make/Python dependencies are
    installed;
  - Docker rebuild from source: may need network for `apt-get` unless base
    image and package layers are cached.
- [ ] Requested badges: **Available + Reusable**. Do not separately request
  Functional if the submission system treats Reusable as subsuming Functional;
  keep the README's Functional justification because Reusable is judged against
  the Functional baseline.

The artifact zip itself must contain at least:

- [ ] A Docker image or equivalent package contents.
- [ ] A reviewer-facing README.
- [ ] A LICENSE file permitting CAV evaluation.

Available badge requirements:

- [ ] Use a public archival repository with a DOI, preferably Zenodo.
- [ ] Use the **version DOI**, not the concept DOI.
- [ ] The license must allow running and examining the artifact inside and
  outside CAV Artifact Evaluation.

Reusable badge expectations:

- [ ] All dependencies and used libraries are documented and current enough.
- [ ] README explains how to use QuAK beyond reproducing the paper.
- [ ] Extension interfaces are documented, or the artifact is clearly open
  source and extensible.
- [ ] The artifact works in more than one environment, for example Docker plus
  native source build, and preferably Linux plus macOS.
- [ ] Instructions are simple enough for a command-line user who is not a
  Docker or nested-automata expert.
- [ ] Outputs are mapped back to the paper tables and claims.
- [ ] Non-trivial steps have runtime estimates and progress indicators.
- [ ] A representative review subset runs in about 8 hours or less.
- [ ] External services and network dependencies are avoided or clearly
  explained.

## Phase 1: Fix Documentation And Metadata Before Any Final Build

Do this before rebuilding Docker. The Docker image copies
`docs/AE_README.md`, so stale DOI/version text inside that file creates a
stale image.

- [ ] Reserve a Zenodo draft and get the final **version DOI**.
  - Record the version DOI, not the concept DOI.
  - Decide the exact artifact version string, for example `v1.0-cav26-ae`.
  - Decide the final file names:
    - `quak-cav26-artifact.zip`
    - `quak-nqa-docker-image.tar.gz`
    - `SHA256SUMS`, uploaded beside the zip, not inside it.

- [ ] Update `docs/AE_README.md`.
  - Replace `pending final package`.
  - Replace `pending upload`.
  - State requested badges as `Available + Reusable`.
  - State that Reusable subsumes the Functional criteria.
  - Make "Choose one setup path" explicit: Path A prebuilt Docker image, Path B
    source Docker rebuild.
  - Keep one image name after setup: `quak-nqa`.
  - State exact architecture for the prebuilt image: `linux/amd64`.
  - State exact external connectivity requirements for each path.
  - State where `SHA256SUMS` lives and which checksum CAV asks for.
  - Make sure the included paper PDF is described accurately. If
    `docs/cav-paper110-updatedTables.pdf` is not the exact PDF being uploaded
    in the CAV form, call it an artifact companion copy with refreshed tables.
  - Add or verify a troubleshooting section for Docker memory, Apple Silicon
    emulation, and native build dependencies.

- [ ] Verify the Python/table dependency story.
  - `results/csv_to_latex_figures.py` should keep using only the Python
    standard library for CSV parsing.
  - Strongest reusable path: make table generation work inside Docker too by
    copying `results/csv_to_latex_figures.py` and `results/paper/` into the
    runtime image. This is optional if the README clearly says table
    regeneration is a source workflow.

- [ ] Verify experiment documentation.
  - In `README.md`, confirm the `--append` resume behavior is described as
    skipping completed `OK`, `OOT`, and `OOM` rows while rerunning `ERR`,
    `KILLED`, and `INCONSISTENT`.
  - Ensure `README.md`, `docs/AE_README.md`, and `experiment.py --help` agree
    on `--append`, output locations, defaults, timeout, warmup, and memory
    limits.

- [ ] Confirm placeholder scan passes for reviewer-facing metadata.

```bash
! grep -nE 'pending|TODO|TBD' docs/AE_README.md
```

- [ ] Confirm the source tree is in the intended state before final validation.

```bash
git status --short --branch
git diff --check
git ls-files --others --exclude-standard
```

Interpretation:

- `git diff --check` must be clean.
- Untracked files must be scratch-only or explicitly excluded.
- Any file required by the artifact must be tracked or intentionally copied by
  `scripts/package-ae.sh`.

## Phase 2: Final Native Build, Tests, Examples, And Table Script

Use a fresh out-of-tree build directory. Do not rely on the existing `build/`
directory for final evidence.

- [ ] Choose a fresh final build directory. The command below fails if the
  directory already exists, so it cannot delete anything by accident.

```bash
test ! -e build-ae-final || {
  echo "build-ae-final already exists; choose a fresh build directory"
  exit 1
}
```

- [ ] Configure and build final native artifacts.

```bash
cmake -S . -B build-ae-final \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_IPO=ON \
  -DENABLE_SCC_SEARCH_OPT=ON

cmake --build build-ae-final --target tests experiments examples -j4
```

- [ ] Run the registered tests.

```bash
ctest --test-dir build-ae-final --output-on-failure
```

Expected current baseline:

```text
100% tests passed, 0 tests failed out of 16
```

- [ ] Run the full native smoke target.

```bash
cmake --build build-ae-final --target smoke-test-full -j4
```

Expected current baseline:

```text
SMOKE PASSED (full) -- 17/17 checks, <time>s wall
```

- [ ] Run example programs from the repository root.

```bash
./build-ae-final/example1_basic
./build-ae-final/example2_value_functions
./build-ae-final/example3_response_time
```

Expected result: all exit 0 and print sensible QuAK outputs.

- [ ] Validate table generation over the checked-in reference CSVs.

```bash
python3 results/csv_to_latex_figures.py results/paper --no-compile
git diff --exit-code results/paper/benchmark_tables.tex
```

Expected result: no diff after regeneration.

- [ ] If LaTeX is available, validate PDF generation too.

```bash
python3 results/csv_to_latex_figures.py results/paper
```

Expected result: `results/paper/benchmark_tables.pdf` is produced. If the PDF
changes because of nondeterministic PDF metadata, inspect visually rather than
committing churn.

- [ ] Record final native evidence in a local validation log:
  - machine OS and architecture;
  - compiler and CMake versions;
  - CTest pass count and runtime;
  - smoke-test pass count and runtime;
  - example-program result;
  - table-script result.

Useful commands:

```bash
uname -a
cmake --version
g++ --version || clang++ --version
python3 --version
```

## Phase 3: Experiment Validation

CAV reviewers need a quick smoke path and a meaningful paper-claim path. The
small subset is the reviewer-friendly path; the full run is the authors'
confidence path and supports the checked-in paper tables.

- [ ] Run the small representative subset from the final native build.

```bash
SMALL_OUT=results/small-ae-final
test ! -e "$SMALL_OUT" || {
  echo "$SMALL_OUT already exists; choose a fresh output directory"
  exit 1
}
python3 experiment_small.py \
  --exe ./build-ae-final/quak-experiment-single \
  --outdir "$SMALL_OUT"
```

Expected README baseline: about 1 hour 15 minutes on the authors' evaluation
machine. Hardware-dependent variation is fine.

- [ ] Validate small-run CSV shape and statuses.

```bash
python3 - <<'PY'
import csv
import pathlib
import sys

expected = {
    "response_sup_sumplus_emptiness.csv": 6,
    "response_limsupavg_sumplus_emptiness.csv": 6,
    "response_sup_sumb_universality.csv": 6,
    "resource_sup_max_emptiness.csv": 6,
    "resource_limsupavg_max_emptiness.csv": 4,
}

root = pathlib.Path("results/small-ae-final")
bad = False
for name, expected_rows in expected.items():
    path = root / name
    if not path.exists():
        print(f"missing {path}")
        bad = True
        continue
    rows = list(csv.DictReader(path.open(newline="", encoding="utf-8")))
    statuses = {row["status"] for row in rows}
    if len(rows) != expected_rows:
        print(f"{path}: expected {expected_rows} rows, got {len(rows)}")
        bad = True
    if "INCONSISTENT" in statuses:
        print(f"{path}: INCONSISTENT status found")
        bad = True
    unexpected = statuses - {"OK", "OOT", "OOM"}
    if unexpected:
        print(f"{path}: unexpected statuses {sorted(unexpected)}")
        bad = True
    print(f"{path}: {len(rows)} rows, statuses={sorted(statuses)}")
sys.exit(1 if bad else 0)
PY
```

- [ ] Decide whether the final artifact claims reference results from a new
  full run or from previously trusted checked-in results.
  - Best CAV outcome: run the full suite once from the final source state.
  - If time prevents a full rerun, document exactly when and where
    `results/paper/` was generated and why it matches the final source.

- [ ] Preferred: run the full paper experiment suite.

```bash
FULL_OUT=results/full-ae-final
test ! -e "$FULL_OUT" || {
  echo "$FULL_OUT already exists; choose a fresh output directory"
  exit 1
}
python3 experiment.py \
  --exe ./build-ae-final/quak-experiment-single \
  --outdir "$FULL_OUT"
```

Expected README baseline: about 5 hours on the authors' evaluation machine.
The run has progress lines for every instance. Timeout and out-of-memory cells
can be expected for large benchmark cells; `INCONSISTENT` is a hard failure.

- [ ] Validate full-run CSV coverage.

```bash
python3 - <<'PY'
import csv
import pathlib
import sys

expected = {
    "response_sup_sumplus_emptiness.csv": 36,
    "response_limsupavg_sumplus_emptiness.csv": 36,
    "response_sup_sumb_universality.csv": 36,
    "resource_sup_max_emptiness.csv": 36,
    "resource_limsupavg_max_emptiness.csv": 16,
}

root = pathlib.Path("results/full-ae-final")
bad = False
for name, expected_rows in expected.items():
    path = root / name
    if not path.exists():
        print(f"missing {path}")
        bad = True
        continue
    rows = list(csv.DictReader(path.open(newline="", encoding="utf-8")))
    statuses = {row["status"] for row in rows}
    if len(rows) != expected_rows:
        print(f"{path}: expected {expected_rows} rows, got {len(rows)}")
        bad = True
    if "INCONSISTENT" in statuses:
        print(f"{path}: INCONSISTENT status found")
        bad = True
    unexpected = statuses - {"OK", "OOT", "OOM"}
    if unexpected:
        print(f"{path}: unexpected statuses {sorted(unexpected)}")
        bad = True
    print(f"{path}: {len(rows)} rows, statuses={sorted(statuses)}")
sys.exit(1 if bad else 0)
PY
```

- [ ] Regenerate tables from the full run.

```bash
python3 results/csv_to_latex_figures.py results/full-ae-final --no-compile
```

- [ ] Compare generated table coverage with `results/paper/`.
  - CSV file names must match the five configured benchmark families.
  - Required columns must match.
  - Row counts must match expected coverage.
  - Status categories must be explainable.
  - Exact runtimes may differ by machine.

- [ ] Do not package `results/small/` or `results/full/` unless the artifact
  policy is intentionally changed. The package should include reference
  `results/paper/`, not local validation outputs.

## Phase 4: Final Docker Image Build

Run this only after Phase 1 metadata is final.

- [ ] Build the final shipped Docker image and save the log.

On an x86_64 Linux machine:

```bash
docker build -t quak-nqa . 2>&1 | tee docker-build-final.log
```

If building on a machine where Docker might otherwise produce a non-amd64
image, force the platform:

```bash
docker build --platform linux/amd64 -t quak-nqa . 2>&1 | tee docker-build-final.log
```

- [ ] Confirm the image architecture.

```bash
docker image inspect quak-nqa --format '{{.Os}}/{{.Architecture}}'
```

Expected for the prebuilt image:

```text
linux/amd64
```

- [ ] Confirm the Docker builder stage ran CTest.

```bash
grep -F 'ctest --test-dir build --output-on-failure' docker-build-final.log
```

Expected result: the `RUN ctest --test-dir build --output-on-failure` line is
present in the final build log, and the Docker build exits 0.

- [ ] Run runtime smoke and help checks from the final image.

```bash
docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
docker run --rm quak-nqa python3 /quak/experiment.py --help
docker run --rm quak-nqa python3 /quak/experiment_small.py --help
```

Expected smoke ending:

```text
SMOKE PASSED (quick) -- 16/16 checks, <time>s wall
```

- [ ] If table generation is meant to work inside Docker, validate it now.
  If it is not meant to work inside Docker, make sure `docs/AE_README.md` says
  table regeneration is done from `source/`.

- [ ] Keep `docker-build-final.log` as local evidence only. Do not include it
  in the artifact zip unless the policy is intentionally changed.

## Phase 5: Save And Validate The Prebuilt Docker Archive

- [ ] Save the final image with deterministic gzip metadata.

```bash
docker save quak-nqa | gzip -n > quak-nqa-docker-image.tar.gz
```

- [ ] Record archive size and checksum locally.

```bash
ls -lh quak-nqa-docker-image.tar.gz
sha256sum quak-nqa-docker-image.tar.gz
```

- [ ] Validate that the saved archive can be loaded and smoke-tested.

For the strongest local check, remove or retag the existing `quak-nqa` image
first so Docker cannot accidentally run the already-built image. Then:

```bash
docker load < quak-nqa-docker-image.tar.gz
docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
```

Expected smoke ending:

```text
SMOKE PASSED (quick) -- 16/16 checks, <time>s wall
```

## Phase 6: Validate Source Docker Rebuild Path

This catches mistakes that do not appear when loading the prebuilt image.

- [ ] Run the source rebuild wrapper from the repository root.

```bash
scripts/build-docker.sh
```

Expected behavior:

- `docker build -t quak-nqa .` succeeds.
- The builder stage compiles the tool, tests, and experiments.
- The builder stage runs CTest.
- The wrapper runs the quick smoke test.
- The smoke test ends with `SMOKE PASSED (quick) -- 16/16 checks`.

- [ ] If this requires network, confirm `docs/AE_README.md` says Docker rebuild
  may require network unless layers are cached.

## Phase 7: Build And Inspect The Artifact Zip

- [ ] Create the final artifact zip.

```bash
scripts/package-ae.sh
```

Expected behavior:

- Fails if `docs/AE_README.md` still contains `pending`, `TODO`, or `TBD`.
- Fails if `quak-nqa-docker-image.tar.gz` is missing.
- Creates `quak-cav26-artifact.zip`.
- Does not put `SHA256SUMS` inside the zip.

- [ ] Save and inspect the zip listing.

```bash
zipinfo -1 quak-cav26-artifact.zip | LC_ALL=C sort > /tmp/quak-ae-zip-files.txt
sed -n '1,240p' /tmp/quak-ae-zip-files.txt
```

- [ ] Confirm the required files are present.

```bash
required=(
  quak-cav26-artifact/README_AE.md
  quak-cav26-artifact/LICENSE
  quak-cav26-artifact/quak-nqa-docker-image.tar.gz
  quak-cav26-artifact/source/CMakeLists.txt
  quak-cav26-artifact/source/Dockerfile
  quak-cav26-artifact/source/README.md
  quak-cav26-artifact/source/LICENSE
  quak-cav26-artifact/source/experiment.py
  quak-cav26-artifact/source/experiment_small.py
  quak-cav26-artifact/source/scripts/build-docker.sh
  quak-cav26-artifact/source/scripts/package-ae.sh
  quak-cav26-artifact/source/scripts/smoke-test.sh
  quak-cav26-artifact/source/docs/AE_README.md
  quak-cav26-artifact/source/docs/CLI.md
  quak-cav26-artifact/source/docs/cav-paper110-updatedTables.pdf
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
for prefix in \
  source/src/ \
  source/samples/ \
  source/examples/ \
  source/results/paper/
do
  grep -q "^quak-cav26-artifact/$prefix" /tmp/quak-ae-zip-files.txt || {
    echo "missing source subtree: $prefix"
    exit 1
  }
done
```

- [ ] Confirm forbidden files are absent.

```bash
forbidden='(^|/)SHA256SUMS$|(^|/)build/|(^|/)\.git/|quak-nqa-linux-amd64\.tar\.gz|source/results/(small|full)/|source/docs/(CAV_ARTIFACT_TODO|MERGE_TODO|MERGE_OVERRIDES)\.md|__pycache__|docker-build-final\.log'

if grep -E "$forbidden" /tmp/quak-ae-zip-files.txt; then
  echo "forbidden file found in artifact zip"
  exit 1
fi
echo "zip inspection passed"
```

- [ ] Confirm the root README matches the source copy.

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

- [ ] Confirm shell scripts keep executable bits after packaging.

```bash
zipinfo -l quak-cav26-artifact.zip | grep 'source/scripts/.*\.sh'
```

Expected: the Unix mode for each shell script includes executable bits.

## Phase 8: Validate From The Packaged Zip, Not The Repo

This is the most important reviewer simulation. Do not skip it.

- [ ] Unpack into a clean temporary directory.

```bash
tmpdir="$(mktemp -d)"
unzip -q quak-cav26-artifact.zip -d "$tmpdir"
cd "$tmpdir/quak-cav26-artifact"
```

- [ ] Reviewer Path A: load and smoke-test the prebuilt Docker image.

```bash
docker load < quak-nqa-docker-image.tar.gz
docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
```

Expected:

```text
SMOKE PASSED (quick) -- 16/16 checks, <time>s wall
```

- [ ] Reviewer Path B: rebuild Docker from the packaged source snapshot.

```bash
cd "$tmpdir/quak-cav26-artifact/source"
scripts/build-docker.sh
```

Expected:

```text
SMOKE PASSED (quick) -- 16/16 checks, <time>s wall
```

- [ ] Reviewer native source path: build and test from packaged source.

```bash
cd "$tmpdir/quak-cav26-artifact/source"
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target tests experiments examples -j4
ctest --test-dir build --output-on-failure
cmake --build build --target smoke-test-full -j4
```

Expected:

- CTest passes 16/16.
- Full smoke passes 17/17.
- No missing source files or scripts.

- [ ] Run the small experiment from the packaged source or packaged image if
  time permits. This is the closest simulation of full review.

Native packaged source:

```bash
cd "$tmpdir/quak-cav26-artifact/source"
python3 experiment_small.py \
  --exe ./build/quak-experiment-single \
  --outdir results/small
```

Docker packaged image:

```bash
cd "$tmpdir/quak-cav26-artifact"
mkdir -p results-docker
docker run --rm \
  -v "$PWD/results-docker:/quak/results" \
  quak-nqa \
  python3 /quak/experiment_small.py --outdir /quak/results/small
```

## Phase 9: macOS And Apple Silicon Checks

CAV advice explicitly recommends testing from scratch on a machine other than
the preparation machine. Do at least one clean non-Linux or second-machine run.

- [ ] On macOS, validate native source build from the packaged zip.

```bash
unzip quak-cav26-artifact.zip
cd quak-cav26-artifact/source
cmake -S . -B build-ae-final -DCMAKE_BUILD_TYPE=Release
cmake --build build-ae-final --target tests experiments examples -j4
ctest --test-dir build-ae-final --output-on-failure
cmake --build build-ae-final --target smoke-test-full -j4
```

- [ ] On macOS / Apple Silicon, validate source Docker rebuild from the
  packaged zip.

```bash
unzip quak-cav26-artifact.zip
cd quak-cav26-artifact/source
scripts/build-docker.sh
```

- [ ] If possible, validate prebuilt `linux/amd64` Docker image loading through
  Docker Desktop emulation on Apple Silicon.

```bash
cd quak-cav26-artifact
docker load < quak-nqa-docker-image.tar.gz
docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
```

- [ ] Update `docs/AE_README.md` if macOS behavior differs from the current
  claims. If README wording changes, return to Phase 1 and rebuild Docker,
  resave the Docker archive, repackage, and regenerate checksums.

## Phase 10: Compute Checksums

CAV asks for the SHA256 checksum of the artifact zip. The local `SHA256SUMS`
file may also include the standalone Docker tarball checksum for convenience,
but the form field must use the zip checksum.

- [ ] Compute external checksums only after the zip and Docker archive are
  final.

```bash
sha256sum quak-cav26-artifact.zip quak-nqa-docker-image.tar.gz > SHA256SUMS
sha256sum -c SHA256SUMS
```

- [ ] Confirm `SHA256SUMS` is not inside the zip.

```bash
zipinfo -1 quak-cav26-artifact.zip | grep -q '^quak-cav26-artifact/SHA256SUMS$' && {
  echo "ERROR: SHA256SUMS is inside the zip"
  exit 1
}
echo "SHA256SUMS is external only"
```

- [ ] Record the zip checksum exactly for the CAV submission form.

```bash
sha256sum quak-cav26-artifact.zip
```

## Phase 11: Zenodo Upload And Download Verification

- [ ] Upload `quak-cav26-artifact.zip` to the Zenodo draft.
- [ ] Upload `SHA256SUMS` beside it.
- [ ] Confirm the Zenodo record exposes the version DOI recorded in
  `docs/AE_README.md`.
- [ ] Confirm the public/download URL does not reveal reviewer identities to
  the authors through analytics or access logs.
- [ ] Download the uploaded zip and `SHA256SUMS` to a clean directory.
- [ ] Verify the downloaded zip checksum.

```bash
sha256sum -c SHA256SUMS
```

- [ ] Unzip the downloaded artifact and rerun Path A smoke test at minimum.

```bash
unzip -q quak-cav26-artifact.zip
cd quak-cav26-artifact
docker load < quak-nqa-docker-image.tar.gz
docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
```

## Phase 12: Final CAV Submission Form

- [ ] Fill paper ID and title.
- [ ] Fill paper abstract.
- [ ] Upload or link the CAV paper PDF required by the submission system.
- [ ] Fill the artifact zip DOI/download URL.
- [ ] Fill the SHA256 checksum of `quak-cav26-artifact.zip`.
- [ ] Artifact type: Docker image.
- [ ] Architecture: `x86_64` / `linux/amd64`.
- [ ] External connectivity:
  - no network required for prebuilt image after download;
  - source native build does not need network once dependencies are installed;
  - Docker rebuild may need network for Ubuntu packages unless cached.
- [ ] Requested badges: Available + Reusable.
- [ ] Submit.
- [ ] Save a local copy or screenshot of the final submitted metadata.

## Final Stop Conditions

The artifact is ready only when every item below is true:

- [ ] `docs/AE_README.md` contains final artifact version and Zenodo version DOI.
- [ ] `docs/AE_README.md` has no `pending`, `TODO`, or `TBD` placeholders.
- [ ] Dependency documentation is accurate, including the table-generation path.
- [ ] `README.md` accurately documents `--append` resume behavior and defaults.
- [ ] Fresh native build from `build-ae-final/` passed.
- [ ] CTest passed 16/16 from the fresh build.
- [ ] Native `smoke-test-full` passed 17/17 from the fresh build.
- [ ] Example programs built and ran.
- [ ] Table generation from reference CSVs was validated.
- [ ] Small representative experiment subset was run from final source or image.
- [ ] Full experiment evidence is fresh or explicitly documented as trusted.
- [ ] Final Docker image was rebuilt after final metadata.
- [ ] Docker build log shows builder-stage CTest.
- [ ] Final Docker runtime quick smoke test passed.
- [ ] Docker image architecture is `linux/amd64`.
- [ ] `quak-nqa-docker-image.tar.gz` was saved and load-tested.
- [ ] Source Docker rebuild through `scripts/build-docker.sh` passed.
- [ ] Final zip was built by `scripts/package-ae.sh`.
- [ ] Final zip inspection found required files and no forbidden files.
- [ ] Both reviewer paths were validated from the packaged zip layout.
- [ ] Native source build was validated from the packaged zip layout.
- [ ] macOS / Apple Silicon behavior is known and documented accurately.
- [ ] External `SHA256SUMS` verifies locally.
- [ ] Zenodo upload was downloaded and checksum-verified.
- [ ] CAV submission form uses the zip checksum and the version DOI URL.

## If Time Is Extremely Short

Do not spend the last hour on optional polish. Do this minimum sequence:

1. Finalize `docs/AE_README.md` version, DOI, connectivity, and badges.
2. Fix the `README.md` resume-support mismatch.
3. Verify reference table generation still works without non-standard Python
   dependencies.
4. Run fresh native CTest and `smoke-test-full`.
5. Rebuild Docker after metadata is final.
6. Run Docker quick smoke test.
7. Save `quak-nqa-docker-image.tar.gz`.
8. Run `scripts/package-ae.sh`.
9. Inspect the zip for required and forbidden files.
10. Validate prebuilt Docker image from the packaged zip.
11. Compute the zip SHA256.
12. Upload zip and checksum to Zenodo.
13. Download, verify checksum, and rerun quick smoke.
14. Submit the CAV form with the version DOI URL and zip checksum.
