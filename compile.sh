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
    --output-dir=build \
    --remove-output \
    create_icon_files.py

echo "Compilation complete. Binary is at build/create-icon-files.bin"