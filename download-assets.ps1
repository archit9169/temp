# Asset releated veriables
$ASSET_PATH = "asset"
$ASSET_FILE = "assets.yml"

# Github API link and header variables to get release info and dl link
$GITHUB_API_LINK = "https://api.github.com/repos/{0}/releases/latest"
$GITHUB_HEADERS = @{
    "Accept" = "application/vnd.github.v3+json"
}

# Function to download asset
function Download-Asset($asset) {
    
    # Get release and asset details from api
    $latestRelease = Invoke-RestMethod -Uri ($GITHUB_API_LINK -f $asset.repo) -Headers $GITHUB_HEADERS
    $latestAssets = $latestRelease.assets | Select-Object -Property "name", "browser_download_url"
    
    # Check each asset in the list
    foreach ($name in $asset.name) {
        
        # Get asset details from list
        $item = $latestAssets | Where-Object {
            $PSItem.name -like "*$name*"
        } | Select-Object -First 1
        if ($item -eq $null) { continue }
        
        # Download or use Cached Assets
        $dlPath = Join-Path -Path $ASSET_PATH -ChildPath $item.name
        if (Test-Path -Path $dlPath) {
            Write-Host "Using cached asset $($item.name)"
            continue
        }
        Write-Host "Downloading asset $($item.name)"
        Invoke-WebRequest -Uri $item.browser_download_url -OutFile $dlPath
    }
}

# Call
New-Item -Name $ASSET_PATH -ItemType Dir
$assets = Get-Content $ASSET_FILE | ConvertFrom-Yaml
foreach ($asset in $assets.assets) {
    Download-Asset $asset
}
