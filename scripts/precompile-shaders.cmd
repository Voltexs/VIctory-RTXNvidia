@echo off
setlocal
rem Offline shader pre-translator for NVIDIA RTX GPUs.
rem Matches the exact adapter + translator flags used by scripts\run-series-s.cmd
rem so all translated DXIL entries in %LOCALAPPDATA%\victory\cache\shaders match 1:1.
rem
rem Usage:
rem   scripts\precompile-shaders.cmd                       (uses game_dir from victory.toml or scripts\local.cmd)
rem   scripts\precompile-shaders.cmd "C:\path\to\game_dir" (scans a specific directory or archive)

set "ROOT=%~dp0.."
set "TARGET=%~1"
if "%TARGET%"=="" if exist "%~dp0local.cmd" call "%~dp0local.cmd"
if "%TARGET%"=="" if not "%VICTORY_GAME%"=="" for %%I in ("%VICTORY_GAME%") do set "TARGET=%%~dpI"

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

echo Pre-translating shaders with %EXE% ...
pushd "%ROOT%"
if "%TARGET%"=="" (
    "%EXE%" shaders %*
) else (
    "%EXE%" shaders "%TARGET%"
)
set "RC=%ERRORLEVEL%"
popd
echo.
pause
exit /b %RC%
