function New-ComprehensiveReport{
    [cmdletbinding()]
    param(
        [cmdletbinding()]
        [Parameter(Mandatory,ValueFromPipeline)]
        [BwCredential]$BwCredential,
        [string]$Path = "ComprehensivePasswordReport_$(Get-Date -Format "yyyyMMdd_hhmm").xlsx"
    )
    begin{
        [BwCredential[]]$TestedCredentials = @()
        Write-Information "[INFO] Testing passwords" -InformationAction Continue
    }
    process{
        $TestedCredentials += $BwCredential | `
            Test-PasswordLengthPolicy | `
            Test-BannedWords | `
            Test-ConsecutiveChars | `
            Test-ConsecutiveChars -Case "Upper" | `
            Test-ConsecutiveChars -Case "Lower" | `
            Test-ConsecutiveDigits
    }
    end{
        Write-Information "[INFO] Generating report" -InformationAction Continue
        $TestedCredentials | `
            New-PasswordLengthReport -Path $Path -PassThru | `
            New-BannedWordsReport -Path $Path -PassThru | `
            New-ConsecutiveCharsReport -Path $Path -PassThru | `
            New-ConsecutiveCharsReport -Path $Path -Case "Upper" -PassThru | `
            New-ConsecutiveCharsReport -Path $Path -Case "Lower" -PassThru | `
            New-ConsecutiveDigitsReport -Path $Path

        #Reused password report is different from the rest and therefore must be run separately
        $TestedCredentials | Get-ReusedPassword -SanitizeOutput | New-ReusedPasswordReport -Path $Path
    }
}