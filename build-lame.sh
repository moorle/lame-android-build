#!/bin/sh

NDK_ROOT=/Users/lanshon/Runtime/Android/android-sdk-macosx/ndk-bundle

ANDROID_API_VERSION=15
NDK_TOOLCHAIN_ABI_VERSION=4.8

ABIS="armeabi armeabi-v7a arm64-v8a x86 x86_64 mips mips64"

TOOLCHAINS=`pwd`/"toolchains"
TOOLCHAINS_PREFIX="arm-linux-androideabi"
TOOLCHAINS_PATH=${TOOLCHAINS}/bin
SYSROOT=${TOOLCHAINS}/sysroot

CFLAGS="${CFLAGS} --sysroot=${SYSROOT} -I${SYSROOT}/usr/include -I${TOOLCHAINS}/include"
CPPFLAGS="${CFLAGS}"
LDFLAGS="${LDFLAGS} -L${SYSROOT}/usr/lib -L${TOOLCHAINS}/lib"

CWD=`pwd`

# directories
SOURCE="lame"
FAT="fat-lame"

SCRATCH="scratch-lame"
# must be an absolute path
THIN=$CWD/"thin-lame"

ARCH_PREFIX="armeabi"

function make_standalone_toolchain()
{
  echo "make standalone toolchain --arch=$1 --api=$2 --install-dir=$3"
  rm -rf ${TOOLCHAINS}

  $NDK_ROOT/build/tools/make_standalone_toolchain.py \
  --arch=$1 \
  --api=$2 \
  --install-dir=$3
}

function export_vars()
{
    export TOOLCHAINS
    export TOOLCHAINS_PREFIX
    export TOOLCHAINS_PATH
    export SYSROOT

    export CPP=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-cpp
    export AR=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-ar
    export AS=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-as
    export NM=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-nm
    export CC=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-gcc
    export CXX=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-g++
    export LD=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-ld
    export RANLIB=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-ranlib
    export STRIP=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-strip
    export OBJDUMP=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-objdump
    export OBJCOPY=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-objcopy
    export ADDR2LINE=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-addr2line
    export READELF=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-readelf
    export SIZE=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-size
    export STRINGS=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-strings
    export ELFEDIT=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-elfedit
    export GCOV=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-gcov
    export GDB=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-gdb
    export GPROF=${TOOLCHAINS_PATH}/${TOOLCHAINS_PREFIX}-gprof
    
    # Don't mix up .pc files from your host and build target
    export PKG_CONFIG_PATH=${TOOLCHAINS}/lib/pkgconfig
    
    export CFLAGS
    export CPPFLAGS
    export LDFLAGS
}

function configure_make_install()
{
    CC=$CC $CWD/$SOURCE/configure \
		    --enable-static \
            --disable-shared \
            --disable-frontend \
            --host=$TOOLCHAINS_PREFIX \
		    --prefix="$THIN/$ARCH_PREFIX"
    export CC
    make -j8 install

}
for ABI in $ABIS
do
    echo "building $ABI..."
    mkdir -p "$SCRATCH/$ABI"
    cd "$SCRATCH/$ABI"

    if [ $ABI = "armeabi" ]
    then
        CFLAGS="${CFLAGS} -D__ANDROID_API__=$ANDROID_API_VERSION"
        make_standalone_toolchain arm $ANDROID_API_VERSION ${TOOLCHAINS}
        TOOLCHAINS_PREFIX=arm-linux-androideabi
        ARCH_PREFIX=$ABI
        export_vars
        configure_make_install
    elif [ $ABI = "armeabi-v7a" ]
    then
        CFLAGS="${CFLAGS} -D__ANDROID_API__=$ANDROID_API_VERSION"
        make_standalone_toolchain arm $ANDROID_API_VERSION ${TOOLCHAINS}
        TOOLCHAINS_PREFIX=arm-linux-androideabi
        ARCH_PREFIX=$ABI
        export_vars
        configure_make_install
    elif [ $ABI = "arm64-v8a" ]
    then
        ANDROID_API_VERSION=21
        CFLAGS="${CFLAGS} -D__ANDROID_API__=$ANDROID_API_VERSION"
        make_standalone_toolchain arm64 $ANDROID_API_VERSION ${TOOLCHAINS}
        TOOLCHAINS_PREFIX=aarch64-linux-android
        ARCH_PREFIX=$ABI
        export_vars
        configure_make_install
    elif [ $ABI = "x86" ]
    then
        CFLAGS="${CFLAGS} -D__ANDROID_API__=$ANDROID_API_VERSION"
        make_standalone_toolchain x86 $ANDROID_API_VERSION ${TOOLCHAINS}
        TOOLCHAINS_PREFIX=i686-linux-android
        ARCH_PREFIX=$ABI
        export_vars
        configure_make_install
    elif [ $ABI = "x86_64" ]
    then
        ANDROID_API_VERSION=21
        CFLAGS="${CFLAGS} -D__ANDROID_API__=$ANDROID_API_VERSION"
        make_standalone_toolchain x86_64 $ANDROID_API_VERSION ${TOOLCHAINS}
        TOOLCHAINS_PREFIX=x86_64-linux-android
        ARCH_PREFIX=$ABI
        export_vars
        configure_make_install
    elif [ $ABI = "mips" ]
    then
        ANDROID_API_VERSION=21
        CFLAGS="${CFLAGS} -D__ANDROID_API__=$ANDROID_API_VERSION"
        make_standalone_toolchain mips $ANDROID_API_VERSION ${TOOLCHAINS}
        TOOLCHAINS_PREFIX=mipsel-linux-android
        ARCH_PREFIX=$ABI
        export_vars
        configure_make_install
    elif [ $ABI = "mips64" ]
    then
        ANDROID_API_VERSION=21
        CFLAGS="${CFLAGS} -D__ANDROID_API__=$ANDROID_API_VERSION"
        make_standalone_toolchain mips64 $ANDROID_API_VERSION ${TOOLCHAINS}
        TOOLCHAINS_PREFIX=mips64el-linux-android
        ARCH_PREFIX=$ABI
        export_vars
        configure_make_install
    else
        echo $ABI
    fi

    cd $CWD

done


