# Compile script for Windows using PyInstaller

Set-Location $PSScriptRoot

Write-Host "--- Setting up PyInstaller Environment ---"
& "C:\Users\floyd\miniconda3\Scripts\activate.ps1" create_icon_files

Write-Host "--- Cleaning previous builds ---"
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }

Write-Host "--- Building with PyInstaller ---"
pyinstaller --noconfirm --onefile --windowed `
    --name "create_icon_files" `
    --icon "..\assets\icons\icon.png" `
    --add-data "..\assets;assets" `
    --add-binary "C:\Users\floyd\miniconda3\Library\bin\cairo.dll;." `
    --hidden-import "cairosvg" `
    --hidden-import "cairocffi" `
    --collect-all "cairosvg" `
    --collect-all "cairocffi" `
    "..\create_icon_files.py"

Write-Host "--- Success! Binary created: dist\create_icon_files.exe ---"