#!/bin/bash
set -e

echo "--- Installing Build Dependencies ---"
pip install -r requirements.txt

echo "--- Compiling with Nuitka ---"
mkdir -p build

# Compile to a standalone binary
# Note: We use --standalone instead of --onefile for faster startup and easier asset management in RPMs
python3 -m nuitka --standalone --onefile \
    --enable-plugin=pyside6 \
    --include-module=shutil \
    --output-filename=create-icon-files.bin \
    --jobs=$(nproc) \
    --output-dir=build \
    --remove-output \
    create_icon_files.py

# Copy assets to build directory so the binary can find them when run locally
echo "--- Copying assets to build directory ---"
cp -r assets build/

echo "Compilation complete. Binary is at build/create-icon-files.bin"