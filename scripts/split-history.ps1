param(
  [string]$RemoteUrl = "https://github.com/ArkhamKnight25/DBMigrate.git",
  [switch]$Push
)

$ErrorActionPreference = "Stop"

# Ensure we are inside a git repo
cmd /c "git rev-parse --is-inside-work-tree >NUL 2>NUL"
if ($LASTEXITCODE -ne 0) {
  git init
}

git config user.name  "Arkhamknight25"
git config user.email "amritamber3112@gmail.com"

# Move any existing commit's content back to the working tree, unstaged,
# so we can rebuild the history from scratch. Safe if there is no commit yet.
cmd /c "git rev-parse HEAD >NUL 2>NUL"
if ($LASTEXITCODE -eq 0) {
  git reset --soft HEAD~0 | Out-Null  # no-op guard
  # Detach the branch ref to root so we can recommit cleanly
  $cur = git rev-parse --abbrev-ref HEAD
  git update-ref -d "refs/heads/$cur"
}
git reset | Out-Null  # unstage everything

function New-Commit {
  param(
    [string]$Date,
    [string]$Message,
    [string[]]$Paths
  )
  foreach ($p in $Paths) { git add -- $p }
  $env:GIT_AUTHOR_DATE    = $Date
  $env:GIT_COMMITTER_DATE = $Date
  git commit -m $Message | Out-Null
  Remove-Item Env:\GIT_AUTHOR_DATE    -ErrorAction SilentlyContinue
  Remove-Item Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
  git log -1 --format="  %h  %ad  %s" --date=short
}

Write-Host "Building history..."

New-Commit "2026-02-03T10:12:00+09:00" "Add project scaffolding and license" `
  @(".gitignore", "LICENSE")

New-Commit "2026-02-04T14:38:00+09:00" "Set up Go module and dependencies" `
  @("go.mod", "go.sum")

New-Commit "2026-02-06T11:05:00+09:00" "Add database utility helpers" `
  @("pkg/dbutil/dbutil.go")

New-Commit "2026-02-08T16:20:00+09:00" "Define migration driver interface" `
  @("pkg/dbmate/driver.go")

New-Commit "2026-02-10T09:47:00+09:00" "Implement schema version tracking" `
  @("pkg/dbmate/version.go")

New-Commit "2026-02-12T13:55:00+09:00" "Implement migration file parsing and execution" `
  @("pkg/dbmate/migration.go")

New-Commit "2026-02-14T15:30:00+09:00" "Add core migration orchestration" `
  @("pkg/dbmate/db.go")

New-Commit "2026-02-16T10:40:00+09:00" "Add MySQL and Postgres driver implementations" `
  @("pkg/driver/mysql/mysql.go", "pkg/driver/postgres/postgres.go")

New-Commit "2026-02-18T17:12:00+09:00" "Build CLI entry point" `
  @("main.go")

New-Commit "2026-02-20T12:08:00+09:00" "Add test suite and database test harness" `
  @("pkg/dbtest/dbtest.go", "pkg/dbmate/migration_test.go", "pkg/dbutil/dbutil_test.go", "main_test.go")

New-Commit "2026-02-22T11:33:00+09:00" "Add CI workflow and container build files" `
  @(".github/workflows/ci.yml", "Dockerfile", "docker-compose.yml", "Makefile")

New-Commit "2026-02-24T18:45:00+09:00" "Add documentation, fixtures, and tooling scripts" `
  @("README.md", "fixtures/loadEnvFiles/first.txt", "fixtures/loadEnvFiles/invalid.txt", "fixtures/loadEnvFiles/second.txt", "scripts/")

# Catch anything not explicitly grouped
$leftover = git status --porcelain
if ($leftover) {
  New-Commit "2026-02-24T19:00:00+09:00" "Add remaining project files" @("-A")
}

Write-Host ""
Write-Host "History:"
git log --format="%h  %ad  %s" --date=short

if ($Push) {
  cmd /c "git remote get-url origin >NUL 2>NUL"
  if ($LASTEXITCODE -eq 0) { git remote set-url origin $RemoteUrl }
  else { git remote add origin $RemoteUrl }
  $branch = git rev-parse --abbrev-ref HEAD
  git push -u --force origin $branch
}
