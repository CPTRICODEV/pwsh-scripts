# Function to call the github repo
function Get-LatestGitHubRelease {
    param (
        [string]$Owner,
        [string]$Repo
    )

    $uri = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
    $response = Invoke-RestMethod -Uri $uri -Method Get

    return $response.tag_name
}

# Example usage
$owner = "your-github-username"
$repo = "your-repository-name"

$latestVersion = Get-LatestGitHubRelease -Owner $owner -Repo $repo
$currentVersion = "v1.0" # Replace with your current version.

if ($latestVersion -gt $currentVersion) {
    Write-Host "A new version ($latestVersion) is available. Please update your script."
} else {
    Write-Host "You are using the latest version ($currentVersion). No update is required"
}