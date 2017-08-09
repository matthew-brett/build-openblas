# Build 32-bit gfortran binary against OpenBLAS
cd $(dirname "${BASH_SOURCE[0]}")
OBP=$(cygpath $OPENBLAS_ROOT\\$BUILD_BITS)
OBP=$(cygpath $OPENBLAS_ROOT\\$BUILD_BITS)
gfortran -I $OBP/include -o test.exe test.f90 \
    $OBP/lib/libopenblas_${OPENBLAS_COMMIT}_$OPENBLAS_SUFFIX.a
./test
