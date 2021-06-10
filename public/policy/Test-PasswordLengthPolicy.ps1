function Test-PasswordLengthPolicy{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [BwCredential]$BwCredential,
        [int]$RequiredLength = 16,
        [string]$PolicyName = "PasswordLength"
    )
    begin{}
    process{
        $policyResult = $false
        $policyLength = $RequiredLength
        #Use policy exemption if it exists
        if($_.PolicyExemptions.ContainsKey($PolicyName)){
            Write-Verbose "Found $PolicyName key on '$($_.Name)'; applying policy test."
            try{
                #Try to parse the exemption length and use that
                $policyLength = [int]$_.PolicyExemptions[$PolicyName]
            }
            catch{
                #If unable to parse the length as int, then just use $RequiredLength
                Write-Warning -Message "Unable to parse policy; using global value."
            }
        }
        $policyResult = ($_.Password.Length -ge $policyLength) ? $true : $false

        $_.PolicyResults[$PolicyName] = $policyResult
        $_
    }
    end{}

}