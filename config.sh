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


CWD=$(pwd)


REQUIREMENTS=(gcc g++ patch sed wget make tar ar ranlib ld)

for r in $REQUIREMENTS
do
   if [ -z $(which $r) ]; then
      echo "\"${r}\" is required. Please install \"${r}\" in your system. Exit 1"
      exit 1
   fi
done



echo "select a new (non-existing) directory: "
read value

if [ -e $value ]; then
   echo "this is a not valid non-existing directory. Exit 1"
   exit 1
fi



CWD=$(pwd)

mkdir -p $value
cp -R scripts $value
mkdir $value/builds
mkdir $value/src
mkdir $value/gcc-deps
mkdir $value/64
cp UPDATE.sh $value/scripts

cd $value
INSTALL_DIR=$(pwd)

cd ${INSTALL_DIR}/scripts


for script in $(ls)
do
    sed -i "s,CROSSMINGW_SYSROOT=,CROSSMINGW_SYSROOT=${INSTALL_DIR}," $script
done


sed -i "s,GIT_REPO=,GIT_REPO=${CWD}," UPDATE.sh

cd $CWD
echo "script system installed ($INSTALL_DIR)"
