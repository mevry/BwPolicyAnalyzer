function Test-BannedWords{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [BwCredential]$BwCredential,
        [string]$PolicyName = "BannedWords",
        [string]$ConfigPath = "config\bannedWords.json"
    )
    begin{
        try{
            Write-Verbose "ConfigPath: $ConfigPath" 
            $WordPolicies = Get-Content $ConfigPath -ErrorAction Stop
            Write-Verbose "Converting from JSON"
            $WordPolicies = $WordPolicies | ConvertFrom-Json -ErrorAction Stop
        }
        catch{
            

            $Error[0].Message
            exit
        }
    }
    process{
        $credential = $_
        $policyFails = @()
        $policyExemptions = ($credential.PolicyExemptions[$PolicyName] -split ",").Trim()
        Write-Verbose "Comparing $($credential.name) to policies"
        foreach($policy in $WordPolicies){
            #if credential is exempt from policy, skip evaluation
            if($policy.WordPolicy -in $policyExemptions){
                continue
            }
            #If password matches a Regex, add the failed policy name
            if($credential.Password -match $policy.Regex){
                $policyFails += $policy.WordPolicy
            }
        }
        $credential.PolicyResults[$PolicyName] = $policyFails
        $credential
    }
    end{}
}