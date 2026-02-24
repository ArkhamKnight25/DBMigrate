param(
  [string]$Message = "Build database migration CLI from scratch",
  [string]$CommitDate = "2026-02-15T12:00:00+09:00",
  [string]$RemoteUrl = "https://github.com/ArkhamKnight25/DBMigrate.git",
  [switch]$Push
)

$ErrorActionPreference = "Stop"

# Detect git repo without letting git's stderr escalate to a terminating error
$insideWorkTree = $false
cmd /c "git rev-parse --is-inside-work-tree >NUL 2>NUL"
if ($LASTEXITCODE -eq 0) {
  $insideWorkTree = $true
}

if (-not $insideWorkTree) {
  git init
}

if (-not (git config user.name)) {
  git config user.name "ArkhamKnight25"
}

if (-not (git config user.email)) {
  git config user.email "arkhamknight25@example.com"
}

git add -A

$status = git status --porcelain
if (-not $status) {
  Write-Host "No changes to commit."
} else {
  $env:GIT_AUTHOR_DATE = $CommitDate
  $env:GIT_COMMITTER_DATE = $CommitDate

  git commit -m $Message

  Remove-Item Env:\GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
  Remove-Item Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}

git log -1 --format="Committed %h on %ad: %s" --date=iso-strict

if ($Push) {
  # Ensure remote 'origin' points at the target repo
  cmd /c "git remote get-url origin >NUL 2>NUL"
  if ($LASTEXITCODE -eq 0) {
    git remote set-url origin $RemoteUrl
  } else {
    git remote add origin $RemoteUrl
  }

  $branch = git rev-parse --abbrev-ref HEAD
  git push -u origin $branch
}
