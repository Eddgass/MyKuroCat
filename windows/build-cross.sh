#!/usr/bin/env bash
# Cross-compile KuroCat.exe on Linux/macOS with MinGW-w64, no Windows machine required.
# Debian/Ubuntu: sudo apt install g++-mingw-w64-x86-64
set -euo pipefail

cd "$(dirname "$0")"

PREFIX="${MINGW_PREFIX:-x86_64-w64-mingw32}"
CXX="${CXX:-${PREFIX}-g++}"
WINDRES="${WINDRES:-${PREFIX}-windres}"

if ! command -v "$CXX" >/dev/null 2>&1; then
    echo "[ERROR] $CXX not found."
    echo "Install the MinGW-w64 cross toolchain, e.g. sudo apt install g++-mingw-w64-x86-64"
    exit 1
fi

echo "==> Cross-compiling KuroCat.exe (Windows x64) with $CXX..."

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

EXTRA_INPUTS=()
if command -v "$WINDRES" >/dev/null 2>&1; then
    # Resource id 1 / type 24 is RT_MANIFEST: same effect as MSVC's /MANIFEST:EMBED.
    printf '1 24 "%s/app.manifest"\n' "$PWD" > "$TMP_DIR/app.manifest.rc"
    "$WINDRES" -O coff -o "$TMP_DIR/app.manifest.o" "$TMP_DIR/app.manifest.rc"
    EXTRA_INPUTS=("$TMP_DIR/app.manifest.o")
else
    echo "==> [WARN] $WINDRES not found, building without the DPI-awareness manifest"
fi

# WINVER/_WIN32_WINNT 0x0A00 exposes SetProcessDpiAwarenessContext used by main.cpp.
"$CXX" -std=c++17 -O2 -mwindows -municode -static -s \
    -ffunction-sections -fdata-sections -Wl,--gc-sections \
    -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00 \
    src/main.cpp ${EXTRA_INPUTS[@]+"${EXTRA_INPUTS[@]}"} -o KuroCat.exe \
    -luser32 -lgdi32 -lgdiplus -lshell32 -ladvapi32 -lwinhttp -lwtsapi32

echo "==> Built successfully: $PWD/KuroCat.exe"
