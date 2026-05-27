$ErrorActionPreference = "Stop"
$appDir = "C:\Users\prakash\BUSINNESS\smart_attendance_app"
Set-Location $appDir

$flutterExists = Get-Command "flutter" -ErrorAction SilentlyContinue

if ($flutterExists) {
    $script = "echo Starting Firebase linking... && dart pub global activate flutterfire_cli && set PATH=%PATH%;%USERPROFILE%\AppData\Local\Pub\Cache\bin && flutterfire configure"
} else {
    $flutterBin = "$appDir\flutter_sdk\flutter\bin"
    $script = "set PATH=%PATH%;$flutterBin && echo Starting Firebase linking... && dart pub global activate flutterfire_cli && set PATH=%PATH%;%USERPROFILE%\AppData\Local\Pub\Cache\bin && flutterfire configure"
}

Write-Host "Opening a new interactive window for Firebase setup..."
Start-Process cmd -ArgumentList "/k `"$script`""
