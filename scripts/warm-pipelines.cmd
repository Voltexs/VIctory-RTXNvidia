@echo off
setlocal
rem Offline graphics pipeline pre-warmer for NVIDIA RTX GPUs (Series S profile).
rem Matches the exact adapter + translator flags used by scripts\run-series-s.cmd
rem so the warmed NVIDIA driver cache and shader translations match 1:1.
rem
rem Note: Launch scripts\run-series-s.cmd (or scripts\run-series-s-diag.cmd) at least once
rem (with VICTORY_PIPELINE_BOOK=1, enabled by default) to the title screen so Victory writes
rem known-shaders.bin and known-pipelines.bin into %LOCALAPPDATA%\victory\cache\pipelines.
rem
rem Usage:
rem   scripts\warm-pipelines.cmd            (warms all --used pipelines; recommended)
rem   scripts\warm-pipelines.cmd --jobs 8   (override parallel worker count)

set "ROOT=%~dp0.."
set VICTORY_D3D12_ADAPTER=NVIDIA
set VICTORY_WAVE_WIDE=last
set VICTORY_PORT_CBV=1

set "EXE=%ROOT%\target\release\victory.exe"
if not exist "%EXE%" set "EXE=%ROOT%\target\diag\victory.exe"
if not exist "%EXE%" (
    echo No built victory.exe found in target\release or target\diag. Build it first.
    pause
    exit /b 1
)

echo Warming used pipelines with %EXE% ...
pushd "%ROOT%"
"%EXE%" warm --used %*
set "RC=%ERRORLEVEL%"
popd
echo.
pause
exit /b %RC%
