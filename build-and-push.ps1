# PowerShell script to build and push the Streamlit Download App to Docker Hub
# Usage: .\build-and-push.ps1 [docker-hub-username]

param(
    [string]$DockerHubUsername = "your-username"
)

# Configuration
$ImageName = "streamlit-download-app"
$Tag = "latest"

Write-Host "🔨 Building Docker image..." -ForegroundColor Blue
docker build -t $ImageName .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Docker image built successfully!" -ForegroundColor Green
    
    # Tag for Docker Hub
    $FullImageName = "$DockerHubUsername/$ImageName`:$Tag"
    docker tag $ImageName $FullImageName
    
    Write-Host "🔐 Logging in to Docker Hub..." -ForegroundColor Blue
    docker login
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "📤 Pushing image to Docker Hub..." -ForegroundColor Blue
        docker push $FullImageName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Image pushed to Docker Hub successfully!" -ForegroundColor Green
            Write-Host "Your image is available at: docker.io/$FullImageName" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "🚀 To use your image:" -ForegroundColor Yellow
            Write-Host "   docker run -p 8501:8501 -v /path/to/data:/data/downloads $FullImageName" -ForegroundColor White
        } else {
            Write-Host "❌ Failed to push image to Docker Hub" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Failed to login to Docker Hub" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Failed to build Docker image" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
