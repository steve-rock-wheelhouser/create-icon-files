#!/bin/bash
set -e

# Automatically activate the virtual environment if it exists
if [ -f ".venv/bin/activate" ]; then
    echo "--- Activating .venv ---"
    source .venv/bin/activate
fi

echo "--- Installing Build Dependencies ---"
pip install -r requirements.txt

# Check for patchelf, which is required by Nuitka on Linux
if ! command -v patchelf &> /dev/null; then
    echo "patchelf not found in PATH. Checking common locations..."
    
    # Check Python bin dir (venv or system)
    PYTHON_BIN=$(python3 -c 'import sys, os; print(os.path.dirname(sys.executable))')
    if [ -x "$PYTHON_BIN/patchelf" ]; then
        echo "Found patchelf in $PYTHON_BIN. Adding to PATH."
        export PATH="$PYTHON_BIN:$PATH"
    elif [ -x "$HOME/.local/bin/patchelf" ]; then
        echo "Found patchelf in $HOME/.local/bin. Adding to PATH."
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "Error: 'patchelf' is required but not found."
        echo "Please install it using your system package manager (e.g., 'sudo apt install patchelf' or 'sudo dnf install patchelf')."
        exit 1
    fi
fi

# Check for ccache to speed up compilation
if command -v ccache &> /dev/null; then
    echo "--- ccache detected! Compilation will be accelerated. ---"
else
    echo "Warning: ccache not found. Install it to speed up future builds."
fi

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
    create_icon_files.py

# Copy assets to build directory so the binary can find them when run locally
echo "--- Copying assets to build directory ---"
cp -r assets build/

echo "Compilation complete. Binary is at build/create-icon-files.bin"