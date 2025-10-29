#!/usr/bin/env python3
"""
Fix Cloud Deployment - Ensure model loads properly on Render.com
"""

import os
import requests
import time
import subprocess

def check_model_file():
    """Verify model file exists and is valid"""
    model_path = 'rice_emergency_model.h5'
    
    if not os.path.exists(model_path):
        print("❌ Model file not found!")
        return False
    
    file_size = os.path.getsize(model_path)
    print(f"✅ Model file found: {model_path}")
    print(f"📊 File size: {file_size / (1024*1024):.1f} MB")
    
    if file_size < 1000000:  # Less than 1MB is suspicious
        print("⚠️ Model file seems too small")
        return False
    
    return True

def update_api_for_render():
    """Update API to work better on Render.com"""
    
    # Read current API file
    with open('rice_disease_api.py', 'r') as f:
        content = f.read()
    
    # Add Render.com specific optimizations
    if 'PORT' not in content:
        # Add port configuration for Render.com
        port_config = '''
# Render.com port configuration
import os
PORT = int(os.environ.get('PORT', 5000))
'''
        
        # Insert before the final if __name__ == '__main__':
        content = content.replace(
            "if __name__ == '__main__':",
            port_config + "\nif __name__ == '__main__':"
        )
    
    # Update the final app.run line for Render.com
    content = content.replace(
        "app.run(debug=True, host='0.0.0.0', port=5000)",
        "app.run(debug=False, host='0.0.0.0', port=PORT)"
    )
    
    # Add more robust model loading with retries
    if 'retry' not in content:
        retry_logic = '''
def load_model_with_retry(max_retries=3):
    """Load model with retry logic for cloud deployment"""
    global model
    
    for attempt in range(max_retries):
        try:
            print(f"Loading model attempt {attempt + 1}/{max_retries}...")
            if load_model():
                return True
            print(f"Attempt {attempt + 1} failed, retrying...")
            time.sleep(5)
        except Exception as e:
            print(f"Attempt {attempt + 1} error: {e}")
            time.sleep(5)
    
    print("❌ Failed to load model after all retries")
    return False
'''
        
        content = content.replace(
            "def load_model():",
            retry_logic + "\n\ndef load_model():"
        )
        
        # Update the main startup to use retry logic
        content = content.replace(
            "if load_model():",
            "if load_model_with_retry():"
        )
    
    # Write updated content
    with open('rice_disease_api.py', 'w') as f:
        f.write(content)
    
    print("✅ Updated API for Render.com deployment")

def create_startup_script():
    """Create a startup script for Render.com"""
    
    startup_content = '''#!/bin/bash
echo "🚀 Starting Rice Disease Detection API on Render.com"
echo "📁 Current directory: $(pwd)"
echo "📊 Available files:"
ls -la *.h5 || echo "No .h5 files found"

echo "🐍 Python version: $(python --version)"
echo "📦 TensorFlow version:"
python -c "import tensorflow as tf; print(f'TensorFlow: {tf.__version__}')" || echo "TensorFlow not available"

echo "🔥 Starting Gunicorn server..."
exec gunicorn --bind 0.0.0.0:$PORT rice_disease_api:app --timeout 300 --workers 1 --preload
'''
    
    with open('start.sh', 'w') as f:
        f.write(startup_content)
    
    print("✅ Created startup script")

def update_render_config():
    """Update render.yaml for better deployment"""
    
    render_config = '''services:
  - type: web
    name: rice-disease-api
    env: python
    buildCommand: |
      echo "🔧 Installing requirements..."
      pip install -r requirements.txt
      echo "📊 Checking model file..."
      ls -la *.h5 || echo "No .h5 files found"
      echo "📁 Directory contents:"
      ls -la
      echo "🐍 Python and TensorFlow versions:"
      python --version
      python -c "import tensorflow as tf; print(f'TensorFlow: {tf.__version__}')"
    startCommand: bash start.sh
    plan: free
    envVars:
      - key: PYTHON_VERSION
        value: 3.12.4
      - key: TF_CPP_MIN_LOG_LEVEL
        value: 2
      - key: MODEL_PATH
        value: rice_emergency_model.h5
      - key: PYTHONUNBUFFERED
        value: 1
'''
    
    with open('render.yaml', 'w') as f:
        f.write(render_config)
    
    print("✅ Updated render.yaml configuration")

def commit_and_deploy():
    """Commit changes and trigger deployment"""
    
    try:
        # Add all changes
        subprocess.run(['git', 'add', '.'], check=True)
        
        # Commit with descriptive message
        commit_msg = "Fix cloud deployment: ensure model loads on Render.com"
        subprocess.run(['git', 'commit', '-m', commit_msg], check=True)
        
        # Push to trigger deployment
        subprocess.run(['git', 'push'], check=True)
        
        print("✅ Changes pushed! Deployment triggered.")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Git operation failed: {e}")
        return False

