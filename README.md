# BwPolicyAnalyzer

Basic password policy analyzer for Bitwarden passwords. Uses the `bw` utility to retrieve your collections and passwords. It then maps the passwords to collections. From there, you can test your passwords against defined policy or view a sorted list of reused passwords.

Includes the following tests:

* Password Length (16 character default)
* Banned Words
* Consecutive Characters
* Consecutive Digits
* Reused Passwords

## Getting Started

### Prerequisites

* `bw` utility; provided by Bitwarden
* PowerShell 7
* [ImportExcel](https://www.powershellgallery.com/packages/ImportExcel/) PowerShell Module

### Import `BwPolicyAnalyzer`

```Powershell
Import-Module .\BwPolicyAnalyer.psd1
```

### Retrieve session token

Calls `bw unlock`. Must have previously logged in prior to calling `Set-BwSessionToken`. Will prompt for Bitwarden credentials and then sets `$env:BW_SESSION` to retrieved token.

```PowerShell
Set-BwSessionToken
```

### Retrieve credentials

```PowerShell
#Retrieve all credentials
$creds = Get-BwCredential

#Retrieve credentials from a specific collection - 'North America/IT' in this case
$creds = Get-BwCredential -CollectionName 'North America/IT'
```

### Generate a comprehensive report

Runs all available tests.

```PowerShell
$creds | New-ComprehensiveReport

#optionally specify path
$creds | New-ComprehensiveReport -Path 'MyCompleteReport.xlsx'
```

### Generate individual reports

You can specify individual tests to run and generate individual reports. Pipe retrieved credentials to the test you want to run. In the following example, credentials are passed to `Test-PasswordLengthPolicy`. Then pipe the results to the corresponding report. Optionally specify a `Path` for a custom report name. Use `PassThru` if creating a report with multiple tests.

```PowerShell
#Single test
$creds | Test-PasswordLength | New-PasswordLengthReport

#Multiple tests
$path = 'MyCustomReport.xlsx'
$creds | Test-PasswordLengthPolicy | Test-BannedWords | New-PasswordLengthReport -Path $path -PassThru | New-BannedWordsReport -Path
```

## Tests and Reports

Most tests are pass or fail. Pipe credentials to multiple tests to run more than one test at a time.

| Policy | Test Name | Report Name |
| - | - | - |
| Password Length | `Test-PasswordLengthPolicy` | `New-PasswordLengthReport` |
| Banned Words | `Test-BannedWords` | `New-BannedWordsReport` |
| Consecutive Characters | `Test-ConsecutiveChars` | `New-ConsecutiveCharsReport` |
| Consecutive Digits | `Test-ConsecutiveDigits` | `New-ConsecutiveDigitsReport`
| Reused Passwords | `Get-ReusedPassword` | `New-ReusedPasswordReport` |

### Password Length

Finds passwords less than the specified number of characters, 16 by default.

### Banned Words

Evaluates regexes defined by you. These regexes must be stored in `config\bannedWords.json` which should be structured like the following example:

```JSON
[
    {
        "WordPolicy": "Password",
        "Regex": "p[@a]s"
    },
    {
        "WordPolicy": "Seattle",
        "Regex": "s[e3][a@]t"
    }
]
```

These example policies match text that contains variants used for 'Password' and 'Seattle'. The matches are only as good as the regexes you choose to use.

### Consecutive Characters
Checks for consecutive alpha chars beyond the allowed number, four by default. The intent is to find dictionary words. You can specify "Mixed", "Upper", or "Lower" casing. "Mixed" is the default if none is selected.

```PowerShell
$creds | Test-ConsecutiveChars | New-ConsecutiveCharsReport

#Specify number of allowed consecutive chars. In this case, if six or more consecutive alpha characters are found in a password, the password will fail audit.
$creds | Test-ConsecutiveChars -AllowedConsecutiveChars 5 | New-ConsecutiveCharsReport

#Specify casing
$creds | Test-ConsecutiveChars -Case "Lower" | New-ConsecutiveCharsReport
```

It should be noted that this test can find a lot of false positives, but can be helpful for manual searches if you have a lot of passwords in Bitwarden.

### Consecutive Digits

This test searches for anything over the specified number of consecutive numerical digits. Three consecutive digits are allowed by default. This is useful for finding numbers like '123456' or years like '2020'. However, years are probably better suited using the banned words report.

```PowerShell
$creds | Test-ConsecutiveDigits | New-ConsecutiveDigitsReport
```

### Reused Passwords

This test is not pass or fail, so operates a little differently. To retrieve a list of reused passwords, use the `Get-ReusedPassword` cmdlet.

```PowerShell
#SanitizeOutput creates a placeholder password, so the actual password doesn't show up in the XLSX report. New-ComprehensiveReport specifies this option.
$creds | Get-ReusedPassword -SanitizeOutput | New-ReusedPasswordsReport
```
