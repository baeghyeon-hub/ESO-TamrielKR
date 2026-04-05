$ErrorActionPreference = "Stop"

$sourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$targetRoot = Join-Path $HOME "Documents\\Elder Scrolls Online\\live\\AddOns"

# -- TamrielKR (addon files live at repo root) --
$tamrielKRTarget = Join-Path $targetRoot "TamrielKR"
if (-not (Test-Path $tamrielKRTarget)) {
    New-Item -ItemType Directory -Path $tamrielKRTarget -Force | Out-Null
}

$tamrielKRFiles = @(
    "Core.lua", "Fonts.lua", "Skills.lua",
    "GuildRoster.lua", "UI.lua", "TamrielKR.lua",
    "TamrielKR.txt", "TamrielKR.xml",
    "backupfont_kr.xml", "fontstrings.xml"
)
foreach ($file in $tamrielKRFiles) {
    Copy-Item -Path (Join-Path $sourceRoot $file) -Destination $tamrielKRTarget -Force
}

$tamrielKRDirs = @("fonts", "flags")
foreach ($dir in $tamrielKRDirs) {
    $src = Join-Path $sourceRoot $dir
    $dst = Join-Path $tamrielKRTarget $dir
    if (-not (Test-Path $dst)) {
        New-Item -ItemType Directory -Path $dst -Force | Out-Null
    }
    Copy-Item -Path (Join-Path $src "*") -Destination $dst -Recurse -Force
}
Write-Host "Synced TamrielKR -> $tamrielKRTarget"

# -- Other packages (subdirectories) --
$packages = @("TamrielKR_Bridge", "EsoUI", "gamedata")
foreach ($package in $packages) {
    $sourcePath = Join-Path $sourceRoot $package
    $targetPath = Join-Path $targetRoot $package

    if (-not (Test-Path $sourcePath)) {
        throw "Missing source package: $sourcePath"
    }

    if (-not (Test-Path $targetPath)) {
        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    }

    Copy-Item -Path (Join-Path $sourcePath "*") -Destination $targetPath -Recurse -Force
    Write-Host "Synced $package -> $targetPath"
}

# -- TTC $(language) compat patch --
$ttcPath = Join-Path $targetRoot "TamrielTradeCentre"
if (Test-Path $ttcPath) {
    $lookupEN = Join-Path $ttcPath "ItemLookUpTable_EN.lua"
    $lookupKR = Join-Path $ttcPath "ItemLookUpTable_kr.lua"
    if (Test-Path $lookupEN) {
        Copy-Item -Path $lookupEN -Destination $lookupKR -Force
    }

    $langEN = Join-Path $ttcPath "lang\en.lua"
    $langKR = Join-Path $ttcPath "lang\kr.lua"
    if ((Test-Path $langEN) -and (-not (Test-Path $langKR))) {
        Copy-Item -Path $langEN -Destination $langKR -Force
        Write-Host "Created TTC lang\\kr.lua from en.lua"
    } elseif (Test-Path $langKR) {
        Write-Host "Preserved existing TTC lang\\kr.lua"
    }

    Write-Host "Patched TamrielTradeCentre for kr"
}

Write-Host "Done."
