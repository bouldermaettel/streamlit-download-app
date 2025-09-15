#!/bin/bash

# Script to run the Streamlit Download App with Docker
# Usage: ./run-docker.sh [data-path]

# Configuration
CONTAINER_NAME="streamlit-download-app"
IMAGE_NAME="streamlit-download-app"
PORT="8501"
DEFAULT_DATA_PATH="./data"

# Get data path from argument or use default
DATA_PATH=${1:-$DEFAULT_DATA_PATH}

# Check if data path exists
if [ ! -d "$DATA_PATH" ]; then
    echo "❌ Data path does not exist: $DATA_PATH"
    echo "Please provide a valid path to your data folder."
    echo "Usage: $0 [data-path]"
    echo "Example: $0 /path/to/your/data"
    exit 1
fi

# Convert to absolute path
DATA_PATH=$(realpath "$DATA_PATH")

echo "🚀 Starting Streamlit Download App..."
echo "📁 Data folder: $DATA_PATH"
echo "🌐 Port: $PORT"
echo "🔗 URL: http://localhost:$PORT"
echo "🔑 Default token: hello"
echo ""

# Stop and remove existing container if it exists
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "🛑 Stopping existing container..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

# Run the container
echo "🐳 Running Docker container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $PORT:8501 \
  -v "$DATA_PATH":/data/downloads \
  --restart unless-stopped \
  --health-cmd "curl --fail http://localhost:8501/_stcore/health || exit 1" \
  --health-interval 30s \
  --health-timeout 10s \
  --health-retries 3 \
  $IMAGE_NAME

if [ $? -eq 0 ]; then
    echo "✅ Container started successfully!"
    echo ""
    echo "📋 Container info:"
    echo "   Name: $CONTAINER_NAME"
    echo "   Status: $(docker ps --format 'table {{.Status}}' -f name=$CONTAINER_NAME | tail -n +2)"
    echo ""
    echo "🔧 Useful commands:"
    echo "   View logs: docker logs $CONTAINER_NAME"
    echo "   Stop: docker stop $CONTAINER_NAME"
    echo "   Remove: docker rm $CONTAINER_NAME"
    echo ""
    echo "🌐 Open your browser and go to: http://localhost:$PORT"
else
    echo "❌ Failed to start container"
    exit 1
fi
