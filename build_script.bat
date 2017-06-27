REM Expects at least (defaults)
REM MSYS2_ROOT: c:\msys64
REM BUILD_COMMIT: v0.2.19
REM BUILD_ROOT: c:\opt
REM PYTHON_ARCH: "32"
git submodule update --init --recursive
REM We need at least the build tools, tar
set PATH=%MSYS2_ROOT%\usr\bin;%PATH%
REM Work in virtualenv
pip install --upgrade virtualenv
rmdir venv /s /q
virtualenv venv
venv\Scripts\activate.bat
REM Install mingwpy gcc
pip install -i https://pypi.anaconda.org/carlkl/simple mingwpy
REM Delete specs file to link to MSVCRT
bash -c "rm $(gcc --print-file specs)"
gcc -dumpspecs
cd OpenBLAS
git checkout %BUILD_COMMIT%
git clean -fxd
git reset --hard
set LIBNAME_SUFFIX=%BUILD_COMMIT%_mingwpy
make BINARY=%PYTHON_ARCH% DYNAMIC_ARCH=1 USE_THREAD=1 USE_OPENMP=0 ^
     NUM_THREADS=24 NO_WARMUP=1 NO_AFFINITY=1 CONSISTENT_FPCSR=1 ^
     BUILD_LAPACK_DEPRECATED=1 MAX_STACK_ALLOC=2048
make PREFIX=%BUILD_ROOT%\%PYTHON_ARCH% install
cd %BUILD_ROOT%
tar zcvf openblas_%PYTHON_ARCH%.tar.gz %PYTHON_ARCH%
