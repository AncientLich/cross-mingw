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

# This script will build qt5 installing those components:
# qtbase, qtimageformats, qttranslations, qtmultimedia

# the first time you compile it, a qtbase.tar.gz file 
# will be created in /src. qtbase.tar.gz stores the starting qmake build created by
# ./configure and it will allow you to save a bunch of time if you need
# to run again a configure from a blank directory.
# extracting qtbase.tar.gz in a new directory and running configure from there
# will allow you to save a bit of time (configure will skip qmake build step)


CROSSMINGW_SYSROOT=
ARCH_BITS=64
QT5_VERSION=5.13.0
QT5_SRC_NAME=qt-everywhere-src-${QT5_VERSION}
QT5_SRC_EXT=tar.xz

ROOT_SRC_DIR=$CROSSMINGW_SYSROOT/src
ROOT_BUILD_DIR=$CROSSMINGW_SYSROOT/builds
INSTALL_DIR=$CROSSMINGW_SYSROOT/$ARCH_BITS

export PATH="$PATH:$INSTALL_DIR/bin"


CWD=$(pwd)

mkdir -p $ROOT_BUILD_DIR/qt5
cd $ROOT_BUILD_DIR/qt5

if [[ -f "$ROOT_BUILD_DIR/qtbase.tar.gz" ]]; then
    tar xvf $ROOT_BUILD_DIR/qtbase.tar.gz
    QTBASE_READY=1
else
    QTBASE_READY=0
fi

cd ${ROOT_SRC_DIR}
wget "http://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/5.13/5.13.0/single/qt-everywhere-src-5.13.0.tar.xz"
wget "https://martchus.no-ip.biz/gogs/Martchus/PKGBUILDs/raw/master/qt5-multimedia/mingw-w64/0003-Link-directshow-plugin-against-libamstrmid.patch"
mv 0003-Link-directshow-plugin-against-libamstrmid.patch qt5-001.patch
tar xvf ${ROOT_SRC_DIR}/${QT5_SRC_NAME}.${QT5_SRC_EXT}
cd ${QT5_SRC_NAME}/qtmultimedia
patch -p 1 -i ${ROOT_SRC_DIR}/qt5-001.patch

cd $ROOT_BUILD_DIR/qt5

# installed:
# qtmultimedia, qttranslations, qtimageformats, qtbase

${ROOT_SRC_DIR}/${QT5_SRC_NAME}/configure \
-xplatform win32-g++ \
-device-option CROSS_COMPILE=x86_64-w64-mingw32- \
-prefix ${INSTALL_DIR} \
-opensource \
-release -shared -strip \
-nomake tests \
-nomake examples \
-confirm-license \
-no-opengl \
-skip qtactiveqt -skip qtcharts -skip qtdoc -skip qtlocation \
-skip qtremoteobjects -skip qtserialbus -skip qtwebchannel \
-skip qtwebview -skip qtandroidextras -skip qtconnectivity \
-skip qtgamepad -skip qtmacextras -skip qtpurchasing -skip qtscript \
-skip qtwebengine -skip qtwinextras \
-skip qtdatavis3d -skip qtgraphicaleffects \
-skip qtquickcontrols -skip qtscxml -skip qtspeech \
-skip qtvirtualkeyboard -skip qtwebglplugin -skip qtx11extras \
-skip qt3d -skip qtcanvas3d -skip qtdeclarative \
-skip qtnetworkauth -skip qtquickcontrols2 \
-skip qtsensors -skip qtwayland -skip qtwebsockets -skip qtxmlpatterns \
-skip qtserialport -skip qtsvg -skip qttools -skip qtlottie \
-D_POSIX_C_SOURCE


if [[ $QTBASE_READY -eq 0 ]]; then
    tar czvf qtbase.tar.gz qtbase
    mv qtbase.tar.gz $ROOT_BUILD_DIR/qtbase.tar.gz
fi


make -j 2
make install


cd $CWD

