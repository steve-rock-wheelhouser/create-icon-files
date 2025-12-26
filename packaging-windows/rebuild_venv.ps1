# Rebuild virtual environment for Windows

Write-Host "--- Removing existing environment ---"
conda env remove -n create_icon_files -y

Write-Host "--- Creating new conda environment ---"
conda create -n create_icon_files python=3.13 -y

Write-Host "--- Activating environment and installing dependencies ---"
& "C:\Users\floyd\miniconda3\Scripts\activate.ps1" create_icon_files

conda install -c conda-forge cairo -y
conda install -c conda-forge pyside6 pillow cairosvg nuitka zstandard ordered-set pyinstaller -y