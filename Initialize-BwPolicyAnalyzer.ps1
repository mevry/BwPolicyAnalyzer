#Create starter bannedWords policy (regexes included for password and qwerty)
$bannedWordsPath = "$PSScriptRoot\config\bannedWords.json"
if(-not (Test-Path $bannedWordsPath)){
    Set-Content -Path $bannedWordsPath -Value @"
[
    {
        "WordPolicy": "Password",
        "Regex": "p[a@][s$]"
    },
    {
        "WordPolicy": "qwerty",
        "Regex": "qw[e3]rt"
    }
]
"@
}