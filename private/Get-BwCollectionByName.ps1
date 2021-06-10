function Get-BwCollectionByName{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CollectionName
    )
    bw get collection $CollectionName | ConvertFrom-Json
    if (-not $?){
        throw "'$CollectionName' Not Found"
    }

}