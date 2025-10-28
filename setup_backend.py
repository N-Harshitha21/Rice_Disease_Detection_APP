#!/usr/bin/env python3
"""
Setup script for Rice Disease Detection Backend
This script will help you get your Kaggle model running as a Flask API
"""

import os
import sys
import subprocess
import urllib.request
from pathlib import Path

def check_python_version():
    """Check if Python version is compatible"""
    if sys.version_info < (3, 8):
        print("❌ Python 3.8+ required. Current version:", sys.version)
        return False
    print(f"✅ Python version: {sys.version.split()[0]}")
    return True

def install_requirements():
    """Install required packages"""
    print("\n📦 Installing required packages...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ All packages installed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to install packages: {e}")
        return False

def check_model_file():
    """Check if model file exists"""
    model_file = "rice_emergency_model.h5"
    
    if os.path.exists(model_file):
        print(f"✅ Model file found: {model_file}")
        file_size = os.path.getsize(model_file) / (1024*1024)  # Convert to MB
        print(f"📊 Model size: {file_size:.2f} MB")
        return True
    else:
        print(f"❌ Model file not found: {model_file}")
        print("\n🔧 Steps to get your model:")
        print("1. Go to your Kaggle notebook output section")
        print("2. Download the 'rice_emergency_model.h5' file")
        print("3. Place it in this directory")
        print("4. Alternative: Look for any .h5 file and rename it to 'rice_emergency_model.h5'")
        
        # Look for other .h5 files
        h5_files = [f for f in os.listdir('.') if f.endswith('.h5')]
        if h5_files:
            print(f"\n💡 Found other .h5 files: {h5_files}")
            print("You can rename one of these if it's your trained model")
        
        return False

def test_tensorflow():
    """Test if TensorFlow is working"""
    try:
        import tensorflow as tf
        print(f"✅ TensorFlow version: {tf.__version__}")
        
        # Test GPU availability
        gpus = tf.config.list_physical_devices('GPU')
        if gpus:
            print(f"🎮 GPU available: {len(gpus)} device(s)")
        else:
            print("💻 Using CPU (GPU not available)")
        
        return True
    except ImportError:
        print("❌ TensorFlow not installed")
        return False
    except Exception as e:
        print(f"❌ TensorFlow error: {e}")
        return False

def update_flutter_config():
    """Update Flutter app configuration"""
    flutter_service_file = "lib/services/rice_disease_api_service.dart"
    
    if os.path.exists(flutter_service_file):
        print(f"\n📱 Updating Flutter configuration...")
        
        # Get local IP address
        try:
            import socket
            hostname = socket.gethostname()
            local_ip = socket.gethostbyname(hostname)
            
            print(f"🌐 Your computer's IP address: {local_ip}")
            print(f"📍 Update Flutter API URL to: http://{local_ip}:5000")
            print(f"📝 Edit file: {flutter_service_file}")
            print(f"📝 Change line 8: static const String baseUrl = 'http://{local_ip}:5000';")
            
        except Exception as e:
            print(f"⚠️ Could not detect IP address: {e}")
            print("📍 Update Flutter API URL to: http://localhost:5000 (for emulator)")
            print("📍 Or find your IP manually and use: http://YOUR_IP:5000")
            
    else:
        print(f"⚠️ Flutter service file not found: {flutter_service_file}")

def main():
    """Main setup function"""
    print("🌾 Rice Disease Detection Backend Setup")
    print("=" * 50)
    
    # Check Python version
    if not check_python_version():
        return False
    
    # Install requirements
    if not install_requirements():
        return False
    
    # Test TensorFlow
    if not test_tensorflow():
        return False
    
    # Check model file
    model_exists = check_model_file()
    
    # Update Flutter config
    update_flutter_config()
    
    print("\n" + "=" * 50)
    
    if model_exists:
        print("🎉 Setup completed successfully!")
        print("\n🚀 To start the backend:")
        print("   python rice_disease_api.py")
        print("\n🔗 API will be available at:")
        print("   - http://localhost:5000")
        print("   - http://YOUR_IP:5000")
        print("\n📱 To test with Flutter:")
        print("   1. Update the API URL in Flutter app")
        print("   2. Run: flutter pub get")
        print("   3. Run: flutter run")
        
    else:
        print("⚠️ Setup incomplete - Model file missing")
        print("\n📋 TODO:")
        print("1. Download your model file from Kaggle")
        print("2. Place it in this directory as 'rice_emergency_model.h5'")
        print("3. Run this setup script again")
    
    return model_exists

if __name__ == "__main__":
    success = main()
    if success:
        print("\n✅ Ready to start!")
    else:
        print("\n❌ Setup needs attention")
        
    input("\nPress Enter to exit...")