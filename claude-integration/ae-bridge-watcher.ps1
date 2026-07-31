Add-Content "C:\Users\DELL\claude-tools\watcher-log.txt" "$(Get-Date -Format HH:mm:ss.fff) WATCHER STARTING v4"
try {
$dir = "C:\Users\DELL\claude-tools\ae-bridge"
$fsw = New-Object System.IO.FileSystemWatcher
$fsw.Path = $dir
$fsw.Filter = "ae_command.json"
$types = [System.IO.WatcherChangeTypes]::Changed -bor [System.IO.WatcherChangeTypes]::Created -bor [System.IO.WatcherChangeTypes]::Renamed
$ae = "C:\Program Files\Adobe\Adobe After Effects 2024\Support Files\AfterFX.exe"
$tick = "C:\Users\DELL\claude-tools\tick2.jsx"
while ($true) {
  $r = $fsw.WaitForChanged($types, 2000)
  $fire = $false
  if (-not $r.TimedOut) { $fire = $true }
  else {
    try {
      $cmd = (Get-Content "$dir\ae_command.json" -Raw -ErrorAction Stop) | ConvertFrom-Json
      $res = Get-Content "$dir\ae_mcp_result.json" -Raw -ErrorAction SilentlyContinue
      if ($cmd.commandId -and (-not $res -or $res -notlike ("*" + $cmd.commandId + "*"))) { $fire = $true }
    } catch {}
  }
  if ($fire) {
    if (Get-Process AfterFX -ErrorAction SilentlyContinue) {
      Start-Sleep -Milliseconds 150
      Start-Process -FilePath $ae -ArgumentList @("-r", $tick) -WindowStyle Hidden
      Add-Content "C:\Users\DELL\claude-tools\watcher-log.txt" "$(Get-Date -Format HH:mm:ss.fff) fired"
      Start-Sleep -Milliseconds 900
    } else {
      Start-Sleep -Seconds 10
    }
  }
}
} catch { Add-Content "C:\Users\DELL\claude-tools\watcher-log.txt" "FATAL: $_" }
