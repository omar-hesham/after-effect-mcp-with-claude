$running = Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" | Where-Object { $_.CommandLine -like "*ae-bridge-watcher*" }
if (-not $running) { Start-Process powershell -ArgumentList "-NoProfile","-WindowStyle","Hidden","-ExecutionPolicy","Bypass","-File","C:\Users\DELL\claude-tools\ae-bridge-watcher.ps1" }
