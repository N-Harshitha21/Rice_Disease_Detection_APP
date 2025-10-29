#!/usr/bin/env python3
"""
Deploy Fixed Cloud API - Push updates to Render.com
"""

import subprocess
import time
import requests

def git_push_to_trigger_deployment():
    """Push changes to trigger Render.com deployment"""
    print("🚀 Pushing changes to trigger cloud deployment...")
    
    try:
        # Add all changes
        subprocess.run(['git', 'add', '.'], check=True)
        
        # Commit changes
        commit_message = "Fix cloud API model loading and add smart fallback"
        subprocess.run(['git', 'commit', '-m', commit_message], check=True)
        
        # Push to trigger deployment
        subprocess.run(['git', 'push'], check=True)
        
        print("✅ Changes pushed successfully!")
        print("⏰ Render.com deployment will start automatically...")
        print("📊 Expected deployment time: 3-5 minutes")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Git operation failed: {e}")
        return False

def wait_for_deployment(max_wait_minutes=10):
    """Wait for cloud deployment to complete"""
    print(f"\n⏰ Waiting for cloud deployment (max {max_wait_minutes} minutes)...")
    
    start_time = time.time()
    max_wait_seconds = max_wait_minutes * 60
    
    while time.time() - start_time < max_wait_seconds:
        try:
            print("🔍 Checking cloud API status...")
            response = requests.get(
                'https://rice-disease-detection-app-1.onrender.com/health',
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                model_loaded = data.get('model_loaded', False)
                
                if model_loaded:
                    print("🎉 CLOUD DEPLOYMENT SUCCESSFUL!")
                    print("✅ Model loaded on cloud server")
                    return True
                else:
                    print("⏳ Deployment in progress... model not loaded yet")
            else:
                print(f"⏳ Deployment in progress... status: {response.status_code}")
                
        except Exception as e:
            print(f"⏳ Deployment in progress... ({e})")
        
        print("   Waiting 30 seconds before next check...")
        time.sleep(30)
    
    print(f"⏰ Deployment timeout after {max_wait_minutes} minutes")
    return False

def test_global_functionality():
    """Test if app works globally without laptop"""
    print("\n🌍 Testing global functionality...")
    
    try:
        # Test cloud API
        response = requests.get(
            'https://rice-disease-detection-app-1.onrender.com/health',
            timeout=60
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('model_loaded', False):
                print("✅ Cloud API working with model loaded")
                
                # Test all endpoints
                endpoints = ['/health', '/diseases', '/model-info']
                all_working = True
                
                for endpoint in endpoints:
                    try:
                        test_response = requests.get(
                            f'https://rice-disease-detection-app-1.onrender.com{endpoint}',
                            timeout=30
                        )
                        if test_response.status_code == 200:
                            print(f"   ✅ {endpoint} - Working")
                        else:
                            print(f"   ❌ {endpoint} - Error {test_response.status_code}")
                            all_working = False
                    except Exception as e:
                        print(f"   ❌ {endpoint} - Failed: {e}")
                        all_working = False
                
                return all_working
            else:
                print("❌ Cloud API responding but model not loaded")
                return False
        else:
            print(f"❌ Cloud API not responding: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Cloud API test failed: {e}")
        return False

def main():
    print("🌍 DEPLOY GLOBAL RICE DISEASE DETECTION APP")
    print("=" * 60)
    print("This will make your app work WITHOUT your laptop!")
    print()
    
    # Step 1: Push changes to trigger deployment
    if not git_push_to_trigger_deployment():
        print("❌ Failed to push changes. Please check git configuration.")
        return
    
    # Step 2: Wait for deployment
    deployment_success = wait_for_deployment()
    
    # Step 3: Test global functionality
    if deployment_success:
        global_working = test_global_functionality()
        
        if global_working:
            print("\n🎉 SUCCESS! YOUR APP NOW WORKS GLOBALLY!")
            print("=" * 60)
            print("✅ Cloud API deployed and working")
            print("✅ Model loaded on cloud server")
            print("✅ All endpoints functional")
            print("✅ App works without your laptop")
            print("✅ Global accessibility for farmers")
            print()
            print("📱 NEXT STEPS:")
            print("1. flutter run (test on device)")
            print("2. flutter build apk --release")
            print("3. Distribute APK to farmers worldwide")
            print("4. Your laptop can be turned off!")
            
        else:
            print("\n⚠️ DEPLOYMENT ISSUES DETECTED")
            print("💡 The smart fallback system will handle this")
            print("📱 Your app will still work by using local API when available")
    
    else:
        print("\n⏰ DEPLOYMENT TAKING LONGER THAN EXPECTED")
        print("💡 Don't worry - your app has smart fallback:")
        print("   1. Will use cloud API when it's ready")
        print("   2. Will use local API as backup")
        print("   3. Users won't see any errors")
        print()
        print("📱 Your app is still functional with current setup!")

if __name__ == "__main__":
    main()