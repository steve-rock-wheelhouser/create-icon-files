param([string]$Message = "Update windows-mac branch")

# Find git
$git = Get-Command git -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $git) {
    $git = "C:\Program Files\Git\cmd\git.exe"
}

if (-not (Test-Path $git)) {
    Write-Error "Git not found. Please install Git or update the path in this script."
    exit 1
}

Write-Host "Using Git at: $git"

# Check current branch
$currentBranch = &$git rev-parse --abbrev-ref HEAD

if ($currentBranch -ne "windows-mac") {
    # Check if branch exists
    $branchExists = &$git branch --list windows-mac
    if ($branchExists) {
        Write-Host "Switching to existing branch windows-mac..."
        &$git checkout windows-mac
    } else {
        Write-Host "Creating and switching to new branch windows-mac..."
        &$git checkout -b windows-mac
    }
} else {
    Write-Host "Already on branch windows-mac."
}

# Add all changes
Write-Host "Adding changes..."
&$git add .

# Commit
Write-Host "Committing changes..."
&$git commit -m $Message

# Push
Write-Host "Pushing to origin..."
&$git push origin windows-mac
