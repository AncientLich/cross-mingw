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


# NSIS is compiled ONLY as terminal application for linux which uses the 
# offician NSIS build.
# unlike other tools, NSIS will be installed in CROSSMINGW_SYSROOT/nsis



CROSSMINGW_SYSROOT=
ARCH_BITS=64

ROOT_SRC_DIR=$CROSSMINGW_SYSROOT/src
ROOT_BUILD_DIR=$CROSSMINGW_SYSROOT/builds
INSTALL_DIR=$CROSSMINGW_SYSROOT/$ARCH_BITS


CWD=$(pwd)

REQUIREMENTS=(unzip scons)

for r in $REQUIREMENTS
do
   if [ -z $(which $r) ]; then
      echo "\"${r}\" is required. Please install \"${r}\" in your system. Exit 1"
      exit 1
   fi
done


cd $ROOT_SRC_DIR
wget https://downloads.sourceforge.net/project/nsis/NSIS%203/3.04/nsis-3.04.zip
wget https://downloads.sourceforge.net/project/nsis/NSIS%203/3.04/nsis-3.04-src.tar.bz2

unzip nsis-3.04.zip
tar xvf nsis-3.04-src.tar.bz2

mv nsis-3.04 $CROSSMINGW_SYSROOT/nsis
mv nsis-3.04-src $ROOT_BUILD_DIR/nsis

cd $ROOT_BUILD_DIR/nsis

scons SKIPSTUBS=all SKIPPLUGINS=all SKIPUTILS=all SKIPMISC=all \
NSIS_CONFIG_CONST_DATA_PATH=no PREFIX=$CROSSMINGW_SYSROOT/nsis \
install-compiler

# this will solve this bug -> Error initalizing CEXEBuild: error setting default stub
# moving the binary to Bin and placing a symlink in the root directory allows to
# run makensis also from root. Placing directly in the root (like the install did)
# it will generate the error
mv $CROSSMINGW_SYSROOT/nsis/makensis $CROSSMINGW_SYSROOT/nsis/Bin/makensis 
cd $CROSSMINGW_SYSROOT/nsis
ln -s Bin/makensis makensis

cd $CWD

echo " "
echo " "
echo "Build finished. Now you can remove \"src/nsis\" directory (and archives if you want)"
echo ""
