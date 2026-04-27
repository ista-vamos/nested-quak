# CAV 2026 Artifact

**Paper title:** Extending QuAK with Nested Quantitative Automata

**Claimed badges:** Available + Reusable (see below for justification)

**Artifact version:** pending final package

**Zenodo DOI:** pending upload

**Checksums:** `SHA256SUMS` will be uploaded beside the final package on
Zenodo.

## Artifact Contents

The final artifact package has the following intended layout:

```text
quak-cav26-artifact/
  README_AE.md
  LICENSE
  quak-nqa-docker-image.tar.gz
  source/
    CMakeLists.txt
    Dockerfile
    README.md
    experiment.py
    experiment_small.py
    scripts/
    src/
    samples/
    examples/
    docs/
    results/
      csv_to_latex_figures.py
      paper/
        *.csv
        benchmark_tables.tex
        benchmark_tables.pdf
```

The Docker image is the recommended entry point for smoke testing. The
`source/` directory contains the complete source snapshot, tests, samples,
experiment drivers, reference paper CSV files, and the table-generation script.
The checked-in `source/results/paper/` files are reference outputs. Reviewers
who run the experiments should regenerate tables from their own generated CSV
directory.

External network connectivity is not required.

## Requirements

| Resource | Requirement |
|----------|-------------|
| RAM | 30 GB recommended for full experiments; less is sufficient for build, smoke test, and CTest |
| CPU cores | 4+ cores recommended; commands below use `-j4` |
| Disk | 2 GB free recommended for normal review; 5 GB if rebuilding the Docker image from source |
| Architecture | x86_64 Docker image; native source build is intended for Linux and macOS |
| External connectivity | Not required |

Approximate running times on the authors' evaluation machine:

| Task | Expected time |
|------|---------------|
| Build Docker image from source | < 5 minutes |
| Docker or native smoke test | < 1 minute |
| Registered CTest suite | < 1 minute |
| Small representative experiment subset | about 1 hour 15 minutes |
| Full paper experiment suite | about 5 hours |

Timings are hardware-dependent. The benchmark scripts use a 300 second
per-instance timeout and a 30 GB memory limit by default.

## Smoke Test

The quick smoke test verifies that the packaged tool is installed correctly and
runs without error. It exercises each major decision procedure on a small
representative input to confirm the binary starts, reads input, and produces
output in the expected format. It does not verify paper claims; that is the
goal of the full review.

### Using Docker

Load the packaged image and run the quick smoke test:

```bash
docker load < quak-nqa-docker-image.tar.gz
docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
```

Expected output ends with:

```text
SMOKE PASSED (quick) -- 16/16 checks, <time>s wall
```

For an interactive shell inside the container:

```bash
docker run --rm -it quak-nqa
```

The shell starts in `/quak`. From there, reviewers can run
`scripts/smoke-test.sh --quick`, inspect `samples/`, or invoke the main CLI
with `./quak-nested`.

The packaged Docker image is built for `linux/amd64`. On Apple Silicon Macs,
Docker Desktop can usually run this image through emulation. Reviewers who want
a native Docker image for their platform may instead rebuild from the
`source/` directory:

```bash
docker build -t quak-nqa .
```

The Docker build runs the registered CTest suite in the builder stage, so a
successful rebuild also verifies the packaged source on that platform.

### From Source

From the `source/` directory:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target smoke-test -j4
```

Expected output ends with:

```text
SMOKE PASSED (quick) -- 16/16 checks, <time>s wall
```

To run the quick smoke test plus the registered CTest suite:

```bash
cmake --build build --target smoke-test-full -j4
```

## Native Build And Tests

The source package can be built without Docker. From the `source/` directory:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j4
cmake --build build --target tests -j4
ctest --test-dir build --output-on-failure
cmake --build build --target experiments -j4
```

The main CLI is `build/quak-nested`. The experiment runner is
`build/quak-experiment-single`.

## Full Review

The paper experiments are driven by `experiment.py`, which runs five configured
benchmark families and writes one CSV file per family. The small review run uses
the same machinery on a representative subset.

### Small Representative Experiments

From the `source/` directory after building the `experiments` target:

```bash
python3 experiment_small.py \
  --exe ./build/quak-experiment-single \
  --outdir results/small
```

This run takes about 1 hour 15 minutes on the authors' evaluation machine.

Inside Docker, use a bind mount if the generated CSVs should be kept outside
the container:

```bash
mkdir -p results-docker
docker run --rm \
  -v "$PWD/results-docker:/quak/results" \
  quak-nqa \
  python3 /quak/experiment_small.py --outdir /quak/results/small
```

### Full Paper Experiments

From the `source/` directory after building the `experiments` target:

```bash
python3 experiment.py \
  --exe ./build/quak-experiment-single \
  --outdir results/full
```

This run takes about 5 hours on the authors' evaluation machine. It uses the
default 300 second per-instance timeout and 30 GB memory limit.

The same full experiment driver can also be run from Docker with persisted
outputs:

```bash
mkdir -p results-docker
docker run --rm \
  -v "$PWD/results-docker:/quak/results" \
  quak-nqa \
  python3 /quak/experiment.py --outdir /quak/results/full
```

The configured experiment families are:

