$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = "Stop"
$appDir = "C:\Users\prakash\BUSINNESS\smart_attendance_app"
Set-Location $appDir

$flutterExists = Get-Command "flutter" -ErrorAction SilentlyContinue

if (-not $flutterExists -and -not (Test-Path "$appDir\flutter_sdk\flutter\bin\flutter.bat")) {
    if (-not (Test-Path "flutter.zip")) {
        Write-Host "Fetching latest Flutter SDK URL..."
        $json = Invoke-RestMethod -Uri "https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json"
        $latestHash = $json.current_release.stable
        $latestRelease = $json.releases | Where-Object { $_.hash -eq $latestHash } | Select-Object -First 1
        $url = "https://storage.googleapis.com/flutter_infra_release/releases/" + $latestRelease.archive

        Write-Host "Downloading Flutter SDK from $url (This is ~1GB and may take 5-10 minutes)..."
        Invoke-WebRequest -Uri $url -OutFile "flutter.zip"
    } else {
        Write-Host "Found existing flutter.zip, skipping download..."
    }

    Write-Host "Extracting Flutter SDK (this will take a few minutes)..."
    New-Item -ItemType Directory -Force -Path "flutter_sdk" | Out-Null
    tar -xf flutter.zip -C flutter_sdk
    
    Write-Host "Cleaning up downloaded zip..."
    Remove-Item "flutter.zip" -Force
}

if ($flutterExists) {
    $script = "echo Starting Flutter Setup... && flutter config --no-analytics && flutter pub get && echo Launching App in Web Browser... && flutter run -d chrome"
} else {
    $flutterBin = "$appDir\flutter_sdk\flutter\bin"
    $script = "set PATH=%PATH%;$flutterBin && echo Starting Flutter Setup... && flutter config --no-analytics && flutter pub get && echo Launching App in Web Browser... && flutter run -d chrome"
}

Write-Host "Starting app in a new command window..."
Start-Process cmd -ArgumentList "/k `"$script`""
