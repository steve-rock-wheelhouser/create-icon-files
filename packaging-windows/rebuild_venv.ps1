# Rebuild virtual environment for Windows

Write-Host "--- Removing existing .venv ---"
if (Test-Path ".venv") { Remove-Item -Recurse -Force ".venv" }

Write-Host "--- Creating new .venv with Python ---"
# Assuming python is python.exe, or python3.13 if available
$pythonCmd = "python"
if (Get-Command "python3.13" -ErrorAction SilentlyContinue) {
    $pythonCmd = "python3.13"
} elseif (Get-Command "python3" -ErrorAction SilentlyContinue) {
    $pythonCmd = "python3"
}

& $pythonCmd -m venv .venv

Write-Host "--- Activating .venv and installing dependencies ---"
& ".venv\Scripts\activate.ps1"

pip install --upgrade pip
pip install -r "requirements-windows.txt"