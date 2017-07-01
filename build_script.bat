REM Expects at least (defaults)
REM PYTHON: c:|Python27
REM MSYS2_ROOT: c:\msys64
REM BUILD_COMMIT: v0.2.19
REM BUILD_ROOT: c:\opt
REM
REM Absolute minimum PATH.
REM Stripping path this way probably not necessary, but it reduces the scope
REM for confusion.
PATH=%MSYS2_ROOT%\usr\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0
REM Make, activate virtualenv
rmdir venv /s /q
%PYTHON%\Scripts\pip install --upgrade virtualenv
%PYTHON%\Scripts\virtualenv venv
call venv\Scripts\activate.bat
REM run the rest of the build through bash
bash build.sh
call deactivate
