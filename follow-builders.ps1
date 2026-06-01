param(
    [Parameter(Position = 0)]
    [ValidateSet("help", "update-submodule", "npm-install", "setup")]
    [string]$Command = "help"
)

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
$SubmodulePath = Join-Path $RepoRoot "submodules\zarazhangrui-follow-builders"
$ScriptsPath = Join-Path $SubmodulePath "scripts"

function Show-Help {
    Write-Host "Follow Builders shortcut"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\follow-builders.ps1 update-submodule  Update/init the zarazhangrui follow-builders submodule"
    Write-Host "  .\follow-builders.ps1 npm-install       Run npm install under the submodule scripts directory"
    Write-Host "  .\follow-builders.ps1 setup             Update submodule, then run npm install"
    Write-Host "  .\follow-builders.ps1 help              Show this help"
}

function Assert-CommandExists {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

function Update-FollowBuildersSubmodule {
    Assert-CommandExists "git"

    Push-Location $RepoRoot
    try {
        git submodule update --init --recursive submodules/zarazhangrui-follow-builders
        git submodule update --remote --merge submodules/zarazhangrui-follow-builders
    }
    finally {
        Pop-Location
    }
}

function Install-FollowBuildersDependencies {
    Assert-CommandExists "npm"

    if (-not (Test-Path $ScriptsPath)) {
        throw "Submodule scripts directory was not found: $ScriptsPath. Run '.\follow-builders.ps1 update-submodule' first."
    }

    Push-Location $ScriptsPath
    try {
        npm install
    }
    finally {
        Pop-Location
    }
}

switch ($Command) {
    "help" {
        Show-Help
    }
    "update-submodule" {
        Update-FollowBuildersSubmodule
    }
    "npm-install" {
        Install-FollowBuildersDependencies
    }
    "setup" {
        Update-FollowBuildersSubmodule
        Install-FollowBuildersDependencies
    }
}
