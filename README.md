# Streamlit File Download App

A dockerized Streamlit application that allows users to browse and download files from a mounted host folder with token-based authentication.

## Features

- 🔐 Token-based authentication
- 📁 Browse files in mounted folder (supports .sql and .csv files)
- 📦 Download single files or multiple files as ZIP
- 🐳 Fully dockerized with Docker Compose support
- 📊 Clean, responsive web interface

## Quick Start

### Using Docker Compose (Recommended)

1. **Clone or download this repository**
2. **Create a data folder and add your files:**
   ```bash
   mkdir data
   # Add your .sql and .csv files to the data folder
   cp your_files.sql data/
   cp your_files.csv data/
   ```

3. **Run the application:**
   ```bash
   docker-compose up -d
   ```

4. **Access the application:**
   - Open your browser and go to `http://localhost:8501`
   - Use the default token: `hello`

### Using Docker directly

1. **Build the image:**
   ```bash
   docker build -t streamlit-download-app .
   ```

2. **Run the container:**
   ```bash
   docker run -p 8501:8501 -v /path/to/your/data:/data/downloads streamlit-download-app
   ```

3. **Access the application:**
   - Open your browser and go to `http://localhost:8501`
   - Use the default token: `hello`

### Using Docker Run (Alternative to Docker Compose)

If Docker Compose is not available, you can use the following Docker run commands:

**Basic run command:**
```bash
docker run -d \
  --name streamlit-download-app \
  -p 8501:8501 \
  -v /path/to/your/data:/data/downloads \
  --restart unless-stopped \
  streamlit-download-app
```

**With health check:**
```bash
docker run -d \
  --name streamlit-download-app \
  -p 8501:8501 \
  -v /path/to/your/data:/data/downloads \
  --restart unless-stopped \
  --health-cmd "curl --fail http://localhost:8501/_stcore/health || exit 1" \
  --health-interval 30s \
  --health-timeout 10s \
  --health-retries 3 \
  streamlit-download-app
```

**Windows PowerShell:**
```powershell
docker run -d `
  --name streamlit-download-app `
  -p 8501:8501 `
  -v C:\path\to\your\data:/data/downloads `
  --restart unless-stopped `
  streamlit-download-app
```

**Windows Command Prompt:**
```cmd
docker run -d ^
  --name streamlit-download-app ^
  -p 8501:8501 ^
  -v C:\path\to\your\data:/data/downloads ^
  --restart unless-stopped ^
  streamlit-download-app
```

### Using the Run Scripts (Easiest)

For convenience, I've included run scripts that handle everything automatically:

**Linux/Mac:**
```bash
chmod +x run-docker.sh
./run-docker.sh                    # Uses ./data folder
./run-docker.sh /path/to/your/data # Uses custom data folder
```

**Windows Command Prompt:**
```cmd
run-docker.bat                     # Uses .\data folder
run-docker.bat C:\path\to\your\data # Uses custom data folder
```

**Windows PowerShell (Recommended):**
```powershell
.\run-docker.ps1                   # Uses .\data folder
.\run-docker.ps1 C:\path\to\your\data # Uses custom data folder
```

The scripts will:
- ✅ Check if the data folder exists
- 🛑 Stop any existing container with the same name
- 🐳 Start the new container with proper configuration
- 📋 Show useful management commands
- 🌐 Optionally open the browser automatically (PowerShell only)

## Configuration

### Changing the Authentication Token

The default token is `hello`. To change it:

1. **Generate a new token hash:**
   ```python
   import hashlib
   token = "your_new_token"
   hash_value = hashlib.md5(token.encode()).hexdigest()
   print(hash_value)
   ```

2. **Update the TOKEN_HASH in app.py:**
   ```python
   TOKEN_HASH = "your_generated_hash_here"
   ```

3. **Rebuild the Docker image:**
   ```bash
   docker-compose build
   docker-compose up -d
   ```

### Supported File Types

The application currently supports:
- `.sql` files
- `.csv` files

To add more file types, modify the `ALLOWED_EXTENSIONS` list in `app.py`:
```python
ALLOWED_EXTENSIONS = ['.sql', '.csv', '.txt', '.json']  # Add your extensions
```

## Docker Hub Deployment

### Building and Pushing to Docker Hub

**Using the build scripts (Recommended):**

**Linux/Mac:**
```bash
# Edit build-and-push.sh and replace 'your-username' with your Docker Hub username
chmod +x build-and-push.sh
./build-and-push.sh
```

**Windows PowerShell:**
```powershell
# Edit build-and-push.ps1 and replace 'your-username' with your Docker Hub username
.\build-and-push.ps1 your-username
```

**Windows Command Prompt:**
```cmd
# Edit build-and-push.bat and replace 'your-username' with your Docker Hub username
build-and-push.bat
```

**Manual commands:**
1. **Login to Docker Hub:**
   ```bash
   docker login
   ```

2. **Build the image with your Docker Hub username:**
   ```bash
   docker build -t yourusername/streamlit-download-app .
   ```

3. **Push to Docker Hub:**
   ```bash
   docker push yourusername/streamlit-download-app
   ```

### Using the Docker Hub Image

Once pushed, others can use your image:

```bash
docker run -p 8501:8501 -v /path/to/data:/data/downloads yourusername/streamlit-download-app
```

## File Structure

```
streamlit-download-app/
├── app.py                 # Main Streamlit application
├── requirements.txt       # Python dependencies
├── Dockerfile            # Docker configuration
├── docker-compose.yml    # Docker Compose configuration
├── .dockerignore         # Docker ignore file
├── .gitignore           # Git ignore file
├── run-docker.sh        # Linux/Mac run script
├── run-docker.bat       # Windows CMD run script
├── run-docker.ps1       # Windows PowerShell run script
├── build-and-push.sh    # Linux/Mac build & push script
├── build-and-push.bat   # Windows CMD build & push script
├── build-and-push.ps1   # Windows PowerShell build & push script
├── README.md            # This file
└── data/                # Sample data folder
    ├── sample_data.csv
    ├── sample_query.sql
    └── analytics_data.csv
```

## Security Notes

- The current implementation uses MD5 hashing for the token, which is not cryptographically secure
- For production use, consider using a more secure authentication method
- The token is hardcoded in the application - consider using environment variables for production

## Troubleshooting

### Container won't start
- Check if port 8501 is already in use
- Ensure the data folder exists and has proper permissions

### Files not showing up
- Verify the data folder is properly mounted
- Check that files have the correct extensions (.sql, .csv)
- Ensure the container has read permissions for the mounted folder

### Authentication issues
- Default token is `hello`
- Check the TOKEN_HASH value in app.py if you've modified it

## License

This project is open source and available under the MIT License.
