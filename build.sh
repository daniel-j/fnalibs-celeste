#!/usr/bin/env bash

set -e

git submodule update --init --recursive

basedir="$(pwd)"
ARCH=$(uname -m)
export PREFIX="$basedir/prefix"
export PATH="$PREFIX/usr/local/bin:$PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
FMOD_FILE="$basedir/fmodstudioapi11020linux.tar.gz"

FMOD_ARCH="$ARCH"
LIB_ARCH="lib$ARCH"

case "$ARCH" in
  i686)
    FMOD_ARCH="x86"
    LIB_ARCH="lib"
    ;;
  armv7l)
    FMOD_ARCH="armhf"
    LIB_ARCH="libarmhf"
    ;;
  x86_64)
    LIB_ARCH="lib64"
    ;;
esac

# rm -rf prefix
mkdir -p prefix/usr/local/lib

## Build Mono
# echo ">> Building Mono"
# cd "$basedir/lib/mono"
# ./autogen.sh --prefix="$PREFIX"
# make -j4
# make install

## Build MonoKickstart
# echo ">> Building MonoKickstart"
# cd "$basedir/lib/MonoKickstart"
# # rm -rf build
# mkdir -p build
# cd build
# cmake -DCMAKE_PREFIX_PATH="$PREFIX" -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
# make -j4
# mv kick.bin.* kick.bin.$ARCH || true
# patchelf --set-rpath "\$ORIGIN/$LIB_ARCH" kick.bin.$ARCH
# install -v kick.bin.$ARCH -t "$PREFIX/usr/local/bin"

## Build SDL2
echo ">> Building SDL2..."
cd "$basedir/lib/SDL"
rm -rf build
mkdir -p build
cd build
cmake -DCMAKE_PREFIX_PATH="$PREFIX" -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX/usr/local" -DSDL2_PREFIX="$PREFIX" -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
make -j4
make install
cd "$basedir"

## Build SDL_image_compact
# echo ">> Building SDL_image_compact"
# cd "$basedir/lib/SDL_image_compact"
# make -j4
# install -v ./libSDL2_image*.so* -t "$PREFIX/usr/local/lib"
# cd "$basedir"

## Extract FMOD
echo ">> Extracting FMOD..."
rm -rf lib/fmodstudioapi
mkdir -p lib/fmodstudioapi
tar xf "$FMOD_FILE" -C lib/fmodstudioapi --strip 1
install -v lib/fmodstudioapi/api/lowlevel/lib/$FMOD_ARCH/* -t "$PREFIX/usr/local/lib"
install -v lib/fmodstudioapi/api/studio/lib/$FMOD_ARCH/* -t "$PREFIX/usr/local/lib"

## Build FMOD_SDL
echo ">> Building FMOD_SDL..."
cd "$basedir/lib/FMOD_SDL"
ln -sfv -t . ../fmodstudioapi/api/lowlevel/inc/* ../fmodstudioapi/api/lowlevel/lib/$FMOD_ARCH/libfmod.so.10
make FMOD_VERSION=10 -j4
install -v ./libfmod_SDL.so -t "$PREFIX/usr/local/lib"
cd "$basedir"

# Build FAudio
# cd "$basedir/lib/FAudio"
# # rm -rf build
# mkdir -p build
# cd build
# cmake -DCMAKE_PREFIX_PATH="$PREFIX" -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
# make -j4
# make DESTDIR="$PREFIX" install
# cd "$basedir"

# Build FNA3D
echo ">> Building FNA3D"
cd "$basedir/lib/FNA3D"
# rm -rf build
mkdir -p build
cd build
cmake -DCMAKE_PREFIX_PATH="$PREFIX" -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
make -j4
install -v ./libFNA3D.so* -t "$PREFIX/usr/local/lib"
cd "$basedir"

echo ">> Copying libraries"
rm -rf build
mkdir -p build/$LIB_ARCH
cd "$PREFIX/usr/local/lib"
cp -v libSDL2-2.0.so.0 libFNA3D.so.0 libfmod_SDL.so libfmod.so.10 libfmodstudio.so.10 "$basedir/build/$LIB_ARCH"
# cd "$PREFIX/usr/local/bin"
# cp -v kick.bin.$ARCH "$basedir/build/Celeste.bin.$ARCH"
# cd "$PREFIX"
# cp -v ./etc/mono/config "$basedir/build/monoconfig"
# cp -v ./etc/mono/config "$basedir/build/monoconfig"
# cp -v ./etc/mono/4.0/machine.config "$basedir/build/monomachineconfig"
# cp -v ./lib/mono/4.5/mscorlib.dll "$basedir/build"

echo ">> Compressing package fnalibs-celeste-$LIB_ARCH.tar.gz"
cd "$basedir/build"
cp ../Celeste.sh .
tar czf ../fnalibs-celeste-$LIB_ARCH.tar.gz *
