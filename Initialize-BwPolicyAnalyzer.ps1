#Create starter bannedWords policy (regexes included for password and qwerty)
#The reason config\bannedWords.json is not included by default is so these policies
#are not accidentally uploaded to a repo
$bannedWordsPath = "$PSScriptRoot\config\bannedWords.json"

try{
    if(-not (Test-Path $bannedWordsPath)){
        New-Item -ErrorAction Stop -Path $bannedWordsPath -Force | Out-Null
        Set-Content -ErrorAction Stop -Path $bannedWordsPath -Value @"
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
}
catch{
    $Error[0]
}
