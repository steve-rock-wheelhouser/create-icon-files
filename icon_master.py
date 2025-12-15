
#!/usr/bin/python3
# -*- coding: utf-8 -*-
# This script resizes an image using a graphical user interface and saves it as a PNG.
# It supports PNG, JPG, JPEG, TIFF, WEBP, AVIF, PDF, SVG, and BMP input formats.
# For PDF support, the 'poppler' library must be installed on the system.
# It uses the Pillow library for image processing and PySide6 for the GUI.
#
#
# Copyright (C) 2025 steve.rock@wheelhouser.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# --- Setup Instructions ---
# Active the venv on linux/macOS:
# python -m venv .venv
# source .venv/bin/activate
# pip install --upgrade pip
#
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# pip install -r requirements.txt
# pip install --force-reinstall -r requirements.txt
#
#===========================================================================================

import os
from PIL import Image
import cairosvg
import io
import argparse
import sys

def generate_icons(source_path, output_dir=None):
    if output_dir is None:
        output_dir = f"{os.path.splitext(source_path)[0]}_icons"

    # 1. Load the Image
    file_ext = os.path.splitext(source_path)[1].lower()
    
    if file_ext == '.svg':
        # Convert SVG to a high-res PNG in memory
        png_data = cairosvg.svg2png(url=source_path, output_width=1024, output_height=1024)
        master_img = Image.open(io.BytesIO(png_data))
    else:
        master_img = Image.open(source_path)
    
    # Ensure RGBA for transparency
    master_img = master_img.convert("RGBA")

    if master_img.width < 512 or master_img.height < 512:
        print(f"Warning: Input image is {master_img.width}x{master_img.height}. For best results, use an image at least 512x512.", file=sys.stderr)

    # Create output directory
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # --- LINUX (PNG Set) ---
    linux_sizes = [16, 24, 32, 48, 64, 96, 128, 256, 512]
    linux_dir = os.path.join(output_dir, 'linux')
    os.makedirs(linux_dir, exist_ok=True)
    
    for size in linux_sizes:
        # 1x
        img_resized = master_img.resize((size, size), Image.Resampling.LANCZOS)
        size_dir = os.path.join(linux_dir, f"{size}x{size}")
        os.makedirs(size_dir, exist_ok=True)
        img_resized.save(os.path.join(size_dir, 'icon.png'))

        # 2x
        img_2x = master_img.resize((size * 2, size * 2), Image.Resampling.LANCZOS)
        size_dir_2x = os.path.join(linux_dir, f"{size}x{size}@2x")
        os.makedirs(size_dir_2x, exist_ok=True)
        img_2x.save(os.path.join(size_dir_2x, 'icon.png'))
        
    print(f"Linux icons generated in {linux_dir}")

    # --- WINDOWS (.ico) ---
    win_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    # Pillow expects a sequence of images to embed in the ICO
    ico_images = []
    for w, h in win_sizes:
        ico_images.append(master_img.resize((w, h), Image.Resampling.LANCZOS))
        
    ico_path = os.path.join(output_dir, 'icon.ico')
    # Save the first image, appending the rest
    ico_images[0].save(ico_path, format='ICO', sizes=win_sizes, append_images=ico_images[1:])
    print(f"Windows icon generated: {ico_path}")

    # --- MACOS (.icns) ---
    # Pillow handles the internal structure of ICNS automatically if you provide the largest image
    # However, for best quality, we explicitly construct it or let Pillow downscale.
    # macOS requires specific sizes (16, 32, 128, 256, 512, 1024)
    # Note: Pillow's ICNS support is decent, but sometimes strict on input sizes.
    # The easiest way with Pillow is often passing the huge 1024x1024 image.
    
    icns_path = os.path.join(output_dir, 'icon.icns')
    # For ICNS, we typically just save the master if it is 1024x1024; 
    # Pillow will auto-generate the smaller mipmaps.
    if master_img.size != (1024, 1024):
         mac_master = master_img.resize((1024, 1024), Image.Resampling.LANCZOS)
    else:
         mac_master = master_img
         
    mac_master.save(icns_path, format='ICNS')
    print(f"macOS icon generated: {icns_path}")

# Example Usage
# generate_icons('my_logo.svg', './output_icons')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate icons for Linux, Windows, and macOS.")
    parser.add_argument("source", help="Path to the source image file")
    parser.add_argument("output_dir", nargs='?', help="Directory to save the generated icons")

    args = parser.parse_args()

    if not os.path.exists(args.source):
        print(f"Error: Source file '{args.source}' does not exist.", file=sys.stderr)
        sys.exit(1)

    generate_icons(args.source, args.output_dir)