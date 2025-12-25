param([string]$Message = "Initial commit to windows-mac branch")

# Create new branch windows-mac
git checkout -b windows-mac

# Add all changes
git add .

# Commit with provided message or default
git commit -m $Message