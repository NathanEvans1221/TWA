param (
    [string]$AppDirectory = "."
)

$ErrorActionPreference = "Stop"

# Resolve absolute path
$targetDir = Resolve-Path $AppDirectory
Write-Host "🚀 Starting Build Release Process in: $targetDir" -ForegroundColor Cyan

# Change to the target directory
Push-Location $targetDir

try {
    # Check if this is a bubblewrap project
    if (-not (Test-Path "twa-manifest.json")) {
        Write-Error "twa-manifest.json not found! Are you in the correct directory?"
    }

    # 1. Update Project (This resets gradle.properties)
    Write-Host "📦 Updating Bubblewrap Project..." -ForegroundColor Yellow
    # We use 'call' operator & to ensure exit codes are propagated correctly in some powershell contexts, 
    # though direct execution usually works.
    bubblewrap update
    if ($LASTEXITCODE -ne 0) {
        throw "Bubblewrap update failed!"
    }

    # 2. Fix Gradle Memory Issue
    $gradlePropsPath = "gradle.properties"
    Write-Host "🔧 Fixing Gradle Memory Settings in $gradlePropsPath..." -ForegroundColor Yellow

    if (Test-Path $gradlePropsPath) {
        $content = Get-Content $gradlePropsPath
        if ($content -match "org.gradle.jvmargs=-Xmx1536m") {
             $newContent = $content -replace "org.gradle.jvmargs=-Xmx1536m", "org.gradle.jvmargs=-Xmx512m"
             Set-Content -Path $gradlePropsPath -Value $newContent
             Write-Host "✅ Memory set to -Xmx512m" -ForegroundColor Green
        } else {
             Write-Host "ℹ️  Memory setting already adjusted or not found in expected format." -ForegroundColor Gray
        }
    } else {
        Write-Warning "gradle.properties not found! Skipping memory fix."
    }

    # 3. Build APK
    Write-Host "🔨 Building APK..." -ForegroundColor Yellow
    bubblewrap build
    if ($LASTEXITCODE -ne 0) {
        throw "Bubblewrap build failed!"
    }

    Write-Host "🎉 Build Completed Successfully!" -ForegroundColor Green

} catch {
    Write-Error $_.Exception.Message
} finally {
    Pop-Location
}
