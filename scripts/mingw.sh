#! /bin/bash

# MIT License
# 
# Copyright (c) 2019 Nobun
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


CROSSMINGW_SYSROOT=
ARCH_BITS=64
BUILD_MACHINE=x86_64-linux-gnu

ROOT_SRC_DIR=$CROSSMINGW_SYSROOT/src
ROOT_BUILD_DIR=$CROSSMINGW_SYSROOT/builds
INSTALL_DIR=$CROSSMINGW_SYSROOT/$ARCH_BITS


CWD=$(pwd)

# ---------------------------------------------------------------------------
#  DOWNLOAD ALL binutils, gcc, gcc-deps and mingw sources
# --------------------------------------------------------------------------

cd $ROOT_SRC_DIR
wget "https://gcc.gnu.org/pub/binutils/snapshots/binutils-2.31.90.tar.xz"
wget "https://gcc.gnu.org/pub/gcc/snapshots/LATEST-6/gcc-6-20181024.tar.xz"
wget "https://ftp.gnu.org/gnu/gmp/gmp-6.1.0.tar.bz2"
wget "https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz"
wget "https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.4.tar.bz2"
wget "https://www.mirrorservice.org/sites/sourceware.org/pub/pthreads-win32/pthreads-w32-2-9-1-release.tar.gz"
wget "https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v6.0.0.tar.bz2"


# extract all archives required to compile mingw toolchain except for pthreads-win32
# pthread-win32 will be extracted later directly in BUILD

tar xvf gmp-6.1.0.tar.bz2
tar xvf mpc-1.0.3.tar.gz
tar xvf mpfr-3.1.4.tar.bz2
tar xvf binutils-2.31.90.tar.xz
tar xvf gcc-6-20181024.tar.xz
tar xvf mingw-w64-v6.0.0.tar.bz2

mkdir gcc-deps
mv gmp-6.1.0 gcc-deps/gmp
mv mpc-1.0.3 gcc-deps/mpc
mv mpfr-3.1.4 gcc-deps/mpfr
mv binutils-2.31.90 binutils
mv gcc-6-20181024 gcc
mv mingw-w64-v6.0.0 mingw


# ---------------------------------------------------------------------------
#  compile GCC deps
# --------------------------------------------------------------------------

mkdir -p $ROOT_BUILD_DIR/gmp
mkdir -p $ROOT_BUILD_DIR/mpfr
mkdir -p $ROOT_BUILD_DIR/mpc

# 1) gmp
cd $ROOT_BUILD_DIR/gmp
${ROOT_SRC_DIR}/gcc-deps/gmp/configure \
--enable-static --disable-shared \
--prefix=${CROSSMINGW_SYSROOT}/gcc-deps
make 
make install 

# 2) mpfr
cd $ROOT_BUILD_DIR/mpfr
${ROOT_SRC_DIR}/gcc-deps/mpfr/configure \
--enable-static --disable-shared \
--prefix=${CROSSMINGW_SYSROOT}/gcc-deps \
--with-gmp-include=${CROSSMINGW_SYSROOT}/gcc-deps/include \
--with-gmp-lib=${CROSSMINGW_SYSROOT}/gcc-deps/lib
make
make install

# 3) mpc
cd $ROOT_BUILD_DIR/mpc
${ROOT_SRC_DIR}/gcc-deps/mpc/configure \
--enable-static --disable-shared \
--prefix=${CROSSMINGW_SYSROOT}/gcc-deps \
--with-gmp-include=${CROSSMINGW_SYSROOT}/gcc-deps/include \
--with-gmp-lib=${CROSSMINGW_SYSROOT}/gcc-deps/lib
make
make install


# ----------------------------------------------------------
#  compiling toolchain
# ----------------------------------------------------------


mkdir -p $ROOT_BUILD_DIR/binutils
mkdir -p $ROOT_BUILD_DIR/mingw-headers
mkdir -p $ROOT_BUILD_DIR/mingw-headers2
mkdir -p $ROOT_BUILD_DIR/gcc
mkdir -p $ROOT_BUILD_DIR/crt
mkdir -p $ROOT_BUILD_DIR/crt2
mkdir -p $ROOT_BUILD_DIR/mingw
mkdir -p $ROOT_BUILD_DIR/mingw2


# binutils

cd $ROOT_BUILD_DIR/binutils

${ROOT_SRC_DIR}/binutils/configure --target=x86_64-w64-mingw32 --disable-multilib --with-sysroot=$INSTALL_DIR --prefix=$INSTALL_DIR
make
make install

export PATH="$PATH:$INSTALL_DIR/bin"

