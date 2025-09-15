@echo off
REM Script to run the Streamlit Download App with Docker
REM Usage: run-docker.bat [data-path]

REM Configuration
set CONTAINER_NAME=streamlit-download-app
set IMAGE_NAME=streamlit-download-app
set PORT=8501
set DEFAULT_DATA_PATH=.\data

REM Get data path from argument or use default
if "%~1"=="" (
    set DATA_PATH=%DEFAULT_DATA_PATH%
) else (
    set DATA_PATH=%~1
)

REM Check if data path exists
if not exist "%DATA_PATH%" (
    echo ❌ Data path does not exist: %DATA_PATH%
    echo Please provide a valid path to your data folder.
    echo Usage: %0 [data-path]
    echo Example: %0 C:\path\to\your\data
    pause
    exit /b 1
)

echo 🚀 Starting Streamlit Download App...
echo 📁 Data folder: %DATA_PATH%
echo 🌐 Port: %PORT%
echo 🔗 URL: http://localhost:%PORT%
echo 🔑 Default token: hello
echo.

REM Stop and remove existing container if it exists
docker ps -aq -f name=%CONTAINER_NAME% >nul 2>&1
if %errorlevel% equ 0 (
    echo 🛑 Stopping existing container...
    docker stop %CONTAINER_NAME%
    docker rm %CONTAINER_NAME%
)

REM Run the container
echo 🐳 Running Docker container...
docker run -d ^
  --name %CONTAINER_NAME% ^
  -p %PORT%:8501 ^
  -v "%DATA_PATH%":/data/downloads ^
  --restart unless-stopped ^
  --health-cmd "curl --fail http://localhost:8501/_stcore/health || exit 1" ^
  --health-interval 30s ^
  --health-timeout 10s ^
  --health-retries 3 ^
  %IMAGE_NAME%

if %errorlevel% equ 0 (
    echo ✅ Container started successfully!
    echo.
    echo 📋 Container info:
    echo    Name: %CONTAINER_NAME%
    echo    Status: Running
    echo.
    echo 🔧 Useful commands:
    echo    View logs: docker logs %CONTAINER_NAME%
    echo    Stop: docker stop %CONTAINER_NAME%
    echo    Remove: docker rm %CONTAINER_NAME%
    echo.
    echo 🌐 Open your browser and go to: http://localhost:%PORT%
) else (
    echo ❌ Failed to start container
    pause
    exit /b 1
)

pause
