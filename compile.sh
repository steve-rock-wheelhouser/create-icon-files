#!/bin/bash
set -e

# Error trap to provide visibility if the build script itself fails
handle_error() {
    echo "!!! BUILD FAILED at line $1 !!!"
    exit 1
}
trap 'handle_error $LINENO' ERR

echo "--- Setting up Compilation Environment ---"
source .venv/bin/activate

# Ensure compiler tools are installed
pip install nuitka patchelf

echo "--- Cleaning previous builds ---"
rm -rf build

# Locate system libcairo for bundling
CAIRO_LIB=$(ldconfig -p | grep libcairo.so.2 | head -n 1 | awk '{print $NF}')
if [ -z "$CAIRO_LIB" ]; then
    echo "Error: Could not find libcairo.so.2 using ldconfig."
    exit 1
fi
echo "Found system libcairo at: $CAIRO_LIB"

echo "--- Compiling with Nuitka ---"
# Switching to --standalone mode.
# --onefile with PySide6 + CairoSVG often causes segmentation faults on Linux due to 
# complex shared library loading in temporary directories.
# --include-data-dir: Bundles the assets folder inside the executable

python3 -m nuitka --standalone --enable-plugin=pyside6 \
    --include-package=cairosvg \
    --include-package=cairocffi \
    --include-data-file="$CAIRO_LIB=libcairo.so.2" \
    --jobs=$(nproc) \
    --output-dir=build \
    --output-filename=create_icon_files.bin \
    --include-data-dir=assets=assets \
    --include-qt-plugins=platforms,iconengines,imageformats \
    --linux-icon=assets/icons/icon.png \
    create_icon_files.py

:<<'COMMENT'
python3 -m nuitka --standalone --enable-plugin=pyside6 \
    --jobs=$(nproc) \
    --output-dir=build \
    --output-filename=create_icon_files.bin \
    --include-package=cairosvg \
    --include-package=cairocffi \
    --include-data-file="$CAIRO_LIB=libcairo.so.2" \
    --include-data-dir=assets=assets \
    --include-qt-plugins=platforms,iconengines,imageformats \
    --noinclude-dll=libwayland-client.so.0 \
    --noinclude-dll=libwayland-cursor.so.0 \
    --noinclude-dll=libwayland-egl.so.1 \
    --noinclude-dll=libstdc++.so.6 \
    --noinclude-dll=libglib-2.0.so.0 \
    --noinclude-dll=libgthread-2.0.so.0 \
    --noinclude-dll=libfreetype.so.6 \
    --noinclude-dll=libfontconfig.so.1 \
    --linux-icon=assets/icons/icon.png \
    create_icon_files.py
COMMENT

BINARY_PATH="build/create_icon_files.dist/create_icon_files.bin"

echo "--- Success! Build complete. ---"
echo "Binary location: $BINARY_PATH"

echo "--- Verifying Shared Libraries (ldd) ---"
ldd "$BINARY_PATH"
if ldd "$BINARY_PATH" | grep "not found"; then
    echo "WARNING: Some shared libraries are missing. This may cause a crash."
else
    echo "Library dependencies look OK."
fi

echo "--- Checking for bundled Cairo libraries ---"
find build -name "*cairo*" || echo "WARNING: No cairo libraries found in build directory!"

echo "--- Running post-compilation steps ---"
# Make the binary executable
chmod +x "$BINARY_PATH"

echo "--- Executing Binary (DEBUG_MODE=1, QT_DEBUG_PLUGINS=1) ---"
# Disable the ERR trap so we can handle the crash manually
trap - ERR

if ! DEBUG_MODE=1 QT_DEBUG_PLUGINS=1 "$BINARY_PATH"; then
    echo "----------------------------------------------------------------"
    echo "!!! BINARY CRASHED !!!"
    echo "----------------------------------------------------------------"
    
    echo "--- DIAGNOSTIC: Library Load Trace (LD_DEBUG=libs) ---"
    echo "Running with LD_DEBUG=libs to identify the library causing the crash..."
    LD_DEBUG=libs "$BINARY_PATH" > ld_debug.log 2>&1 || true
    echo ">>> Last 30 lines of ld_debug.log (The last library mentioned is likely the culprit):"
    tail -n 30 ld_debug.log
    echo "----------------------------------------------------------------"

    if command -v gdb &> /dev/null; then
        echo "--- Capturing Stack Trace with GDB ---"
        gdb -batch -ex "run" -ex "bt" --args "$BINARY_PATH"
    else
        echo "GDB not found. Install 'gdb' to see the crash backtrace."
        echo "Fedora: sudo dnf install gdb | Ubuntu: sudo apt install gdb"
    fi
    exit 1
fi
