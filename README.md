# Build script for Celeste's dependencies on Raspberry Pi

## Usage

Either clone the repository recursively or run `git submodule update --init --recursive` after you have cloned it.

First, download FMOD Engine version 1.10.20 from [https://www.fmod.com/download](https://www.fmod.com/download). You need to create an account to download. Then navigate to the downloads page, click [FMOD Studio Suite](https://www.fmod.com/download#fmodstudiosuite) and under FMOD Engine click Older and select 1.10.20 in the dropdown. Then click Download on the line with Linux. Place the downloaded file at the root of this repository.

Install system dependencies package with `sudo apt install libsdl2-dev`

Now, run `./build.sh` and wait for it to complete.

This will create a file called `celeste-libarmhf.tar.gz`. Extract this in the Celeste game directory.

To play the game you need to install the Mono Runtime with `sudo apt install mono-runtime`

You can now launch the game by running `./Celeste.sh` from the game directory. Enjoy!
