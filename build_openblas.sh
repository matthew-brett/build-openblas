#!/bin/bash
# Build script for OpenBLAS on Windows
# Expects environment variables:
#  OPENBLAS_ROOT
#  OPENBLAS_COMMIT
cd $(dirname "${BASH_SOURCE[0]}")

# Paths in Unix format
BUILD_ROOT=$(cygpath "$OPENBLAS_ROOT")
cd OpenBLAS
git fetch origin
git checkout $OPENBLAS_COMMIT
git clean -fxd
git reset --hard
rm -rf $BUILD_ROOT/32
march=pentium4
extra="-mfpmath=sse -msse2"
vc_arch="i386"
cflags="-O2 -march=$march -mtune=generic $extra"
fflags="$cflags -frecursive -ffpe-summary=invalid,zero"
export LIBNAMESUFFIX=${OPENBLAS_COMMIT}_vanilla
make BINARY=32 DYNAMIC_ARCH=1 USE_THREAD=1 USE_OPENMP=0 \
     NUM_THREADS=24 NO_WARMUP=1 NO_AFFINITY=1 CONSISTENT_FPCSR=1 \
     BUILD_LAPACK_DEPRECATED=1 \
     COMMON_OPT="$cflags" \
     FCOMMON_OPT="$fflags" \
     MAX_STACK_ALLOC=2048
make PREFIX=$BUILD_ROOT/32 install
cd $BUILD_ROOT
ZIP_NAME="openblas-${BUILD_COMMIT}_win32.zip"
zip -r $ZIP_NAME $PYTHON_BITS
cp $ZIP_NAME $our_wd
