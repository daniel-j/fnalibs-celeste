#!/usr/bin/env bash

# Uncomment this to use OpenGL ES 3
# export FNA_OPENGL_FORCE_ES3=1

# This enables fps and frametime overlay.
export GALLIUM_HUD=simple,frametime,fps

cd "${0%/*}"

rm -f mono_crash.*.json
rm -f error_log.txt

export LD_LIBRARY_PATH=libarmhf:$LD_LIBRARY_PATH
export DISPLAY=${DISPLAY:-:0}

# If you have gamemoderun installed
#exec gamemoderun mono ./Celeste.exe
exec mono Celeste.exe
