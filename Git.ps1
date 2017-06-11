$ErrorActionPreference = "Stop"

# Get correct location
$dir = Read-Host "Enter project path (eg. C:\..\proj)"


# Validate path
$validPath = Test-Path "$dir"

if ($validPath -like "False") {
    Read-Host "Path doesn't exist, press enter to exit"
    Exit-PSSession
} else {
    Write-Host "The path is valid" -ForegroundColor Magenta
    cd "$dir"
}

git status -s #show staus
git add --all #add items
git status -s #show status again

$commitMsg = Read-Host "Enter the commit message"
git commit -m "$commitMsg"
git push -u origin master


