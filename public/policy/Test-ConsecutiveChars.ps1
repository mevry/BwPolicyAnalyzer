function Test-ConsecutiveChars{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [BwCredential]$BwCredential,
        [string]$PolicyBaseName = "ConsecutiveChars",
        [int]$AllowedConsecutiveChars = 4,
        [ValidateSet("Mixed","Upper","Lower")]
        [string]$Case = "Mixed"
    )
    begin{}
    process{
        $PolicyName = "${PolicyBaseName}${Case}"
        $policyLength = $AllowedConsecutiveChars
        
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
        
        switch ($Case) {
            "Mixed" { $pattern = "[A-Za-z]{$($policyLength+1),}" }
            "Upper" { $pattern = "[A-Z]{$($policyLength+1),}" }
            "Lower" { $pattern = "[a-z]{$($policyLength+1),}" }
        }
        Write-Verbose "Using Pattern: $pattern"
        $_.PolicyResults[$PolicyName] = [regex]::Matches($_.Password,$pattern).value
        $_
    }
    end{}
}