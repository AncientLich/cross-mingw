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
GIT_REPO=

SCRIPT_DIR=$CROSSMINGW_SYSROOT/scripts
GIT_SCRIPT_DIR=$GIT_REPO/scripts

CWD=$(pwd)


if [ ${SCRIPT_DIR}/UPDATE.sh -ot $GIT_REPO/upd/UPDATE.sh ]; then
   cp $GIT_REPO/upd/UPDATE.sh ${SCRIPT_DIR}/.update.sh 
   cp $GIT_REPO/upd/upd2.sh ${SCRIPT_DIR}
   echo "UPDATE.sh must be updated. Please run \"bash upd2.sh\""
   cd $CWD
   exit 1
fi


cd ${GIT_SCRIPT_DIR}
for f in $(ls)
do
   if [ ${SCRIPT_DIR}/${f} -ot ${f} ]; then
      rm ${SCRIPT_DIR}/${f}
      cp $f ${SCRIPT_DIR}
      sed -i "s,CROSSMINGW_SYSROOT=,CROSSMINGW_SYSROOT=${CROSSMINGW_SYSROOT}," ${SCRIPT_DIR}/${f}
   elif [ ! -e ${SCRIPT_DIR}/${f} ]; then
      cp $f ${SCRIPT_DIR}
      sed -i "s,CROSSMINGW_SYSROOT=,CROSSMINGW_SYSROOT=${CROSSMINGW_SYSROOT}," ${SCRIPT_DIR}/${f}
   fi
done


cd $CWD

