# Constant Vars
$GITHUB_API_LINK = "https://api.github.com/repos/{0}/releases/latest"
$GITHUB_HEADERS = @{
    "Accept" = "application/vnd.github.v3+json"
}

# Function
function Download-Asset($asset) {
    
    # Get release and asset details from api
    $latestRelease = Invoke-RestMethod -Uri ($GITHUB_API_LINK -f $asset.repo) -Headers $GITHUB_HEADERS
    $latestAssets = $latestRelease.assets | Select-Object -Property "name", @{
        Name = "url"; Expression = { "browser_download_url" };
    }
    
    # Check each asset in the list
    foreach ($name in $asset.name) {
        
        # Get asset details from list
        $item = $latestAssets | Where-Object {
            $PSItem.name -like "*$name*"
        } | Select-Object -First 1
        if ($item -eq $null) { continue }
        
        # Download or use Cached
        $dlPath = Join-Path -Path "source" -ChildPath $item.name
        if (Test-Path -Path $dlPath) {
            Write-Host "Using cached asset $($item.name)"
            continue
        }
        Write-Host "Downloading asset $($item.name)"
        Invoke-WebRequest -Uri $item.url -OutFile $dlPath
    }
}

$assets = Get-Content "assets.yml" | ConvertFrom-Yaml
foreach ($asset in $assets.assets) {
    Download-Asset $asset
}
