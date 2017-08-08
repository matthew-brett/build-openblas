# Build 32-bit gfortran binary against OpenBLAS
pacman -Sy mingw-w64-i686-toolchain
OBP=$(cygpath $OPENBLAS_ROOT\\$PYTHON_ARCH)
gfortran -I $OPB/include -o test.exe test.f90 \
    $OPB/lib/libopenblas_$OPENBLAS_COMMIT_mingwpy.a
