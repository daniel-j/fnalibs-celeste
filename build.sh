#!/usr/bin/env bash

set -e

basedir="$(pwd)"
ARCH=$(uname -m)
export PREFIX="$basedir/prefix"
export PATH="$PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
FMOD_FILE="$basedir/fmodstudioapi11020linux.tar.gz"

FMOD_ARCH="$ARCH"

case "$ARCH" in
  i686)
    FMOD_ARCH="x86"
    ;;
  armv7l)
    FMOD_ARCH="armhf"
    ;;
esac

#rm -rf prefix
mkdir -p prefix

#Extract FMOD
#rm -rf lib/fmodstudioapi
mkdir -p lib/fmodstudioapi
tar xf "$FMOD_FILE" -C lib/fmodstudioapi --strip 1
install -v lib/fmodstudioapi/api/lowlevel/lib/$FMOD_ARCH/*.so* -t "$PREFIX/usr/local/lib"
install -v lib/fmodstudioapi/api/studio/lib/$FMOD_ARCH/*.so* -t "$PREFIX/usr/local/lib"

# Build FMOD_SDL
cd "$basedir/lib/FMOD_SDL"
ln -sfv -t . ../fmodstudioapi/api/lowlevel/inc/*.h ../fmodstudioapi/api/lowlevel/lib/$FMOD_ARCH/libfmod.so.10
make -j4
install -v ./libfmod_SDL.so -t "$PREFIX/usr/local/lib"

# Build SDL2
cd "$basedir/lib/SDL"
#rm -rf build
mkdir -p build
cd build
cmake -DCMAKE_PREFIX_PATH="$PREFIX" -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
make -j4
make DESTDIR="$PREFIX" install
cd "$basedir"

# Build SDL_image_compact
cd "$basedir/lib/SDL_image_compact"
make -j4
install -v ./libSDL2_image*.so* -t "$PREFIX/usr/local/lib"
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

# Build MojoShader
cd "$basedir/lib/MojoShader"
# rm -rf build
mkdir -p build
cd build
cmake -DCMAKE_PREFIX_PATH="$PREFIX" -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
make -j4
install -v ./libmojoshader.so -t "$PREFIX/usr/local/lib"
cd "$basedir"


mkdir -p fnalibs
cd "$PREFIX/usr/local/lib"
cp -v libSDL2-2.0.so.0 libSDL2_image-2.0.so.0 libmojoshader.so libfmod_SDL.so libfmod.so.10 libfmodstudio.so.10 "$basedir/fnalibs"
