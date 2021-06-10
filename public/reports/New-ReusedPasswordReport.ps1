function New-ReusedPasswordReport{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [PSTypeName('ReusedCredential')]$ReusedCredentials,
        [string]$Path = "ReusedPasswordReport_$(Get-Date -Format "yyyyMMdd_hhmm").xlsx",
        [string]$WorksheetName = "ReusedPasswords"
    )
    begin{
        $creds = @()
    }
    process{
        $creds += $_
    }
    end{
        
        $excel = $creds | `
            Export-Excel -AutoSize `
            -AutoFilter `
            -Path $Path `
            -WorksheetName $WorksheetName `
            -TableName $WorksheetName `
            -PassThru

        #FORMATTING
        #Manually size the first two columns
        $excel.Workbook.Worksheets[$WorksheetName].Column(3).width = 50

        #Save and close
        $excel.Save()
        $excel.Dispose()
    }
}