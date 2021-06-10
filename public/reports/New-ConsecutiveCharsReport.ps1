function New-ConsecutiveCharsReport{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [BwCredential]$BwCredential,
        [string]$Path = "ConsecutiveCharsReport_$(Get-Date -Format "yyyyMMdd_hhmm").xlsx",
        [string]$PolicyBaseName = "ConsecutiveChars",
        [ValidateSet("Mixed","Upper","Lower")]
        [string]$Case = "Mixed",
        [switch]$PassThru
    )
    begin{
        $consecutiveCharsTable = @()
        $PolicyName = "${PolicyBaseName}${Case}"
    }
    process{
        
        $policy = ""
        if ($_.PolicyExemptions.ContainsKey($PolicyName)){
            $policy = $_.PolicyExemptions[$PolicyName]
        }
        
        $consecutiveCharsTable += [PSCustomObject]@{
            Collection = $_.Collection
            Name = $_.name
            Username = $_.username
            PolicyMatches = ($_.PolicyResults[$PolicyName] -join ", ")
            PassedPolicy = (($_.PolicyResults[$PolicyName]) ? "FAIL" : "PASS")
            PolicyExemptions = $policy
            PolicyExemptionDetails = Get-ParsedPolicyDetails -PolicyName $PolicyName -Notes $_.Notes
            
        }
        if($PassThru){
            $_
        }
    }
    end{
        $failColor = New-ConditionalText -Text "FAIL" -Range "E:E" -ConditionalType "Equal"
        $passColor = New-ConditionalText  -Text "PASS" -ConditionalTextColor "DarkGreen" -BackgroundColor "LightGreen" -Range "E:E" -ConditionalType "Equal"

        #Create Worksheet
        $excel = $consecutiveCharsTable | `
            Export-Excel -AutoSize `
            -AutoFilter `
            -Path $Path `
            -WorksheetName $PolicyName `
            -TableName $PolicyName `
            -ConditionalText $failColor, $passColor `
            -PassThru

        #FORMATTING
        #Manually size the first two columns
        $excel.Workbook.Worksheets[$PolicyName].Column(1).width = 50
        $excel.Workbook.Worksheets[$PolicyName].Column(2).width = 50

        #Save and close
        $excel.Save()
        $excel.Dispose()

    }
}