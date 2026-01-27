[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Path
)

$Uris = @('https://www.spamhaus.org/drop/drop_v4.json', ' https://www.spamhaus.org/drop/drop_v6.json')

try {

    if (Test-Path $Path) {
        Remove-Item -Path $Path
    }

    foreach ($Uri in $Uris) {
        $TemporaryFile = New-TemporaryFile

        Invoke-WebRequest -Uri $Uri -OutFile $TemporaryFile.FullName
        $Content = Get-Content -Path $TemporaryFile.FullName

        foreach ($Line in $Content) {
            if ($null -ne ($Line | ConvertFrom-Json).cidr) {
                Add-Content -Path $Path -Value ($Line | ConvertFrom-Json).cidr
            }
        }

        Remove-Item -Path $TemporaryFile

    }
}
catch {
    Write-Error $PSItem.Exception.Message
}
