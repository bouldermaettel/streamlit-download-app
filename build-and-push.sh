git #!/bin/bash

# Script to build and push the Streamlit Download App to Docker Hub

# Configuration
IMAGE_NAME="streamlit-download-app"
DOCKER_HUB_USERNAME="bouldermaettel"
TAG="0.0.1"

echo "Building Docker image..."
docker build -t $IMAGE_NAME .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully!"
    
    # Tag for Docker Hub
    docker tag $IMAGE_NAME $DOCKER_HUB_USERNAME/$IMAGE_NAME:$TAG
    
    echo "Logging in to Docker Hub..."
    docker login
    
    if [ $? -eq 0 ]; then
        echo "Pushing image to Docker Hub..."
        docker push $DOCKER_HUB_USERNAME/$IMAGE_NAME:$TAG
        
        if [ $? -eq 0 ]; then
            echo "✅ Image pushed to Docker Hub successfully!"
            echo "Your image is available at: docker.io/$DOCKER_HUB_USERNAME/$IMAGE_NAME:$TAG"
        else
            echo "❌ Failed to push image to Docker Hub"
        fi
    else
        echo "❌ Failed to login to Docker Hub"
    fi
else
    echo "❌ Failed to build Docker image"
fi
