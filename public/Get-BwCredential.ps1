function Get-BwCredential{
    [cmdletbinding()]
    param(
        [Parameter(ParameterSetName = 'CollectionName')]
        [string]$CollectionName
    )
    #check for bw cli tool
    if(-not (Get-Command bw -ErrorAction SilentlyContinue)){throw "bw not found, please install."}
    #check to see if $env:BW_SESSION has been set
    if(-not (Test-Path "Env:BW_SESSION")){
        throw "`$env:BW_SESSION does not exist. Run Set-BwSessionToken."
    }
    Write-Information -MessageData "[INFO] Syncing from server" -InformationAction Continue
    bw sync | Write-Host
    if ($CollectionName){
        try{
            #Search for collection
            Write-Information "[INFO] Searching for '$CollectionName'" -InformationAction Continue
            $collections = Get-BwCollectionByName -CollectionName $CollectionName
            $collectionId = $collections.id
            $passwords = bw list items --collectionid=$collectionId | ConvertFrom-Json
        }
        catch{
            #Exit script if none is found
            Write-Error $Error[0]
            exit
        }
    }
    else{
        $collections = bw list collections | ConvertFrom-Json
        $passwords = bw list items | ConvertFrom-Json
    }

    Write-Information -MessageData "[INFO] Mapping passwords to collections." -InformationAction Continue
    $passwords | Where-Object type -ne 2 | ForEach-Object{
        $collectionId = $_.collectionIds[0]
        $collectionName = $collections | Where-Object {$_.id -match $collectionId} | Select-Object -expand name
        $credentialObject = [BwCredential]::new(
                $collectionName,
                $_.name,
                $_.login.username,
                $_.login.password,
                $_.notes,
                $_.fields
            )

        $credentialObject
    }

}