@echo off
REM Script to build and push the Streamlit Download App to Docker Hub

REM Configuration
set IMAGE_NAME=streamlit-download-app
set DOCKER_HUB_USERNAME=your-username
set TAG=latest

echo Building Docker image...
docker build -t %IMAGE_NAME% .

if %errorlevel% equ 0 (
    echo ✅ Docker image built successfully!
    
    REM Tag for Docker Hub
    docker tag %IMAGE_NAME% %DOCKER_HUB_USERNAME%/%IMAGE_NAME%:%TAG%
    
    echo Logging in to Docker Hub...
    docker login
    
    if %errorlevel% equ 0 (
        echo Pushing image to Docker Hub...
        docker push %DOCKER_HUB_USERNAME%/%IMAGE_NAME%:%TAG%
        
        if %errorlevel% equ 0 (
            echo ✅ Image pushed to Docker Hub successfully!
            echo Your image is available at: docker.io/%DOCKER_HUB_USERNAME%/%IMAGE_NAME%:%TAG%
        ) else (
            echo ❌ Failed to push image to Docker Hub
        )
    ) else (
        echo ❌ Failed to login to Docker Hub
    )
) else (
    echo ❌ Failed to build Docker image
)

pause
