# KimiK3-4G

A tiny launcher/distribution for the upstream **Kimi K3 in C** ultra-low-memory path.
It keeps the official full Kimi K3 checkpoint and exact routing/math, but defaults to
upstream's `ultra` execution profile so the inference process stays below a 4 GiB-class
RAM budget.

## What this is

- Full 2.78T Kimi K3 checkpoint; this is **not** a distilled/retrained model.
- Exact BF16/MXFP4 weights and all 93 layers.
- Embedding rows are streamed instead of keeping the 2.35 GB table resident.
- `lm_head` is projected in bounded streamed chunks instead of keeping 2.35 GB resident.
- Full-recompute mode reuses one recurrent-state slot.
- Trunk budget: **2.50 GB**.
- Expert-cache budget: **0.31 GB**.
- Upstream measured peak: **2.573 GiB RSS** on four complete one-token runs.

The trade-off is speed and storage. The official checkpoint plus packed trunk still needs
about **1.7 TB** of fast local storage. The upstream Jetson proof averaged about **949 s**
for one generated token. Treat this as proof-of-life / research mode, not interactive chat.

## Pinned upstream

This distribution pins:

- Repository: `FareedKhan-dev/kimi-k3-in-c`
- Commit: `117e9d29bde14db9742f54fb66a191fd0bf03903`
- Ultra feature introduced by commit: `b2f5b5bc6f1f575f6506e658299366b643dad053`

Pinning makes behavior reproducible and avoids silently pulling a future incompatible CLI.

## Quick start (Linux/macOS)

```bash
./scripts/bootstrap.sh

# after downloading the official checkpoint and preparing the packed trunk with upstream tools:
./scripts/run-4gb.sh \
  --model ~/k3model \
  --trunk ~/k3trunk \
  --tok ~/k3model \
  --prompt "The capital of France is" \
  --gen 1
```

## Quick start (Windows / MSYS2 MinGW-w64)

Run from an MSYS2 MinGW64 shell:

```bash
bash scripts/bootstrap.sh
bash scripts/run-4gb.sh \
  --model /c/models/k3model \
  --trunk /c/models/k3trunk \
  --tok /c/models/k3model \
  --prompt "The capital of France is" \
  --gen 1
```

Upstream has native Windows support through MinGW-w64. A 4 GB physical Windows machine is
very tight because Windows itself consumes a large part of RAM; keep the page file enabled
and close other applications. The measured inference process peak is below 2.6 GiB, but
this repository does not claim a 4 GB Windows machine was physically validated.

## Download / prepare weights

This repository intentionally does **not** redistribute the 1.56 TB checkpoint.
Use the pinned upstream tools after bootstrap:

```bash
cd upstream
# Follow upstream README Full setup / download scripts.
# Then pack the trunk using the upstream packing script.
```

The launcher refuses settings that defeat the low-memory contract. In particular,
`--incremental`, `--spec`, and `--draft-trunk` are not exposed by `run-4gb.sh` because they
allocate additional carried state/KV or draft state.

## Memory contract

`run-4gb.sh` always invokes:

```text
--preset ultra --ultra-low-memory
```

and leaves generation in full-recompute mode. You can set prompt and generation length,
but short requests are strongly recommended because full recompute is intentionally traded
for lower RAM.

## Verify installation

```bash
./scripts/verify.sh
```

This checks the pinned commit, builds the weightless tests and asserts that the upstream
CLI still advertises the `ultra` preset. It does not download model weights.

## Why this repo is small

Rather than copying tens of MB of upstream code and losing provenance, this repository
contains only the 4 GB launcher, reproducible bootstrap and documentation. The source is
checked out at an exact upstream commit into `upstream/` locally. This keeps Apache-2.0
attribution clear and makes future upgrades reviewable as a single pinned-commit change.

## License

Launcher code in this repository is Apache-2.0. Upstream code retains its original
Apache-2.0 license and NOTICE. See `NOTICE`.
