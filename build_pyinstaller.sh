#!/bin/bash
set -e

echo "--- Setting up PyInstaller Environment ---"
source .venv/bin/activate
pip install pyinstaller

echo "--- Cleaning previous builds ---"
rm -rf build dist

echo "--- Building with PyInstaller ---"
# --onefile: Create a single executable
# --windowed: Do not show a console window when running
# --add-data: Bundle the assets folder (format is source:dest)
# --collect-all: Aggressively collect all files for cairo libraries to prevent missing imports
pyinstaller --noconfirm --onefile --windowed \
    --name "create_icon_files" \
    --icon "assets/icons/icon.png" \
    --add-data "assets:assets" \
    --hidden-import "cairosvg" \
    --hidden-import "cairocffi" \
    --collect-all "cairosvg" \
    --collect-all "cairocffi" \
    create_icon_files.py

echo "--- Success! Binary created: dist/create_icon_files ---"
