@echo off
setlocal
rem Safe fallback launcher (without experimental renderer ports or thin lists) for A/B troubleshooting.
rem Usage:
rem   scripts\run-series-s-safe.cmd "C:\path\to\title.exe"

set "ROOT=%~dp0.."
set "GAME=%~1"
if "%GAME%"=="" if exist "%~dp0local.cmd" call "%~dp0local.cmd"
if "%GAME%"=="" set "GAME=%VICTORY_GAME%"
if "%GAME%"=="" (
    echo Usage: scripts\run-series-s-safe.cmd "C:\path\to\title.exe"
    echo Or create a git-ignored scripts\local.cmd with: set "VICTORY_GAME=C:\path\to\title.exe"
    pause
    exit /b 1
)

set VICTORY_D3D12_ADAPTER=NVIDIA
set VICTORY_DISPLAY_MODE=1920x1080
set VICTORY_D3D12_BACKGROUND=0
set VICTORY_D3D12_DRED=light
set VICTORY_WAVE_WIDE=last

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
set VICTORY_UNDER_WIDE=0
set VICTORY_LAND_ECHO=0

set VICTORY_WAIT_RESIDENT=0
set VICTORY_TEXTURE_POOL=staging
set VICTORY_RESIDENCY=1
set VICTORY_KEEP_FREED=0
set VICTORY_LEVELS_ON_DEMAND=1
set VICTORY_LEVELS_MIN_KB=128
set VICTORY_TEXTURE_LOOK_MS=250
set VICTORY_TEXTURE_ROOM_PERCENT=90
set VICTORY_TEXTURE_STAGE_MB=64
set VICTORY_CARD_ROOM_FOR_TARGETS_MB=1400
set VICTORY_CARD_BUFFERS_MIN_MB=1
set VICTORY_CARD_BUFFERS_MB=640
set VICTORY_CARD_WINDOWS_MB=0

pushd "%ROOT%"
"%ROOT%\target\release\victory.exe" run "%GAME%" --console series-s --execute
set "RC=%ERRORLEVEL%"
popd
exit /b %RC%
