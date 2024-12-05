@echo off
powershell -Command "Start-Process -FilePath 'powershell.exe' -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -NoProfile -File \"%~dp0SymlinkManager.ps1\"' -Verb RunAs"
pause