def monitor_deployment():
    """Monitor the deployment progress"""
    
    print("\n⏰ Monitoring deployment progress...")
    print("This may take 5-10 minutes for Render.com to build and start")
    
    max_attempts = 20  # 10 minutes with 30-second intervals
    
    for attempt in range(max_attempts):
        try:
            print(f"\n🔍 Check {attempt + 1}/{max_attempts}: Testing cloud API...")
            
            response = requests.get(
                'https://rice-disease-detection-app-1.onrender.com/health',
                timeout=60
            )
            
            if response.status_code == 200:
                data = response.json()
                model_loaded = data.get('model_loaded', False)
                
                print(f"📡 Status: {response.status_code}")
                print(f"🤖 Model loaded: {model_loaded}")
                
                if model_loaded:
                    print("\n🎉 SUCCESS! CLOUD API IS WORKING!")
                    print("✅ Model loaded successfully")
                    print("🌍 Your app now works WITHOUT laptop!")
                    return True
                else:
                    print("⏳ API responding but model still loading...")
            else:
                print(f"⏳ Deployment in progress... Status: {response.status_code}")
                
        except Exception as e:
            print(f"⏳ Deployment in progress... ({e})")
        
        if attempt < max_attempts - 1:
            print("   Waiting 30 seconds before next check...")
            time.sleep(30)
    
    print("\n⏰ Deployment monitoring timeout")
    print("💡 Deployment may still be in progress - check manually later")
    return False

def test_global_access():
    """Test if the app works globally"""
    
    print("\n🌍 Testing global access...")
    
    try:
        # Test health endpoint
        health_response = requests.get(
            'https://rice-disease-detection-app-1.onrender.com/health',
            timeout=30
        )
        
        if health_response.status_code != 200:
            print("❌ Health endpoint failed")
            return False
        
        health_data = health_response.json()
        if not health_data.get('model_loaded', False):
            print("❌ Model not loaded")
            return False
        
        # Test model info endpoint
        model_response = requests.get(
            'https://rice-disease-detection-app-1.onrender.com/model-info',
            timeout=30
        )
        
        if model_response.status_code != 200:
            print("❌ Model info endpoint failed")
            return False
        
        # Test diseases endpoint
        diseases_response = requests.get(
            'https://rice-disease-detection-app-1.onrender.com/diseases',
            timeout=30
        )
        
        if diseases_response.status_code != 200:
            print("❌ Diseases endpoint failed")
            return False
        
        print("✅ All endpoints working!")
        print("🎉 GLOBAL ACCESS CONFIRMED!")
        return True
        
    except Exception as e:
        print(f"❌ Global access test failed: {e}")
        return False

def main():
    print("🌍 FIXING CLOUD DEPLOYMENT FOR GLOBAL ACCESS")
    print("=" * 60)
    print("This will make your app work WITHOUT your laptop!")
    print()
    
    # Step 1: Verify model file
    if not check_model_file():
        print("❌ Model file issues detected. Please check your model file.")
        return
    
    # Step 2: Update API for cloud deployment
    update_api_for_render()
    
    # Step 3: Create startup script
    create_startup_script()
    
    # Step 4: Update Render configuration
    update_render_config()
    
    # Step 5: Commit and deploy
    if not commit_and_deploy():
        print("❌ Failed to push changes. Please check git configuration.")
        return
    
    # Step 6: Monitor deployment
    deployment_success = monitor_deployment()
    
    # Step 7: Test global access
    if deployment_success:
        global_success = test_global_access()
        
        if global_success:
            print("\n🎊 MISSION ACCOMPLISHED!")
            print("=" * 60)
            print("✅ Your Rice Disease Detection app now works GLOBALLY!")
            print("✅ No laptop required for farmers to use it")
            print("✅ 24/7 availability worldwide")
            print("✅ Cloud API with AI model fully operational")
            print()
            print("📱 NEXT STEPS:")
            print("1. flutter run (test on your device)")
            print("2. flutter build apk --release")
            print("3. Share APK with farmers worldwide")
            print("4. Turn off your laptop - app will still work! 🎉")
            
        else:
            print("\n⚠️ Deployment completed but some issues remain")
            print("💡 Your app has smart fallback and will work when cloud is ready")
    
    else:
        print("\n⏰ Deployment taking longer than expected")
        print("💡 Check Render.com dashboard for detailed logs")
        print("🔧 Your app will automatically work when deployment completes")

if __name__ == "__main__":
    main()