# PowerShell script to run the Streamlit Download App with Docker
# Usage: .\run-docker.ps1 [data-path]

param(
    [string]$DataPath = ".\data"
)

# Configuration
$ContainerName = "streamlit-download-app"
$ImageName = "streamlit-download-app"
$Port = "8501"

# Convert to absolute path
$DataPath = Resolve-Path -Path $DataPath -ErrorAction SilentlyContinue

# Check if data path exists
if (-not $DataPath -or -not (Test-Path $DataPath)) {
    Write-Host "❌ Data path does not exist: $DataPath" -ForegroundColor Red
    Write-Host "Please provide a valid path to your data folder." -ForegroundColor Yellow
    Write-Host "Usage: .\run-docker.ps1 [data-path]" -ForegroundColor Yellow
    Write-Host "Example: .\run-docker.ps1 C:\path\to\your\data" -ForegroundColor Yellow
    exit 1
}

Write-Host "🚀 Starting Streamlit Download App..." -ForegroundColor Green
Write-Host "📁 Data folder: $DataPath" -ForegroundColor Cyan
Write-Host "🌐 Port: $Port" -ForegroundColor Cyan
Write-Host "🔗 URL: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "🔑 Default token: hello" -ForegroundColor Cyan
Write-Host ""

# Stop and remove existing container if it exists
$ExistingContainer = docker ps -aq -f name=$ContainerName 2>$null
if ($ExistingContainer) {
    Write-Host "🛑 Stopping existing container..." -ForegroundColor Yellow
    docker stop $ContainerName | Out-Null
    docker rm $ContainerName | Out-Null
}

# Run the container
Write-Host "🐳 Running Docker container..." -ForegroundColor Blue

$DockerCommand = @(
    "run", "-d",
    "--name", $ContainerName,
    "-p", "$Port`:8501",
    "-v", "`"$DataPath`":/data/downloads",
    "--restart", "unless-stopped",
    "--health-cmd", "curl --fail http://localhost:8501/_stcore/health || exit 1",
    "--health-interval", "30s",
    "--health-timeout", "10s",
    "--health-retries", "3",
    $ImageName
)

$Result = & docker @DockerCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Container started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Container info:" -ForegroundColor Cyan
    Write-Host "   Name: $ContainerName" -ForegroundColor White
    Write-Host "   Status: Running" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 Useful commands:" -ForegroundColor Cyan
    Write-Host "   View logs: docker logs $ContainerName" -ForegroundColor White
    Write-Host "   Stop: docker stop $ContainerName" -ForegroundColor White
    Write-Host "   Remove: docker rm $ContainerName" -ForegroundColor White
    Write-Host "   Status: docker ps -f name=$ContainerName" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 Open your browser and go to: http://localhost:$Port" -ForegroundColor Green
    
    # Optional: Open browser automatically
    $OpenBrowser = Read-Host "Would you like to open the browser now? (y/N)"
    if ($OpenBrowser -eq "y" -or $OpenBrowser -eq "Y") {
        Start-Process "http://localhost:$Port"
    }
} else {
    Write-Host "❌ Failed to start container" -ForegroundColor Red
    Write-Host "Error details:" -ForegroundColor Red
    Write-Host $Result -ForegroundColor Red
    exit 1
}
