# VIctory-RTXNvidia

An NVIDIA RTX–focused fork of [VIctory](https://github.com/Marvisak/VIctory), built on top of [avatarmanz/VIctory-7900XTX](https://github.com/avatarmanz/VIctory-7900XTX) and [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD), tuned for **NVIDIA wave32 GPUs, 8 GB VRAM laptops/desktops, and 32 GB system RAM** running Xbox Series titles natively on Windows from files the user supplies.

**This repository contains no game files, code, or assets.** You need your own copy of the title. It is not affiliated with or endorsed by any game developer or publisher.

---

## What is different for NVIDIA RTX & 8 GB VRAM

On NVIDIA GPUs (wave32 hardware, 1,000,000 shader-visible view heap cap / `raw_twins=false`, and 8 GB VRAM budgets around `7.0–7.2 GB`), stock AMD-oriented settings hit severe bottlenecks. This fork adds targeted fixes:

| Feature / Switch | What it fixes on NVIDIA RTX |
|---|---|
| `VICTORY_PORT_SECTIONS=1` / `noncard` (+ `VICTORY_PORT_SECTIONS_MB`) | Extends Renderer Port #1 (`OpenExistingHeapFromAddress1` via a second `MapViewOfFile` view) from `< 4 GiB` to contiguous 64-bit XMem section stretches (`Cover::Run`), giving Xbox-style zero-copy unified memory without Error-87 view-lock crashes or pinning untouched pool pages. |
| `VICTORY_TEXTURE_POOL=staging` | Keeps GPU textures unpooled (eliminating ~2.5 GB of fragmented 64 MiB VRAM blocks on 8 GB cards) while keeping host RAM staging buffers pooled. |
| `VICTORY_WAIT_RESIDENT=0` | Disables synchronous copy-queue fence waits under the global `ASIDE` lock (an AMD-specific workaround that caused tens of thousands of stalls per minute on NVIDIA). |
| `VICTORY_WAVE_WIDE=last` | Only falls back to wave-wide branch lowering for wave64 compute shaders after all narrower/local-wave forms fail, keeping NVIDIA wave32 graphics/particle shaders exact while allowing wave64 compute shaders to build. |
| Recycled `shadow::exact()` buffer pool | NVIDIA's `1,000,000` view heap cap disables `raw_twins`, routing thousands of offset buffer views/frame into `shadow::exact()`. Replaces per-frame `CreateCommittedResource` storms and $O(N^2)$ cache sweeps with a 64 MiB size-bucketed pool and throttled eviction (`~20x` faster list translation). |
| Pooled water / texture readbacks (`texback.rs`) | Reuses D3D12 readback buffers (`READBACK_POOL`, up to 16 MiB) and thread-local tiling scratch buffers (`0 CreateCommittedResource/frame`) and skips unaddressable XOR-swizzled render targets (`_X`/`_T`) before recording GPU copies. |
| `VICTORY_LEVELS_MIN_KB=128` + `VICTORY_TEXTURE_LOOK_MS=250` | Reclaims ~1.0–1.2 GB of wasted VRAM on unmapped MIP0 levels of streamed textures and cuts waiting-texture re-check backoff from `256 frames` down to `250 ms`. |
| Rate-limited `port_descriptors` warnings & F3 HUD | Prevents per-second log spam from descriptor-hook misses and supports the built-in F3 live diagnostics overlay in `diag` builds. |

---

## Requirements

- Windows 10/11 x64
- CPU with AVX2
- Direct3D 12 GPU with Shader Model 6.6 and Mesh Shaders (tested on **NVIDIA GeForce RTX 3070 Laptop GPU, 8 GB VRAM, 32 GB RAM**)
- Rust toolchain (pinned in `rust-toolchain.toml`) and MSVC build tools
- Your own dump of the title, stored **outside** this repository

---

## Build & Run

```powershell
git clone https://github.com/Voltexs/VIctory-RTXNvidia
cd VIctory-RTXNvidia
copy victory.example.toml victory.toml   # set paths outside this folder

# Build release (best FPS) and diag (F3 HUD + series-s-diag.log telemetry)
cargo build --locked --release -p victory
cargo build --locked --profile diag -p victory --features diagnostics
```

### Launcher Scripts (`scripts/`)

All launcher scripts live in [`scripts/`](scripts/). Pass your title executable as the first argument, set `VICTORY_GAME`, or create a git-ignored `scripts\local.cmd` containing:

```cmd
@echo off
set "VICTORY_GAME=C:\path\to\your\title.exe"
```

| Script | Purpose |
|---|---|
| `scripts\run-series-s.cmd` | **Recommended (1080p release):** best FPS & visual quality with all NVIDIA/8 GB VRAM optimizations and zero-copy XMem sections (`VICTORY_PORT_SECTIONS=1`). |
| `scripts\run-series-s-diag.cmd` | **1080p diagnostics:** runs `target\diag\victory.exe`, enables the `F3` HUD, and tees full telemetry to `series-s-diag.log`. |
| `scripts\warm-pipelines.cmd` | **Offline pipeline pre-warmer:** pre-compiles `--used` pipelines offline using the exact same NVIDIA + translator flags (`VICTORY_D3D12_ADAPTER=NVIDIA`, `VICTORY_WAVE_WIDE=last`, `VICTORY_PORT_CBV=1`). Run once after reaching the title screen/open world. |
| `scripts\run-series-s-720p-maxfps.cmd` | **720p max-FPS release:** lowers output to `1280x720` with `VICTORY_UPSCALER=6` (avoids 720p FSR jitter crash). |
| `scripts\run-series-s-safe.cmd` | **Safe fallback:** disables experimental renderer ports and thin lists for A/B troubleshooting. |
| `scripts\play.ps1` | Upstream PowerShell launcher (supports `-Safe`, `-RayTracing`, `-Fsr4K`, `-Build`, `-More`). |

> **Tip:** Run launchers from a normal (non-Administrator) window so the NVIDIA driver keeps its shader cache in your normal user profile.

### Offline Shader & Pipeline Warming

```cmd
scripts\warm-pipelines.cmd
```

Or run `victory` directly:

```powershell
target\release\victory.exe shaders <path-to-shader-archives>
target\release\victory.exe warm --used
```

---

## Upstream Renderer Ports & Switches

Inherited from `VIctory-7900XTX` and enabled in `scripts\run-series-s*.cmd`:

- `VICTORY_PORT_CONSTANTS=1` — Maps the title's 32-bit constants heap in place (`OpenExistingHeapFromAddress1`).
- `VICTORY_PORT_SECTIONS=1` (or `noncard`) — Extends zero-copy section mapping to contiguous 64-bit XMem section stretches (`VICTORY_PORT_SECTIONS_MB=1024`).
- `VICTORY_PORT_DESCRIPTORS=1` — Patches descriptor-table stores to report written slots directly instead of scanning hundreds of thousands of slots per frame.
- `VICTORY_PORT_CBV=1` — Translates root CBVs to raw byte reads in place.
- `VICTORY_PORT_GUARD=1` — Shared write-guard locking with per-block claims and parallel refresh planning.
- `VICTORY_PORT_JOURNAL=1` — Partitioned descriptor journal locks and submit-time heap record scheduling.
- `VICTORY_THIN=1`, `VICTORY_UPLOAD_AHEAD=1`, `VICTORY_RELAY=2`, `VICTORY_CARD_STEPS=2` — Multi-threaded command list translation, dedicated copy-queue texture uploads, background shader write readbacks, and GPU-side buffer fills.

More documentation and upstream switch details live in [docs/README-fxceless.md](docs/README-fxceless.md), [docs/findings.md](docs/findings.md), [docs/replay.md](docs/replay.md), and [docs/asset-policy.md](docs/asset-policy.md).

---

## Credits

This repository preserves full upstream commit history and builds directly on the work of:

- **[Marvisak/VIctory](https://github.com/Marvisak/VIctory)** and its contributors: the loader, runtime services, Direct3D 12 backend, and shader recompiler.
- **[fxceless/victory-fork](https://github.com/fxceless/victory-fork)**: core performance, stability, water readback, and shader fixes.
- **[avatarmanz/VIctory-7900XTX](https://github.com/avatarmanz/VIctory-7900XTX)**: Renderer Ports 1–7, multi-threaded submission/thin lists, and frame replay tooling.
- **[Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD)**: ambient light stand-in, pipeline workers, HUD overlay, and rebase onto `VIctory-7900XTX`.
- **[DexNom/VIctory](https://github.com/DexNom/VIctory)**: ray tracing fixes, cube gradients, sparse textures, and PC FidelityFX bridge.
- **[myokex/victory-amd](https://github.com/myokex/victory-amd)**, **[FQY55kai/ZJOU-VICTORY](https://github.com/FQY55kai/ZJOU-VICTORY)**, **Geckomacabre**, **cxy0072019-sketch**, and all upstream pull-request authors.

## License

GPL-3.0-or-later, as VIctory. See [LICENSE](LICENSE); the single asset-policy exception is documented in [docs/asset-policy.md](docs/asset-policy.md).
