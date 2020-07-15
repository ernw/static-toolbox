$allArgs = $PsBoundParameters.Values + $args
$env:NMAPDIR = "data"
.\nmap.exe $allArgs
