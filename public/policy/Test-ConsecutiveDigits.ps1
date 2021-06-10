function Test-ConsecutiveDigits{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [BwCredential]$BwCredential,
        [string]$PolicyName = "ConsecutiveDigits",
        [int]$ConsecutiveDigits = 3
    )
    begin{}
    process{   
        $policyLength = $ConsecutiveDigits
        
        #Use policy exemption if it exists
        if($_.PolicyExemptions.ContainsKey($PolicyName)){
            Write-Verbose "Found $PolicyName key on '$($_.Name)'; applying policy test."
            try{

                #Try to parse the exemption length and use that
                $policyLength = [int]$_.PolicyExemptions[$PolicyName]
                Write-Verbose "Applying policy: $PolicyName - $policyLength"
            }
            catch{
                #If unable to parse the length as int, then just use $ConsecutiveDigits
                Write-Warning -Message "Unable to parse policy; using global value."
            }
        }
        #Any digit 1 or more greater than the specified length
        $pattern = "\d{$($policyLength+1),}"
        $_.PolicyResults[$PolicyName] = [regex]::Matches($_.Password,$pattern).value
        $_
    }
    end{}
}