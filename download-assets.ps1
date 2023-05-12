function Download-Asset($asset) {
    $repoName = $asset.repo
    $uri = "https://api.github.com/repos/$repoName/releases/latest"
    $headers = @{
        "Accept" = "application/vnd.github.v3+json"
    }

    $latestRelease = Invoke-RestMethod -Uri $uri -Headers $headers
    $assetName = $asset.name
    $assetDownloadUrl = $latestRelease.assets | Where-Object { $_.name -like "$assetName*" } | Select-Object -First 1 -ExpandProperty browser_download_url
    $assetVersion = $latestRelease.tag_name
    $assetNameWithVersion = $assetName + "-" + $assetVersion + $assetDownloadUrl.Substring($assetDownloadUrl.LastIndexOf("."))
    $downloadPath = Join-Path -Path "source" -ChildPath $assetNameWithVersion

    if (Test-Path -Path $downloadPath) {
        Write-Host "Using cached asset $assetNameWithVersion"
        return
    }

    Write-Host "Downloading asset $assetNameWithVersion"
    Invoke-WebRequest -Uri $assetDownloadUrl -OutFile $downloadPath
}

$assets = Get-Content "assets.yml" | ConvertFrom-Yaml
foreach ($asset in $assets.assets) {
    Download-Asset $asset
}
