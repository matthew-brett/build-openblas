# Build 32-bit gfortran binary against OpenBLAS
cd $(dirname "${BASH_SOURCE[0]}")
OBP=$(cygpath $OPENBLAS_ROOT\\$PYTHON_ARCH)
OBP=$(cygpath $OPENBLAS_ROOT\\$PYTHON_ARCH)
gfortran -I $OBP/include -o test.exe test.f90 \
    $OBP/lib/libopenblas_${OPENBLAS_COMMIT}_$OPENBLAS_SUFFIX.a
./test
