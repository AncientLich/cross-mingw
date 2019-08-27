# cross-mingw
Cross-mingw is a set of bash scripts (MIT licensed) 
that will build a mingw toolchain (for linux)  from source 
targeting 64-bit-only windows binaries.

## installing
Cross-mingw must not be used directly from the original git repository, but
must be "installed" elsewhere, in a non-existing directory where you don't need
root permissions (I would suggest a directory under your $HOME)

In order to install Cross-mingw run `bash config.sh` 
from the original git repository.

You will be asked to type there a non-existing directory.

### installing troubleshooting
Config.sh could not install anything raising an error

> X is required. Please install "X" in your system. Exit 1.

This error message means that a mandatory tool is missing.
If the missing tool is one of those:
 
 * gcc
 * g++ 
 * make 
 * ranlib 
 * ar
 * ld 

you probably require to install 'build-essential' or similar package 
(name can change depending of your linux distro).

other packages could be require a separate installation from your 
distro package manager

> this is a not valid non-existing directory. Exit 1

This error appears, after config.sh asked you a non-existing directory if the
path points to an existing file/directory/symlink.

Simply specify a non-existing directory the next time 
(eg. /home/account/something_new) and config.sh will create for you the 
directory "installing" cross-mingw there


### cross-mingw directory tree
When installed cross-mingw will create a sort of ecosystem (but not a jail),
structured in some folders:
 
 * 64 -> where 64-bit binaries will be installed
 * src -> where source archives will be downloaded (and sometimes extracted)
 * builds -> where intermediate compiled object (not installed) will be stored
 * scripts -> where the bash scripts wil be stored (and where you should execute them)
 * gcc-deps -> where gmp, mpc and mpfr binaries will be built (required by gcc to be compiled)


## using cross-mingw
after cross-mingw is installed in INSTALL_DIR you must execute scripts from the 
INSTALL_DIR/scripts with `bash scriptfile.sh`.

the first script to execute, before any other, is **mingw.sh**
this script will build the mingw toolchain.
You may require to manually edit the `BUILD_MACHINE` variable before running it.
BUILD_MACHINE is the name triplette of your host machine (in my case it is
x86_64-linux-gnu)

All the other scripts will compile a thing using the mingw toolchain created
by mingw.sh

There are other 2 special scripts: UPDATE.sh and upd2.sh

### UPDATE.sh
UPDATE.sh is the script that allows to update scripts aligning them to the 
newest changes found in the git repository from where you originally installed 
cross-mingw.
But UPDATE.sh cannot update itself if needed. In that special situation,
UPDATE.sh will notify you to use upd2.sh.

By default, upd2.sh is not available in your cross-mingw installation.
upd2.sh will be added in cross-mingw installation only when actually needed
if UPDATE.sh will ask you to use upd2.sh

that case, enter in INSTALL_DIR/scripts and run
`bash upd2.sh`
in order to update UPDATE.sh. UPDATE.sh script will be updated and upd2.sh 
will be removed again from cross-mingw installation.

## other scripts
All other non-mentioned scripts usually compile a specific library with a
specific configuration. Anyone of those scripts could require an 
additional dependency not checked during installation (which checks only
the requirements for installation and mingw.sh script)
