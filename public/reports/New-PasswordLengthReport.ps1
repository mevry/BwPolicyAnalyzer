function New-PasswordLengthReport{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [BwCredential]$BwCredential,
        [string]$Path = "PasswordLengthReport_$(Get-Date -Format "yyyyMMdd_hhmm").xlsx",
        [switch]$SanitizeOutput,
        [string]$PolicyName = "PasswordLength",
        [switch]$PassThru
    )
    begin{
        $passwordLengthReportTable = @()
    }
    process{
        $policy = ""
        if ($_.PolicyExemptions.ContainsKey($PolicyName)){
            $policy = $_.PolicyExemptions[$PolicyName]
        }
        $passwordLengthReportTable += [PSCustomObject]@{
            Collection = $_.Collection
            Name = $_.name
            Username = $_.username
            PasswordLength = $_.Password.Length
            PassedPolicy = (($_.PolicyResults[$PolicyName]) ? "PASS" : "FAIL")
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
        $excel = $passwordLengthReportTable | Sort-Object -Property PasswordLength | `
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