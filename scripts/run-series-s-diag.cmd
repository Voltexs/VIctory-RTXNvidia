@echo off
setlocal
rem VIctory-RTXNvidia diagnostics launcher tuned for NVIDIA RTX GPUs (8 GB VRAM, 32 GB RAM, 1080p, Series S profile).
rem Press F3 in-game to toggle the live performance HUD panel. Writes series-s-diag.log at repo root.
rem Usage:
rem   scripts\run-series-s-diag.cmd "C:\path\to\title.exe"
rem Or set VICTORY_GAME in your environment or in a git-ignored scripts\local.cmd file.

set "ROOT=%~dp0.."
set "GAME=%~1"
if "%GAME%"=="" if exist "%~dp0local.cmd" call "%~dp0local.cmd"
if "%GAME%"=="" set "GAME=%VICTORY_GAME%"
if "%GAME%"=="" (
    echo Usage: scripts\run-series-s-diag.cmd "C:\path\to\title.exe"
    echo Or create a git-ignored scripts\local.cmd with: set "VICTORY_GAME=C:\path\to\title.exe"
    pause
    exit /b 1
)

set VICTORY_D3D12_ADAPTER=NVIDIA
set VICTORY_DISPLAY_MODE=1920x1080
set VICTORY_D3D12_BACKGROUND=0
set VICTORY_D3D12_DRED=light
set VICTORY_WAVE_WIDE=last
set VICTORY_PIPELINE_BOOK=1

rem Core multi-threaded pipeline
set VICTORY_THIN=1
set VICTORY_JOIN_PARTS=8
set VICTORY_UPLOAD_AHEAD=1
set VICTORY_TEXTURE_NO_WAIT=1
set VICTORY_RELAY=2
set VICTORY_RELAY_COPY=1
set VICTORY_WIDE_BACK=1
set VICTORY_CARD_REHASH_RUNS=1
set VICTORY_JOIN_COPIES=1
set VICTORY_INDIRECT_WINDOW=1
set VICTORY_INDIRECT_BATCH=2
set VICTORY_CARD_STEPS=2
set VICTORY_MAP_THREADS=1
set VICTORY_TITLE_PRIORITIES=0
set VICTORY_CARD_AWAKE=0
set VICTORY_PLACED_ORDER=1
set VICTORY_SHOW_AFTER=1
set VICTORY_AMBIENT=0.8
set VICTORY_LATE_WAIT=3

rem Renderer ports 1, 2, 5, 6, 7, RT-part1 + zero-copy non-card XMem sections (hot big buffers stay in 448 GB/s VRAM)
set VICTORY_PORT_CONSTANTS=1
set VICTORY_PORT_SECTIONS=noncard
set VICTORY_PORT_SECTIONS_MB=1024
set VICTORY_PORT_DESCRIPTORS=1
set VICTORY_PORT_CBV=1
set VICTORY_PORT_GUARD=1
set VICTORY_PORT_JOURNAL=1
set VICTORY_PORT_RT=1

rem 8 GB VRAM + 32 GB RAM NVIDIA RTX tuning
set VICTORY_WAIT_RESIDENT=0
set VICTORY_TEXTURE_POOL=staging
set VICTORY_RESIDENCY=1
set VICTORY_KEEP_FREED=0
set VICTORY_THIN_THREADS=8
set VICTORY_UNDER_THREADS=6
set VICTORY_LAND_THREADS=6
set VICTORY_LEVELS_ON_DEMAND=1
set VICTORY_LEVELS_MIN_KB=128
set VICTORY_TEXTURE_CATCHUP=0
set VICTORY_TEXTURE_LOOK_MS=500
set VICTORY_TEXTURE_AWAY_MS=8000
set VICTORY_TEXTURE_ROOM_PERCENT=92
set VICTORY_TEXTURE_STAGE_MB=48
set VICTORY_TEXTURE_STAGE_MS=12
set VICTORY_CARD_ROOM_FOR_TARGETS_MB=1400
set VICTORY_CARD_RESERVE_BUDGETS=1
set VICTORY_CARD_BUFFERS_MIN_KB=64
set VICTORY_CARD_BUFFERS_MB=1280
set VICTORY_CARD_WINDOWS_MB=384

pushd "%ROOT%"
powershell -NoProfile -Command "& '%ROOT%\target\diag\victory.exe' run '%GAME%' --console series-s --execute 2>&1 | Tee-Object -FilePath '%ROOT%\series-s-diag.log'"
set "RC=%ERRORLEVEL%"
popd
exit /b %RC%
