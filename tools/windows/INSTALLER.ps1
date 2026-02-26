#Requires -Version 5.0
param(
    [string]$InstallDir = "$env:LocalAppData\ManaoBot"
)

$ErrorActionPreference = "Stop"
$target = Join-Path $InstallDir "manao"
$versionFile = Join-Path $InstallDir "version.txt"
$isUpdate = Test-Path $target

# --- Header ---
if ($isUpdate) {
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host "   Manao Bot - Updater" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    $currentVersion = if (Test-Path $versionFile) { (Get-Content $versionFile -Raw).Trim() } else { "unknown" }
    Write-Host "Currently installed: $currentVersion"
} else {
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host "   Manao Bot - Installer" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
}

# --- Fetch releases from GitHub ---
Write-Host ""
Write-Host "Fetching available versions from GitHub..." -ForegroundColor Cyan
try {
    $releases = Invoke-RestMethod -Uri 'https://api.github.com/repos/tinarskii/manao/releases' -UseBasicParsing
} catch {
    Write-Host "ERROR: Could not fetch releases from GitHub: $_" -ForegroundColor Red
    exit 1
}

if (-not $releases -or $releases.Count -eq 0) {
    Write-Host "ERROR: No releases found." -ForegroundColor Red
    exit 1
}

# --- Let user pick a version ---
Write-Host ""
Write-Host "Available versions:" -ForegroundColor Yellow
for ($i = 0; $i -lt [Math]::Min($releases.Count, 10); $i++) {
    $tag = $releases[$i].tag_name
    $date = ([datetime]$releases[$i].published_at).ToString("yyyy-MM-dd")
    $marker = if ($i -eq 0) { " (latest)" } else { "" }
    Write-Host "  [$($i + 1)] $tag  --  $date$marker"
}

Write-Host ""
$choice = Read-Host "Enter version number to install (default: 1 for latest)"
if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

if ($choice -notmatch '^\d+$' -or [int]$choice -lt 1 -or [int]$choice -gt $releases.Count) {
    Write-Host "Invalid choice. Defaulting to latest." -ForegroundColor Yellow
    $choice = "1"
}

$selected = $releases[[int]$choice - 1]
$selectedVersion = $selected.tag_name

# --- Confirm if updating ---
if ($isUpdate) {
    if ($selectedVersion -eq $currentVersion) {
        Write-Host ""
        Write-Host "Version $selectedVersion is already installed." -ForegroundColor Green
        $confirm = Read-Host "Reinstall anyway? (y/n)"
        if ($confirm -ne 'y') {
            Write-Host "Cancelled." -ForegroundColor Yellow
            exit 0
        }
    } else {
        Write-Host ""
        Write-Host "You are about to update: $currentVersion -> $selectedVersion" -ForegroundColor Yellow
        $confirm = Read-Host "Continue? (y/n)"
        if ($confirm -ne 'y') {
            Write-Host "Cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
}

# --- Ensure install directory ---
try {
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
} catch {
    Write-Host "ERROR: Failed to create install directory: $_" -ForegroundColor Red
    exit 1
}

# --- Check / Install Git ---
try {
    git --version | Out-Null
    Write-Host "Git found." -ForegroundColor Green
} catch {
    Write-Host "Installing Git via winget..."
    winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements --silent
    $env:PATH = "$env:ProgramFiles\Git\cmd;$env:PATH"
}

# --- Clone or update repo ---
try {
    if ($isUpdate) {
        Write-Host ""
        Write-Host "Updating repository to $selectedVersion..." -ForegroundColor Cyan
        Set-Location $target
        git fetch --tags origin
        git checkout $selectedVersion
        git pull origin $selectedVersion
    } else {
        Write-Host ""
        Write-Host "Cloning repository at $selectedVersion..." -ForegroundColor Cyan
        git clone --branch $selectedVersion https://github.com/tinarskii/manao.git $target
        Set-Location $target
    }
    Write-Host "Repository ready." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Git operation failed: $_" -ForegroundColor Red
    exit 1
}

# --- Check / Install Bun ---
$env:PATH = "$env:USERPROFILE\.bun\bin;$env:PATH"
try {
    bun --version | Out-Null
    Write-Host "Bun found." -ForegroundColor Green
} catch {
    Write-Host "Installing Bun..."
    Invoke-WebRequest https://bun.sh/install.ps1 -OutFile install-bun.ps1 -UseBasicParsing
    powershell -ExecutionPolicy Bypass -File install-bun.ps1
    Remove-Item install-bun.ps1 -Force -ErrorAction SilentlyContinue
    $env:PATH = "$env:USERPROFILE\.bun\bin;$env:PATH"
}

# --- Check / Install Twitch CLI ---
try {
    twitch --version | Out-Null
    Write-Host "Twitch CLI found." -ForegroundColor Green
} catch {
    Write-Host "Installing Twitch CLI..."
    winget install -e --id Twitch.TwitchCLI --accept-package-agreements --accept-source-agreements --silent
}

# --- Install dependencies ---
try {
    Write-Host ""
    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    bun install
    Write-Host "Dependencies installed." -ForegroundColor Green
} catch {
    Write-Host "WARNING: Failed to install dependencies: $_" -ForegroundColor Yellow
}

# --- Set environment variable ---
[Environment]::SetEnvironmentVariable("MANAO_PATH", $target, "Machine")

# --- Write version file ---
$selectedVersion | Set-Content -Path $versionFile

# --- Done ---
Write-Host ""
Write-Host "==============================" -ForegroundColor Green
if ($isUpdate) {
    Write-Host "  Manao Bot updated to $selectedVersion" -ForegroundColor Green
} else {
    Write-Host "  Manao Bot installed ($selectedVersion)" -ForegroundColor Green
}
Write-Host "  Path: $target" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
exit 0