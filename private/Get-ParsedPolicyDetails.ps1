function Get-ParsedPolicyDetails{
    [cmdletbinding()]
    param(
        [string]$Notes,
        [string]$PolicyName,
        [string]$SplitToken = ":",
        [string]$PolicyExemptionPattern = "(?:PolicyExemption|Policy Exemption)"
    )
    #Manually split on newline. PowerShell isn't doing this automatically for some reason
    $parseNewline = $Notes -split "`n"

    #If match for specified policy exemption, split on $SplitToken
    $matchPattern = "$PolicyExemptionPattern[ ]*$SplitToken[ ]*${PolicyName}[ ]*$SplitToken"
    if($parseNewline -match $matchPattern){
        $matched = $parseNewline | Select-String $matchPattern
        $splitNotes = $matched -split "$SplitToken"
        #retrieve policy details if not null
        $policyDetails = $splitNotes[2] ?? ""
    }

    return $policyDetails ? $policyDetails.Trim() : ""

}