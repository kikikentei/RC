@echo off
rem Drag and drop a folder containing DWG files onto this file.
rem Output: <folder>\DXF  (DXF 2018)
if "%~1"=="" (
  echo Usage: drag a folder onto dwg2dxf.bat
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0dwg2dxf.ps1" -InDir "%~1" -Recurse
pause
