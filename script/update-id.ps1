

Function GenerateHash {
    param (
        [string]$InputString,
        [string]$Key
    )
    $hash = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256')
    $hashBytes = $hash.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($InputString))
    $hashString = [System.BitConverter]::ToString($hashBytes).Replace("-", "").Substring(0, 5)
    return "$Key$hashString"
}

try {
    $jsonAPP = ".\json\app.json"
    $key = "APP"

    $json = Get-Content $jsonAPP -Raw | ConvertFrom-Json

    $json.list.items | ForEach-Object {
        if (-not $_.id.StartsWith($key)) {
            $_.id = GenerateHash -InputString $_.name -Key $key
        }
    }
    $json | ConvertTo-Json -Depth 10 | Set-Content $jsonAPP
}
catch {
    write-error 'Something went wrong file updating APP'
}


try {
    $jsonWEB = ".\json\web.json"
    $key = "WEB"

    $json = Get-Content $jsonWEB -Raw | ConvertFrom-Json

    $json.list.items | ForEach-Object {
        if (-not $_.id.StartsWith($key )) {
            $_.id = GenerateHash -InputString $_.name -Key $key 
        }
    }
    $json | ConvertTo-Json -Depth 10 | Set-Content $jsonWEB
}
catch {
    write-error 'Something went wrong file updating APP'
}
