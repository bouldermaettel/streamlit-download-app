import streamlit as st
import os
import zipfile
import io
from pathlib import Path
import hashlib
import time

# Configuration
DATA_FOLDER = os.getenv("DATA_FOLDER", "/data/downloads")  # Data folder path (configurable via environment variable)
ALLOWED_EXTENSIONS = ['.sql', '.csv']
TOKEN_HASH = "5d41402abc4b2a76b9719d911017c592"  # "hello" hashed with MD5

def verify_token(token):
    """Verify the provided token against the stored hash."""
    return hashlib.md5(token.encode()).hexdigest() == TOKEN_HASH

def get_files_in_folder(folder_path):
    """Get all files with allowed extensions from the specified folder."""
    if not os.path.exists(folder_path):
        return []
    
    files = []
    for file_path in Path(folder_path).rglob('*'):
        if file_path.is_file() and file_path.suffix.lower() in ALLOWED_EXTENSIONS:
            files.append(file_path)
    
    return files

def create_zip_file(file_paths):
    """Create a zip file containing the selected files."""
    zip_buffer = io.BytesIO()
    
    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
        for file_path in file_paths:
            if os.path.exists(file_path):
                # Add file to zip with relative path
                arcname = os.path.relpath(file_path, DATA_FOLDER)
                zip_file.write(file_path, arcname)
    
    zip_buffer.seek(0)
    return zip_buffer

def main():
    st.set_page_config(
        page_title="File Download App",
        page_icon="📁",
        layout="wide"
    )
    
    # Check if user is authenticated
    if 'authenticated' not in st.session_state:
        st.session_state.authenticated = False
    
    if not st.session_state.authenticated:
        st.title("🔐 Authentication Required")
        st.write("Please enter your access token to continue.")
        
        token = st.text_input("Access Token", type="password")
        
        if st.button("Login"):
            if verify_token(token):
                st.session_state.authenticated = True
                st.rerun()
            else:
                st.error("Invalid token. Please try again.")
        
        st.stop()
    
    # Main application interface
    st.title("📁 File Download App")
    st.write("Select files to download from the mounted data folder.")
    
    # Check if data folder exists
    if not os.path.exists(DATA_FOLDER):
        st.error(f"Data folder not found: {DATA_FOLDER}")
        st.write("Please ensure the folder is properly mounted.")
        st.write(f"Current working directory: {os.getcwd()}")
        st.write(f"Environment variable DATA_FOLDER: {os.getenv('DATA_FOLDER', 'Not set')}")
        return
    
    # Get available files
    files = get_files_in_folder(DATA_FOLDER)
    
    if not files:
        st.warning(f"No {', '.join(ALLOWED_EXTENSIONS)} files found in {DATA_FOLDER}")
        return
    
    st.success(f"Found {len(files)} files in the data folder")
    
    # Display files in a table
    st.subheader("Available Files")
    
    # Create a list of file info for display
    file_data = []
    for file_path in files:
        file_info = {
            'Name': file_path.name,
            'Path': str(file_path.relative_to(Path(DATA_FOLDER))),
            'Size': f"{file_path.stat().st_size / 1024:.1f} KB",
            'Modified': time.ctime(file_path.stat().st_mtime)
        }
        file_data.append(file_info)
    
    # Display files in a dataframe
    import pandas as pd
    df = pd.DataFrame(file_data)
    
    # Add checkboxes for file selection
    selected_files = []
    for idx, row in df.iterrows():
        col1, col2, col3, col4 = st.columns([3, 4, 1, 2])
        
        with col1:
            if st.checkbox(f"Select {row['Name']}", key=f"file_{idx}"):
                selected_files.append(files[idx])
        
        with col2:
            st.write(f"📄 {row['Name']}")
        
        with col3:
            st.write(row['Size'])
        
        with col4:
            st.write(row['Modified'])
    
    # Download section
    if selected_files:
        st.subheader("Download Selected Files")
        st.write(f"Selected {len(selected_files)} file(s)")
        
        # Show selected files
        for file_path in selected_files:
            st.write(f"• {file_path.name}")
        
        # Download options
        col1, col2 = st.columns(2)
        
        with col1:
            if st.button("📦 Download as ZIP", type="primary"):
                zip_buffer = create_zip_file(selected_files)
                st.download_button(
                    label="Download ZIP File",
                    data=zip_buffer.getvalue(),
                    file_name="selected_files.zip",
                    mime="application/zip"
                )
        
        with col2:
            if len(selected_files) == 1:
                file_path = selected_files[0]
                with open(file_path, 'rb') as f:
                    file_data = f.read()
                
                st.download_button(
                    label="📄 Download Single File",
                    data=file_data,
                    file_name=file_path.name,
                    mime="application/octet-stream"
                )
    
    # Logout button
    if st.button("🚪 Logout"):
        st.session_state.authenticated = False
        st.rerun()

if __name__ == "__main__":
    main()
