#!/bin/bash
# Build script for OpenBLAS on Windows
# Expects environment variables:
#  BUILD_ROOT
#  BUILD_COMMIT
#  VC9_ROOT

# Paths in Unix format
BUILD_ROOT=$(cygpath "$BUILD_ROOT")
VC9_ROOT=$(cygpath "$VC9_ROOT")

# Minimum utilities
pacman -Sy --noconfirm git
pacman -Rs --noconfirm gcc gcc-fortran
# Our directory for later copying
our_wd=$PWD
# Make output directory for build artifacts
rm -rf builds
mkdir builds
# Update OpenBLAS submodule
git submodule update --init --recursive
# Get bitness of Python
PYTHON_BITS=$(python -c "import platform; print(platform.architecture()[0][:2])")
# Install mingwpy gcc
pip install -i https://pypi.anaconda.org/carlkl/simple mingwpy
# Patch specs file
patch_file="${PWD}/specs.patch"
specs_dir=$(dirname $(gcc --print-file specs))
(cd $specs_dir && patch < $patch_file)
gcc -dumpspecs
cd OpenBLAS
git checkout $BUILD_COMMIT
git clean -fxd
git reset --hard
rm -rf $BUILD_ROOT/$PYTHON_BITS
if [ "$PYTHON_BITS" == 64 ]; then
    march="x86-64"
    vc_arch="X64"
else
    march=pentium4
    extra="-mfpmath=sse -msse2"
    vc_arch="i386"
fi
cflags="-O2 -march=$march -mtune=generic $extra"
fflags="$cflags -frecursive -ffpe-summary=invalid,zero"
export LIBNAMESUFFIX=${BUILD_COMMIT}_mingwpy
make BINARY=$PYTHON_BITS DYNAMIC_ARCH=1 USE_THREAD=1 USE_OPENMP=0 \
     NUM_THREADS=24 NO_WARMUP=1 NO_AFFINITY=1 CONSISTENT_FPCSR=1 \
     BUILD_LAPACK_DEPRECATED=1 \
     COMMON_OPT="$cflags" \
     FCOMMON_OPT="$fflags" \
     MAX_STACK_ALLOC=2048
make PREFIX=$BUILD_ROOT/$PYTHON_BITS install
DLL_BASENAME=libopenblas_${LIBNAMESUFFIX}
cd $BUILD_ROOT
# Copy library link file for custom name
cd $PYTHON_BITS/lib
# At least for the mingwpy wheel, we have to use the VC tools to build the
# export library. Maybe fixed in later binutils by patch referred to in
# https://sourceware.org/ml/binutils/2016-02/msg00002.html
cp ${our_wd}/OpenBLAS/exports/libopenblas.def ${DLL_BASENAME}.def
"$VC9_PATH/bin/lib.exe" /machine:${vc_arch} /def:${DLL_BASENAME}.def
cd ../..
# Build template site.cfg for using this build
cat > ${PYTHON_BITS}/site.cfg.template << EOF
[openblas]
libraries = $DLL_BASENAME
library_dirs = {openblas_root}\\${PYTHON_BITS}\\lib
include_dirs = {openblas_root}\\${PYTHON_BITS}\\include
EOF
TAR_NAME="openblas-${BUILD_COMMIT}_win${PYTHON_BITS}.tar.gz"
tar zcvf $TAR_NAME $PYTHON_BITS
cp $TAR_NAME $our_wd/builds
