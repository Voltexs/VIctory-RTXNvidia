@echo off
setlocal
rem VIctory-RTXNvidia release launcher tuned for NVIDIA RTX GPUs (8 GB VRAM, 32 GB RAM, 1080p, Series S profile).
rem Usage:
rem   scripts\run-series-s.cmd "C:\path\to\title.exe"
rem Or set VICTORY_GAME in your environment or in a git-ignored scripts\local.cmd file:
rem   set "VICTORY_GAME=C:\path\to\title.exe"

set "ROOT=%~dp0.."
set "GAME=%~1"
if "%GAME%"=="" if exist "%~dp0local.cmd" call "%~dp0local.cmd"
if "%GAME%"=="" set "GAME=%VICTORY_GAME%"
if "%GAME%"=="" (
    echo Usage: scripts\run-series-s.cmd "C:\path\to\title.exe"
    echo Or create a git-ignored scripts\local.cmd with: set "VICTORY_GAME=C:\path\to\title.exe"
    pause
    exit /b 1
)

rem Select dedicated NVIDIA RTX GPU and 1080p display
set VICTORY_D3D12_ADAPTER=NVIDIA
set VICTORY_DISPLAY_MODE=1920x1080
set VICTORY_D3D12_BACKGROUND=0

rem Safe wave32 fallback for wave64 compute shaders (only widens if narrower/local-wave forms fail)
set VICTORY_WAVE_WIDE=last
rem Record known shaders/pipelines to disk so scripts\warm-pipelines.cmd can pre-compile them offline
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
set VICTORY_CARD_AWAKE=1
set VICTORY_SHOW_AFTER=1
set VICTORY_AMBIENT=0.8
set VICTORY_LATE_WAIT=3

rem Renderer ports 1, 2, 5, 6, 7 + Xbox-style zero-copy XMem section stretches via second view
set VICTORY_PORT_CONSTANTS=1
set VICTORY_PORT_SECTIONS=1
set VICTORY_PORT_SECTIONS_MB=1024
set VICTORY_PORT_DESCRIPTORS=1
set VICTORY_PORT_CBV=1
set VICTORY_PORT_GUARD=1
set VICTORY_PORT_JOURNAL=1

rem 8 GB VRAM + 32 GB RAM tuning:
rem - VICTORY_WAIT_RESIDENT=0: disables synchronous copy-queue fence stalls under ASIDE lock
rem - VICTORY_TEXTURE_POOL=staging: keeps GPU textures unpooled to eliminate ~2.5 GB VRAM fragmentation while pooling RAM staging
rem - VICTORY_RESIDENCY=1 + VICTORY_KEEP_FREED=0: keeps 32 GB host RAM commit healthy & reclaims idle staging/scratch
rem - VICTORY_LEVELS_MIN_KB=128: reclaims ~1.0-1.2 GB VRAM on unmapped MIP0 levels of streamed textures
rem - VICTORY_TEXTURE_LOOK_MS=250: re-checks waiting texture slots every 250 ms instead of 256 frames
rem - VICTORY_LAND_THREADS=8: parallelizes copy-back merge workers
set VICTORY_WAIT_RESIDENT=0
set VICTORY_TEXTURE_POOL=staging
set VICTORY_RESIDENCY=1
set VICTORY_KEEP_FREED=0
set VICTORY_THIN_THREADS=6
set VICTORY_LAND_THREADS=8
set VICTORY_LEVELS_ON_DEMAND=1
set VICTORY_LEVELS_MIN_KB=128
set VICTORY_TEXTURE_LOOK_MS=250
set VICTORY_TEXTURE_ROOM_PERCENT=92
set VICTORY_TEXTURE_STAGE_MB=128
set VICTORY_TEXTURE_STAGE_MS=40
set VICTORY_CARD_ROOM_FOR_TARGETS_MB=1400
set VICTORY_CARD_BUFFERS_MIN_KB=256
set VICTORY_CARD_BUFFERS_MB=640
set VICTORY_CARD_WINDOWS_MB=0

pushd "%ROOT%"
"%ROOT%\target\release\victory.exe" run "%GAME%" --console series-s --execute
set "RC=%ERRORLEVEL%"
popd
exit /b %RC%
