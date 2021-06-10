function Get-ReusedPassword{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [BwCredential]$BwCredential,
        [switch]$SanitizeOutput
    )
    begin{
        $passwordDictionary = @{}
        if($SanitizeOutput){
            $passwordIdCounter = 1
        }
    }
    process{

        $password = $BwCredential.Password

        if ($passwordDictionary[$password]){
            ($passwordDictionary[$password]).Add($_)
        }
        else{
            $BwCredentialList = New-Object System.Collections.Generic.LinkedList[BwCredential]
            $BwCredentialList.Add($_)
            $passwordDictionary.Add($password, $BwCredentialList)
        }
    }
    end{
        #Changes passwords to sanitized placeholder values (for grouping purposes)
        if($SanitizeOutput){
            $dictKeys = $passwordDictionary.GetEnumerator() | Select-Object -ExpandProperty Name 
            $dictKeys | ForEach-Object{
                $passwordDictionary["Password${passwordIdCounter}"] = $passwordDictionary[$_]
                $passwordDictionary.Remove($_)
                $passwordIdCounter += 1
            }
        }
        $passwordDictionary.GetEnumerator() | Where-Object {$_.Value.Count -gt 1} | Sort-Object -Property @{e={$_.Value.Count}} -Descending | `
        #Each dictionary entry
        ForEach-Object {
            $password = $_.Key
            $reuseCount = $_.Value.Count
            #Each list in dictionary
            $_.Value | ForEach-Object{
                $ReusedCredential = [PSCustomObject]@{
                    PSTypeName = "ReusedCredential"
                    ReuseCount = $reuseCount
                    Password = $password
                    CollectionID = $_.Collection
                    Name = $_.Name 
                    Username = $_.Username
                }
                $ReusedCredential
            }
        }
    }
}