| Output CSV | Benchmark family | Decision problem | Aggregators |
|------------|------------------|------------------|-------------|
| `response_sup_sumplus_emptiness.csv` | Response time | emptiness | `Sup`, `SumPlus` |
| `response_limsupavg_sumplus_emptiness.csv` | Response time | emptiness | `LimSupAvg`, `SumPlus` |
| `response_sup_sumb_universality.csv` | Response time | universality | `Sup`, `SumB:auto` |
| `resource_sup_max_emptiness.csv` | Resource consumption | emptiness | `Sup`, `Max` |
| `resource_limsupavg_max_emptiness.csv` | Resource consumption | emptiness | `LimSupAvg`, `Max` |

Each CSV row records the input parameters, status, mean runtime, and Boolean
result. Status values include:

| Status | Meaning |
|--------|---------|
| `OK` | Instance completed and produced a consistent result |
| `OOT` | Instance exceeded the 300 second timeout |
| `OOM` | Instance exceeded the 30 GB memory limit |
| `INCONSISTENT` | Repetitions disagreed; this should be treated as a failure |

Timeout and out-of-memory entries are expected for some large benchmark cells
and are represented explicitly in the paper tables.

## Regenerating Tables

The final artifact includes reference tables and CSVs in
`source/results/paper/`. To regenerate tables after running the full
experiments, run the table script on the new CSV directory:

```bash
python3 results/csv_to_latex_figures.py results/full --no-compile
```

This writes `results/full/benchmark_tables.tex`.

If LaTeX tools are installed and a PDF is desired:

```bash
python3 results/csv_to_latex_figures.py results/full
```

This writes both `results/full/benchmark_tables.tex` and
`results/full/benchmark_tables.pdf`.

Compare the regenerated files with the reference files under
`results/paper/`. Exact runtimes may differ by machine, but the CSV structure,
status categories, and benchmark coverage should match.

## Known Limitations

- **Windows/MSVC:** not officially supported. Linux and macOS source builds are
  the supported native workflows.
- **Apple Silicon Docker:** the packaged image is `linux/amd64` and may run
  through Docker Desktop emulation. Rebuilding the image from `source/` can
  produce a native image for the local platform.
- **Benchmark scale:** some full benchmark cells may time out or exceed the
  30 GB memory limit. These outcomes are expected benchmark data, not smoke-test
  failures.

## Final Package Checklist

Before submission, the final package should satisfy:

- `README_AE.md` contains the final artifact version, Zenodo DOI, and checksum
  location.
- `SHA256SUMS` is uploaded beside the artifact zip and records checksums for
  the artifact zip and Docker image tarball.
- `quak-nqa-docker-image.tar.gz` loads successfully with `docker load`.
- `docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick` passes.
- The `source/` snapshot builds natively with the commands above.
- The `source/results/paper/` reference CSVs and table outputs are present.

## Justification for the Badges

### Available

**Q: Does the artifact have a DOI?**

A: The final artifact will be uploaded to Zenodo. The version-specific DOI will
be listed at the top of this README after upload.

**Q: Does the artifact have an appropriate license?**

A: Yes. The project is distributed under the MIT License, which permits use,
examination, modification, redistribution, and reuse within and outside CAV
2026 Artifact Evaluation.

**Q: Is the artifact self-contained for evaluation?**

A: Yes. The package includes the source snapshot, Docker image, scripts,
samples, reference outputs, and checksums. It does not require external network
access during evaluation.

### Functional

**Q: Is the artifact documented?**

A: Yes. The "Artifact Contents" section inventories the package, and this
README gives the commands needed to exercise it.

**Q: Is the artifact consistent?**

A: Yes. The included tool, inputs, experiment scripts, reference CSVs, and table
script directly support the paper's benchmark results.

**Q: Is the artifact complete enough to reproduce the paper results?**

A: Yes. The package includes the source, Docker image, tests, benchmark inputs,
experiment drivers, reference CSVs, and table-generation script. No proprietary
software or external services are required.

**Q: Is the artifact exercisable by reviewers?**

A: Yes. The included commands run the smoke test, CTest suite, small experiment
subset, full experiment suite, and table generation over accessible local data.

### Reusable

**Q: Does the license allow reuse and repurposing?**

A: Yes. The MIT License allows reuse and repurposing beyond CAV 2026 Artifact
Evaluation.

**Q: Are dependencies documented and minimal?**

A: Yes. The core tool requires only a C++17 compiler, CMake, and Make. Python 3
is used only for the experiment orchestration scripts. Docker is optional, and
LaTeX is needed only to regenerate the PDF version of the tables.

**Q: Can the artifact be used beyond reproducing the paper?**

A: Yes. `README.md` documents the nested-automata input format and CLI usage,
`docs/CLI.md` lists supported commands and value functions, `examples/`
contains buildable example programs, and `samples/` contains automata that can
be adapted as templates. Users can prepare new inputs in the documented format
and run them with `quak-nested`; the C++ sources in `src/` are also available
for library-level extensions.

**Q: Is the artifact open and extensible?**

A: Yes. The source code is included under an open-source license. The main
extension surface is the family of nested-to-non-nested flattening algorithms:
developers can add new flattening procedures in the same pattern (e.g., for new
aggregator combinations, optimized constructions, or alternative symbolic
representations), and the existing flattening methods are exposed through the
public C++ API for use outside the CLI and Docker environment.

**Q: Can the artifact be used in more than one environment?**

A: Yes. The tool can be built from source and used outside Docker; native build
instructions are given above. Docker is provided as a convenience path.
