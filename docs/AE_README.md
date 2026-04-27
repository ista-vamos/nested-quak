# CAV 2026 Artifact

**Paper title:** Extending QuAK with Nested Quantitative Automata

**Claimed badges:** Available + Reusable

## Justification for the badges

- **Reusable** (subsumes Functional): TODO

## Requirements

| Resource | Requirement |
|----------|-------------|
| RAM | TODO |
| CPU cores | TODO |
| Disk | TODO |
| Time (smoke test) | < 1 minute with Docker (~5 sec); native build adds ~2–3 min for compilation |
| Architecture | x86_64 |
| Time (full review) | TODO |

**External connectivity:** NO

---

## Smoke Test

The quick smoke test verifies that the packaged tool is installed correctly and
runs without error. It exercises each major decision procedure on a small
representative input to confirm the binary starts, reads input, and produces
output in the expected format. It does not verify paper claims; that is the
goal of the full review.

### Using Docker (recommended)

```bash
docker load < image.tar.gz
docker run --rm quak-nqa /quak/scripts/smoke-test.sh --quick
```

Expected output ends with:
```
SMOKE PASSED (quick) -- 16/16 checks, <time>s wall
```

If the smoke test fails, please flag it in the HotCRP smoke-test review so we
can revise during the revision window.

For an interactive shell inside the container:

```bash
docker run --rm -it quak-nqa
```

You are placed in `/quak`. You can then run `scripts/smoke-test.sh --quick`
manually or explore the tool interactively (e.g. `./quak-nested`, `ls
samples/`).

### Without Docker (requires C++17 compiler + CMake >= 3.9)

Configure the build, then run the quick smoke target:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target smoke-test -j4
```

To run the quick smoke test plus the registered sanity/correctness CTest suite:

```bash
cmake --build build --target smoke-test-full -j4
```

The quick target's expected output ends with:

```
SMOKE PASSED (quick) -- 16/16 checks, <time>s wall
```

---

## Full Review

TODO

---

## Known Limitations

- **Windows/MSVC:** not officially supported (pre-existing VLA compatibility
  issue); Linux and macOS are fully supported and tested in CI.
- **Mixed-sign `SumPlus`/`SumMinus` children:** not currently supported. Use
  `SumPlus` with non-negative child weights and `SumMinus` with non-positive
  child weights.
- TODO
