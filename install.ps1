#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Version = "latest",

    [string]$InstallDir = $(if ($env:LAN_REMOTE_INSTALL) { $env:LAN_REMOTE_INSTALL } elseif ($IsWindows) { Join-Path $env:LOCALAPPDATA "Programs\lan_remote\bin" } else { "/usr/local/bin" })
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Repo = "StanleyMasinde/LAN-remote"
$BinaryName = "lan_remote"

function Get-Platform {
    $os = if ($IsWindows) {
        "windows"
    } elseif ($IsMacOS) {
        "macos"
    } elseif ($IsLinux) {
        "linux"
    } else {
        throw "Unsupported OS"
    }

    $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    $archName = switch ($arch) {
        ([System.Runtime.InteropServices.Architecture]::X64) { "x86_64"; break }
        ([System.Runtime.InteropServices.Architecture]::Arm64) { "arm64"; break }
        default { throw "Unsupported architecture: $arch" }
    }

    return "${os}-${archName}"
}

function Get-ReleaseData([string]$RequestedVersion) {
    if ($RequestedVersion -eq "latest") {
        $url = "https://api.github.com/repos/$Repo/releases/latest"
    } else {
        $url = "https://api.github.com/repos/$Repo/releases/tags/$RequestedVersion"
    }

    try {
        return Invoke-RestMethod -Uri $url -Method Get
    } catch {
        throw "Could not fetch release data from $url. $($_.Exception.Message)"
    }
}

function Get-AssetInfo($Release, [string]$FileName) {
    $asset = $Release.assets | Where-Object { $_.name -eq $FileName } | Select-Object -First 1
    if (-not $asset) {
        return $null
    }

    $sha = $null
    if ($asset.PSObject.Properties.Name -contains "digest" -and $asset.digest) {
        if ($asset.digest -match '^sha256:(.+)$') {
            $sha = $Matches[1]
        }
    }

    [pscustomobject]@{
        Url    = $asset.browser_download_url
        Sha256 = $sha
    }
}

function Verify-Checksum([string]$FilePath, [string]$ExpectedSha) {
    if ([string]::IsNullOrWhiteSpace($ExpectedSha)) {
        Write-Host "Warning: No checksum available for this release asset"
        Write-Host "Skipping verification"
        return
    }

    Write-Host "Verifying checksum..."
    $actual = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $expected = $ExpectedSha.ToLowerInvariant()

    if ($actual -ne $expected) {
        throw "Checksum verification failed. Expected: $expected Got: $actual"
    }

    Write-Host "Checksum verified: $ExpectedSha"
}

function Ensure-PathContains([string]$Dir) {
    if (-not $IsWindows) {
        return
    }

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = @()
    if ($userPath) {
        $parts = $userPath -split ';'
    }

    $normalized = $Dir.TrimEnd('\\')
    $alreadyPresent = $parts | Where-Object { $_.TrimEnd('\\') -ieq $normalized }
    if ($alreadyPresent) {
        return
    }

    $newPath = if ([string]::IsNullOrWhiteSpace($userPath)) { $Dir } else { "$userPath;$Dir" }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Added to user PATH: $Dir"
    Write-Host "Open a new terminal session for PATH changes to take effect."
}

function Install-LanRemote([string]$RequestedVersion) {
    $platform = Get-Platform
    $ext = if ($platform.StartsWith("windows-")) { "zip" } else { "tar.gz" }

    Write-Host "LAN Remote Installer"
    Write-Host ""
    Write-Host "Fetching release information..."

    $release = Get-ReleaseData -RequestedVersion $RequestedVersion
    $resolvedVersion = $release.tag_name
    if ([string]::IsNullOrWhiteSpace($resolvedVersion)) {
        throw "Could not parse version from API response"
    }

    $fileName = "$BinaryName-$platform-$resolvedVersion.$ext"

    Write-Host "Version:  $resolvedVersion"
    Write-Host "Platform: $platform"
    Write-Host "Asset:    $fileName"
    Write-Host ""

    $asset = Get-AssetInfo -Release $release -FileName $fileName
    if (-not $asset) {
        Write-Error "Could not find asset '$fileName' in release"
        Write-Host ""
        Write-Host "Available assets for this release:"
        $release.assets | ForEach-Object { Write-Host "  - $($_.name)" }
        exit 1
    }

    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tmpDir | Out-Null

    try {
        $archivePath = Join-Path $tmpDir $fileName
        Write-Host "Downloading from: $($asset.Url)"
        Invoke-WebRequest -Uri $asset.Url -OutFile $archivePath

        Write-Host ""
        Verify-Checksum -FilePath $archivePath -ExpectedSha $asset.Sha256
        Write-Host ""

        Write-Host "Extracting..."
        Expand-Archive -Path $archivePath -DestinationPath $tmpDir -Force

        $binaryFile = if ($platform.StartsWith("windows-")) { "$BinaryName.exe" } else { $BinaryName }
        $sourceBinary = Join-Path $tmpDir $binaryFile
        if (-not (Test-Path $sourceBinary)) {
            throw "Binary '$binaryFile' not found after extraction"
        }

        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        $targetBinary = Join-Path $InstallDir $binaryFile

        Write-Host "Installing to $InstallDir..."
        Copy-Item -Path $sourceBinary -Destination $targetBinary -Force

        if (-not $IsWindows) {
            & chmod +x $targetBinary
        } else {
            Ensure-PathContains -Dir $InstallDir
        }

        Write-Host ""
        Write-Host "Installed: $targetBinary"
        Write-Host "Run '$binaryFile --help' to get started"
        if ($IsWindows) {
            Write-Host "On Windows, open a fresh PowerShell or CMD before running '$binaryFile --help'."
        }
    }
    finally {
        if (Test-Path $tmpDir) {
            Remove-Item -Path $tmpDir -Recurse -Force
        }
    }
}

if ($Version -in @("-h", "--help")) {
    @"
LAN Remote Installer (PowerShell)

Usage:
  irm https://raw.githubusercontent.com/$Repo/main/install.ps1 | iex

Or with specific version:
  irm https://raw.githubusercontent.com/$Repo/main/install.ps1 | iex; install.ps1 v1.0.0

Parameters:
  -Version      Release tag (default: latest)
  -InstallDir   Installation directory

Environment Variables:
  LAN_REMOTE_INSTALL    Installation directory override

Supported Platforms:
  - Linux (x86_64, arm64)
  - macOS (x86_64, arm64)
  - Windows (x86_64, arm64)

Notes:
  - Downloads assets named like: lan_remote-<platform>-<arch>-<tag>.<ext>
  - Adds InstallDir to User PATH on Windows if missing
"@ | Write-Host
    exit 0
}

Install-LanRemote -RequestedVersion $Version
