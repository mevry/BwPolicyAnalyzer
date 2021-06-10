function Set-BwSessionToken{
    #check for bw cli tool
    if(-not (Get-Command bw -ErrorAction SilentlyContinue)){throw "bw not found, please install."}
    
    Write-Information -MessageData "[INFO] Setting `$env:BW_SESSION" -InformationAction Continue
    $env:BW_SESSION = bw unlock --raw
    Write-Information -MessageData "[INFO] Done" -InformationAction Continue
}