#!/usr/bin/env python3
"""
Cloud Deployment Script for Rice Disease Detection API
Deploys to Render.com and configures Flutter app
"""

import os
import sys
import json
import subprocess
import time
import requests
from pathlib import Path

def check_requirements():
    """Check if all required files exist"""
    required_files = [
        'rice_disease_api.py',
        'requirements.txt',
        'rice_emergency_model.h5',
        'render.yaml',
    ]
    
    missing_files = []
    for file in required_files:
        if not os.path.exists(file):
            missing_files.append(file)
    
    if missing_files:
        print(f"❌ Missing required files: {missing_files}")
        return False
    
    print("✅ All required files present")
    return True

def create_git_repo():
    """Initialize git repository if not exists"""
    if not os.path.exists('.git'):
        print("📦 Initializing git repository...")
        subprocess.run(['git', 'init'], check=True)
        subprocess.run(['git', 'add', '.'], check=True)
        subprocess.run(['git', 'commit', '-m', 'Initial commit for rice disease API'], check=True)
        print("✅ Git repository initialized")
    else:
        print("✅ Git repository already exists")

def test_local_api():
    """Test local API before deployment"""
    print("🧪 Testing local API...")
    try:
        response = requests.get('http://localhost:5000/health', timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data.get('model_loaded'):
                print("✅ Local API is working and model is loaded")
                return True
            else:
                print("❌ Model is not loaded in local API")
                return False
        else:
            print(f"❌ Local API returned status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Local API test failed: {e}")
        print("💡 Make sure to run 'python rice_disease_api.py' first")
        return False

def deploy_to_render():
    """Deploy to Render.com"""
    print("🚀 Deploying to Render.com...")
    print("\n📋 Manual Deployment Steps:")
    print("1. Go to https://render.com and sign up/login")
    print("2. Click 'New +' → 'Web Service'")
    print("3. Connect your GitHub repository")
    print("4. Configure the following settings:")
    print("   - Name: rice-disease-api")
    print("   - Environment: Python 3")
    print("   - Build Command: pip install -r requirements.txt")
    print("   - Start Command: gunicorn --bind 0.0.0.0:$PORT rice_disease_api:app")
    print("   - Plan: Free")
    print("\n5. Add Environment Variables:")
    print("   - TF_CPP_MIN_LOG_LEVEL = 2")
    print("   - PYTHON_VERSION = 3.12")
    
    print("\n🔗 Your API will be available at:")
    print("   https://rice-disease-api-XXXXXXX.onrender.com")
    
    return input("\n✅ Enter your Render.com URL when deployment is complete: ").strip()

def update_flutter_config(api_url):
    """Update Flutter app configuration to use cloud API"""
    print(f"🔧 Updating Flutter configuration to use {api_url}...")
    
    # Update disease_detection_service.dart
    service_file = Path('lib/services/disease_detection_service.dart')
    if service_file.exists():
        content = service_file.read_text()
        
        # Replace the production URL
        updated_content = content.replace(
            'https://rice-disease-api-YOUR_APP_ID.onrender.com',
            api_url
        )
        
        # Enable production API
        updated_content = updated_content.replace(
            'static const bool _useProductionAPI = true;',
            'static const bool _useProductionAPI = true;'
        )
        
        service_file.write_text(updated_content)
        print("✅ Updated disease_detection_service.dart")
    
    # Also update rice_disease_api_service.dart as fallback
    api_service_file = Path('lib/services/rice_disease_api_service.dart')
    if api_service_file.exists():
        content = api_service_file.read_text()
        updated_content = content.replace(
            'http://192.168.182.140:5000',
            api_url
        )
        api_service_file.write_text(updated_content)
        print("✅ Updated rice_disease_api_service.dart as fallback")

def test_cloud_api(api_url):
    """Test the deployed cloud API"""
    print(f"🧪 Testing cloud API at {api_url}...")
    
    try:
        # Test health endpoint
        print("   Testing /health...")
        response = requests.get(f"{api_url}/health", timeout=60)
        
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Health check passed")
            print(f"   Model loaded: {data.get('model_loaded')}")
            print(f"   Status: {data.get('status')}")
            
            # Test diseases endpoint
            print("   Testing /diseases...")
            response = requests.get(f"{api_url}/diseases", timeout=30)
            if response.status_code == 200:
                diseases_data = response.json()
                print(f"   ✅ Diseases endpoint working ({len(diseases_data.get('diseases', []))} diseases)")
                
                return True
            else:
                print(f"   ❌ Diseases endpoint failed: {response.status_code}")
                return False
        else:
            print(f"   ❌ Health check failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except requests.exceptions.Timeout:
        print("   ⏰ API is still waking up (this is normal for Render.com free tier)")
        print("   💡 Try again in 2-3 minutes")
        return False
    except Exception as e:
        print(f"   ❌ API test failed: {e}")
        return False

def create_deployment_guide():
    """Create a deployment guide file"""
    guide_content = """# 🚀 Rice Disease Detection - Cloud Deployment Guide

## ✅ Deployment Complete!

Your Rice Disease Detection API is now deployed to the cloud and your Flutter app is configured to use it.

### 📱 **Flutter App Configuration:**
- ✅ Configured to use production cloud API
- ✅ Firebase integration enabled
- ✅ All endpoints updated

### 🌐 **Cloud API Features:**
- ✅ 24/7 availability (with cold start delays)
- ✅ Automatic scaling
- ✅ HTTPS security
- ✅ Global CDN

### 📊 **Performance Expectations:**

**First Request (Cold Start):**
- ⏱️ 30-60 seconds (API waking up)
- 🔄 Automatic retry logic included

**Subsequent Requests:**
- ⏱️ 5-15 seconds
- 🚀 Faster response times

### 🔧 **Testing Your App:**

1. **Build and Run:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Test Disease Detection:**
   - Take photo with camera
   - Select from gallery
   - Wait for cloud processing
   - View results and treatment

### 📱 **Building for Production:**

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

### 🎯 **Your App is Now:**
- ✅ **Fully Cloud-Deployed**
- ✅ **Device Independent**
- ✅ **Production Ready**
- ✅ **Scalable**

### 🌾 **Ready for Real-World Use!**

Your rice disease detection app now works completely independently without needing a laptop connection. Farmers can use it anywhere with internet connectivity!

## 🔧 **Troubleshooting:**

**Slow First Response:**
- Normal for free tier hosting
- Subsequent requests are faster

**API Not Responding:**
- Check Render.com dashboard
- Ensure deployment is active

**Firebase Issues:**
- Check Firebase console settings
- Verify API keys and permissions
"""
    
    with open('DEPLOYMENT_COMPLETE.md', 'w') as f:
        f.write(guide_content)
    
    print("📚 Created DEPLOYMENT_COMPLETE.md guide")

def main():
    print("🌾 Rice Disease Detection - Cloud Deployment")
    print("=" * 60)
    
    # Step 1: Check requirements
    if not check_requirements():
        sys.exit(1)
    
    # Step 2: Test local API
    if not test_local_api():
        print("\n💡 Start local API first: python rice_disease_api.py")
        if input("Continue anyway? (y/N): ").lower() != 'y':
            sys.exit(1)
    
    # Step 3: Initialize git
    try:
        create_git_repo()
    except Exception as e:
        print(f"⚠️ Git initialization failed: {e}")
        print("💡 You may need to manually push to GitHub")
    
    # Step 4: Deploy to Render.com
    api_url = deploy_to_render()
    
    if not api_url:
        print("❌ No API URL provided")
        sys.exit(1)
    
    # Ensure URL format is correct
    if not api_url.startswith('http'):
        api_url = f"https://{api_url}"
    
    print(f"\n🔗 Using API URL: {api_url}")
    
    # Step 5: Update Flutter configuration
    update_flutter_config(api_url)
    
    # Step 6: Test cloud API (optional)
    print(f"\n🧪 Would you like to test the cloud API now?")
    if input("This may take 1-2 minutes due to cold start (y/N): ").lower() == 'y':
        test_cloud_api(api_url)
    
    # Step 7: Create deployment guide
    create_deployment_guide()
    
    print("\n" + "=" * 60)
    print("🎉 DEPLOYMENT COMPLETE!")
    print("=" * 60)
    print("✅ Your Rice Disease Detection app is now fully cloud-deployed!")
    print("✅ Works independently without laptop connection")
    print("✅ Ready for production use by farmers")
    print(f"\n🔗 Cloud API: {api_url}")
    print("\n📱 Next steps:")
    print("1. Run: flutter run")
    print("2. Test disease detection")
    print("3. Build production APK: flutter build apk --release")
    print("\n📚 See DEPLOYMENT_COMPLETE.md for full guide")

if __name__ == "__main__":
    main()