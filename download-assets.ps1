# Asset releated veriables from env
$ASSET_PATH = ${{ env.ASSET_PATH }}
$ASSET_FILE = ${{ env.ASSET_FILE }}

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
            $PSItem.name -like "$name-*"
        } | Select-Object -First 1

        # Check if item exist
        if ($item -eq $null) { continue }
        $dlPath = "$ASSET_PATH/$($item.name)"

        # Check and use cached assets
        if (Test-Path -Path $dlPath) {
            Write-Host "Using cached $($item.name)"
            continue
        }
        
        # Remove previous version of assets
        Write-Host "Removing old $name-*"
        Remove-Item -Path "$ASSET_PATH/$($item.name)-*"

        # Donwload new version of assets
        Write-Host "Downloading $($item.name)"
        Invoke-WebRequest -Uri $item.browser_download_url -OutFile $dlPath
    }
}

# Main Call
New-Item -Name $ASSET_PATH -ItemType Dir -EA 0
$assets = Get-Content $ASSET_FILE | ConvertFrom-Yaml
foreach ($asset in $assets.assets) {
    Download-Asset $asset
}