CWD=$(pwd)


# mingw-headers (install to /)

cd $ROOT_BUILD_DIR/mingw-headers

${ROOT_SRC_DIR}/mingw/mingw-w64-headers/configure --build=$BUILD_MACHINE --host=x86_64-w64-mingw32 \
--prefix=$INSTALL_DIR

make 
make install 


# mingw-headers (install to /x86_64-w64-mingw32)

cd $ROOT_BUILD_DIR/mingw-headers2

${ROOT_SRC_DIR}/mingw/mingw-w64-headers/configure --build=$BUILD_MACHINE --host=x86_64-w64-mingw32 \
--prefix=$INSTALL_DIR/x86_64-w64-mingw32

make 
make install 


ln -s $INSTALL_DIR/x86_64-w64-mingw32 $INSTALL_DIR/mingw
mkdir -p $INSTALL_DIR/x86_64-w64-mingw32/lib
ln -s $INSTALL_DIR/x86_64-w64-mingw32/lib $INSTALL_DIR/x86_64-w64-mingw32/lib64


# gcc (base build)

cd $ROOT_BUILD_DIR/gcc

${ROOT_SRC_DIR}/gcc/configure --target=x86_64-w64-mingw32 \
--disable-multilib --with-sysroot=$INSTALL_DIR --prefix=$INSTALL_DIR \
--with-gmp=$CROSSMINGW_SYSROOT/gcc-deps \
--enable-fully-dynamic-string --enable-shared \
--enable-languages=c,c++ --enable-libgomp \
--enable-libssp --with-host-libstdcxx="-lstdc++ -lsupc++" --enable-lto

make all-gcc
make install-gcc 


# mingw crt (/)

cd $ROOT_BUILD_DIR/crt

${ROOT_SRC_DIR}/mingw/mingw-w64-crt/configure --host=x86_64-w64-mingw32 \
--with-sysroot=$INSTALL_DIR --prefix=$INSTALL_DIR

make
make install


# mingw crt (/x86_64-w64-mingw32)

cd $ROOT_BUILD_DIR/crt2

${ROOT_SRC_DIR}/mingw/mingw-w64-crt/configure --host=x86_64-w64-mingw32 \
--with-sysroot=$INSTALL_DIR --prefix=$INSTALL_DIR/x86_64-w64-mingw32

make
make install


# gcc (libgcc)

cd $ROOT_BUILD_DIR/gcc

make all-target-libgcc
make install-target-libgcc

cd $CWD

# windows-pthread

cd ${ROOT_SRC_DIR}
tar xvf /home/user/programmi/windows/src/pthreads-w32-2-9-1-release.tar.gz
mv pthreads-w32-2-9-1-release ${ROOT_BUILD_DIR}/pthread
cd ${ROOT_BUILD_DIR}/pthread
make clean GC CROSS=x86_64-w64-mingw32-
cp pthreadGC2.dll ${INSTALL_DIR}/bin
cp pthreadGC2.dll ${INSTALL_DIR}/x86_64-w64-mingw32/lib/libpthread.a
cp pthread.h ${INSTALL_DIR}/x86_64-w64-mingw32/include
cp sched.h ${INSTALL_DIR}/x86_64-w64-mingw32/include
cp semaphore.h ${INSTALL_DIR}/x86_64-w64-mingw32/include
cp config.h ${INSTALL_DIR}/x86_64-w64-mingw32/include/pthread-config.h
sed -i "s,#include \"config.h\",#include \"pthread-config.h\",g" ${INSTALL_DIR}/x86_64-w64-mingw32/include/pthread.h


# gcc (finalize gcc)

cd $ROOT_BUILD_DIR/gcc
make
make install 


# mingw libs (/)

cd ${ROOT_BUILD_DIR}/mingw

${ROOT_SRC_DIR}/mingw/configure --host=x86_64-w64-mingw32 \
--with-sysroot=$INSTALL_DIR --prefix=$INSTALL_DIR \
--without-headers --without-crt \
--with-libraries=all --with-tools=all

make
make install


# mingw libs (/x86_64-w64-mingw32)

cd ${ROOT_BUILD_DIR}/mingw2

${ROOT_SRC_DIR}/mingw/configure --host=x86_64-w64-mingw32 \
--with-sysroot=$INSTALL_DIR --prefix=$INSTALL_DIR/x86_64-w64-mingw32 \
--without-headers --without-crt \
--with-libraries=all --with-tools=all

make
make install

echo " "
echo " "
echo "Build finished. Now you can remove all sub-directories created in \"src\" and \"build\""
echo ""

