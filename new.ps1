param (
    [Parameter(Mandatory=$true)]
    [string]$Repo
)

# Get the repository name from the URL
$repoName = [System.IO.Path]::GetFileNameWithoutExtension($Repo.Split('/')[-1])

# Check if the Docker volume already exists
$volumeExists = (docker volume ls -q | Select-String $repoName) -ne $null

# Get the full path of the user's .ssh directory
$userSshDir = (Resolve-Path ~/.ssh).ProviderPath

if (-not $volumeExists) {
    # Create a Docker volume based on the repository name
    docker volume create $repoName
    Write-Host "Created Docker volume: $repoName"

    # Run a Docker container and attach the created volume
    docker run -v "${repoName}:/app" -v "${userSshDir}:/.ssh" -e "REPO=$Repo" -e "DIR=/app" --rm alpine-cloner
    Write-Host "Cloned $Repo to volume /app $repoName."
} else {
    Write-Host "Docker volume $repoName already exists."
}

docker run -v "${repoName}:/app" -v "${userSshDir}:/.ssh" -p "8000:8000" -it --rm alpine-vscode
