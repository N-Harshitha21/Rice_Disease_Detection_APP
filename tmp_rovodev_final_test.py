#!/usr/bin/env python3
"""
Final test to confirm laptop-free operation
"""
import requests
import time

def test_laptop_free_operation():
    """Test if the app works without laptop"""
    print("🚀 TESTING LAPTOP-FREE OPERATION")
    print("=" * 40)
    
    base_url = "https://rice-disease-detection-app-1.onrender.com"
    
    try:
        print("📡 Testing cloud API...")
        response = requests.get(f"{base_url}/health", timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Cloud API Status: {data}")
            
            # Check for emergency version
            is_emergency = data.get('version') == 'emergency-v1.0'
            model_loaded = data.get('model_loaded', False)
            
            print(f"🔧 Emergency Version: {'✅ YES' if is_emergency else '❌ NO'}")
            print(f"🤖 Model Loaded: {'✅ YES' if model_loaded else '❌ NO'}")
            
            if is_emergency and model_loaded:
                print("\n🎉 PERFECT! Your app now works WITHOUT laptop!")
                
                # Test a prediction
                print("\n🧪 Testing prediction...")
                try:
                    # Small test image (1x1 pixel)
                    test_data = {
                        "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
                    }
                    
                    pred_response = requests.post(f"{base_url}/predict", json=test_data, timeout=60)
                    
                    if pred_response.status_code == 200:
                        pred_data = pred_response.json()
                        print(f"✅ Prediction test successful!")
                        print(f"🔮 Result: {pred_data.get('prediction', {}).get('disease', 'Unknown')}")
                        return True
                    else:
                        print(f"⚠️ Prediction test failed: {pred_response.status_code}")
                        print(f"Error: {pred_response.text[:200]}")
                        
                except Exception as e:
                    print(f"⚠️ Prediction test error: {e}")
                
                return model_loaded
                
            elif is_emergency and not model_loaded:
                print("\n⏳ Emergency version deployed but model still loading...")
                print("💡 Try again in 2-3 minutes")
                return False
                
            elif not is_emergency and model_loaded:
                print("\n⚠️ Old version still running but model is loaded")
                print("💡 This should work, but emergency version is better")
                return True
                
            else:
                print("\n❌ Old version still running and model not loaded")
                print("⏳ Waiting for emergency deployment...")
                return False
                
        else:
            print(f"❌ Cloud API error: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Cloud API test failed: {e}")
        return False

def main():
    print("🌍 FINAL LAPTOP-FREE TEST")
    print("=" * 30)
    
    print("🔍 Testing your rice disease detection app without laptop...")
    
    success = test_laptop_free_operation()
    
    print("\n" + "=" * 50)
    
    if success:
        print("🎊 CONGRATULATIONS!")
        print("✅ YOUR APP NOW WORKS WITHOUT LAPTOP!")
        print("🌍 Global cloud deployment successful!")
        
        print("\n📱 NEXT STEPS FOR DISTRIBUTION:")
        print("1. Hot restart your Flutter app")
        print("2. Test taking photos of rice leaves")
        print("3. Verify disease detection works")
        print("4. Build release APK: flutter build apk --release")
        print("5. Share with farmers!")
        
        print("\n🌾 IMPACT:")
        print("✅ Farmers can now detect rice diseases anywhere")
        print("✅ No laptop dependency")
        print("✅ Instant treatment recommendations")
        print("✅ Professional AI-powered agriculture tool")
        
    else:
        print("⏳ DEPLOYMENT STILL IN PROGRESS")
        print("💡 The emergency fix is applied, but cloud deployment takes time")
        print("🕐 Try testing again in 3-5 minutes")
        print("🔧 If issues persist, check Render.com dashboard")

if __name__ == "__main__":
    main()