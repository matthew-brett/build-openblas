@echo off
REM run script through bash
REM Expects
REM    MSYS2_ROOT: c:\msys64
IF "%~1"=="" (exit /b)
IF "%MSYS2_ROOT%"=="" (set MSYS2_ROOT=c:\msys64)
PATH=%MSYS2_ROOT%\usr\bin;%PATH%
bash %*
