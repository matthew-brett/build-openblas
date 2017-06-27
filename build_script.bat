REM Expects at least (defaults)
REM MSYS2_ROOT: c:\msys64
REM BUILD_COMMIT: v0.2.19
REM BUILD_ROOT: c:\opt
git submodule update --init --recursive
REM We need at least the build tools, tar
set PATH=%MSYS2_ROOT%\usr\bin;%PATH%
set OUR_WD=%cd%
REM Work in virtualenv
pip install --upgrade virtualenv
rmdir venv /s /q
rmdir /s /q builds
virtualenv venv
call venv\Scripts\activate.bat
REM Get Python bitness
REM https://stackoverflow.com/questions/1746475/windows-batch-help-in-setting-a-variable-from-command-output#4509885
set PY_CMD=python -c "import platform; print(platform.architecture()[0][:2])"
for /f "tokens=1 delims=" %%i in ('%PY_CMD%') do set PYTHON_ARCH=%%i
REM Install mingwpy gcc
pip install -i https://pypi.anaconda.org/carlkl/simple mingwpy
REM Patch specs file
bash patch_specs.sh
gcc -dumpspecs
cd OpenBLAS
git checkout %BUILD_COMMIT%
git clean -fxd
git reset --hard
rmdir /s /q %BUILD_ROOT%\%PYTHON_ARCH%
set LIBNAMESUFFIX=%BUILD_COMMIT%_mingwpy
make BINARY=%PYTHON_ARCH% DYNAMIC_ARCH=1 USE_THREAD=1 USE_OPENMP=0 ^
     NUM_THREADS=24 NO_WARMUP=1 NO_AFFINITY=1 CONSISTENT_FPCSR=1 ^
     BUILD_LAPACK_DEPRECATED=1 MAX_STACK_ALLOC=2048
make PREFIX=%BUILD_ROOT%\%PYTHON_ARCH% install
cd %BUILD_ROOT%
REM Copy library link file for custom name
cd %PYTHON_ARCH%\lib
set DLL_BASENAME=libopenblas_%LIBNAMESUFFIX%
cp %DLL_BASENAME%.dll.a %DLL_BASENAME%.lib
cd ..\..
REM Build template site.cfg for using this build
(
echo [openblas]
echo libraries = %DLL_BASENAME%
echo library_dirs = {openblas_root}\%PYTHON_ARCH%\lib
echo include_dirs = {openblas_root}\%PYTHON_ARCH%\include
) > %PYTHON_ARCH%\site.cfg.template
set TAR_NAME=openblas-%BUILD_COMMIT%_win%PYTHON_ARCH%.tar.gz
tar zcvf %TAR_NAME% %PYTHON_ARCH%
copy %TAR_NAME% %OUR_WD%\builds
cd %OUR_WD%
call deactivate
