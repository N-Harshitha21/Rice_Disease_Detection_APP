#!/usr/bin/env python3
"""
Debug the exact connection between Flutter and backend
"""

import requests
import json
import base64
from datetime import datetime

def test_all_endpoints():
    """Test all API endpoints that Flutter uses"""
    print("🔍 Testing Flutter API Endpoints...")
    print("=" * 60)
    
    base_url = "http://192.168.182.140:5000"
    
    # Test 1: Health endpoint
    print("1️⃣ Testing /health endpoint...")
    try:
        response = requests.get(f"{base_url}/health", timeout=10)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Model loaded: {data.get('model_loaded')}")
            print(f"✅ Classes: {data.get('num_classes')}")
            print(f"✅ Status: {data.get('status')}")
        else:
            print(f"❌ Error: {response.text}")
    except Exception as e:
        print(f"❌ Health check failed: {e}")
    
    # Test 2: Diseases endpoint
    print("\n2️⃣ Testing /diseases endpoint...")
    try:
        response = requests.get(f"{base_url}/diseases", timeout=10)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            diseases = data.get('diseases', [])
            print(f"✅ Total diseases: {len(diseases)}")
            for disease in diseases:
                print(f"   - {disease['name']} ({disease['type']})")
        else:
            print(f"❌ Error: {response.text}")
    except Exception as e:
        print(f"❌ Diseases check failed: {e}")
    
    # Test 3: Model info endpoint
    print("\n3️⃣ Testing /model-info endpoint...")
    try:
        response = requests.get(f"{base_url}/model-info", timeout=10)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            model_info = data.get('model_info', {})
            print(f"✅ Architecture: {model_info.get('architecture')}")
            print(f"✅ Classes: {model_info.get('num_classes')}")
            print(f"✅ Input size: {model_info.get('input_size')}")
        else:
            print(f"❌ Error: {response.text}")
    except Exception as e:
        print(f"❌ Model info failed: {e}")

def test_prediction_methods():
    """Test both prediction methods Flutter might use"""
    print("\n4️⃣ Testing Prediction Methods...")
    print("-" * 40)
    
    base_url = "http://192.168.182.140:5000"
    
    # Method 1: Multipart file upload (like Flutter MultipartFile)
    print("📤 Method 1: Multipart file upload...")
    try:
        with open('healthy_rice_leaf.jpg', 'rb') as f:
            files = {'image': f}
            headers = {}  # Let requests set the content-type
            response = requests.post(f"{base_url}/predict", files=files, headers=headers, timeout=30)
        
        print(f"Status: {response.status_code}")
        print(f"Headers sent: multipart/form-data")
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Prediction: {result['prediction']['disease']}")
            print(f"✅ Confidence: {result['prediction']['confidence']:.3f}")
            print(f"✅ Success: {result.get('success')}")
        else:
            print(f"❌ Error: {response.text}")
            
    except Exception as e:
        print(f"❌ Multipart upload failed: {e}")
    
    # Method 2: Base64 JSON (alternative Flutter method)
    print("\n📤 Method 2: Base64 JSON...")
    try:
        with open('healthy_rice_leaf.jpg', 'rb') as f:
            image_data = f.read()
            base64_data = base64.b64encode(image_data).decode('utf-8')
        
        headers = {'Content-Type': 'application/json'}
        data = {'image_base64': base64_data}
        
        response = requests.post(f"{base_url}/predict", headers=headers, json=data, timeout=30)
        
        print(f"Status: {response.status_code}")
        print(f"Headers sent: application/json")
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Prediction: {result['prediction']['disease']}")
            print(f"✅ Confidence: {result['prediction']['confidence']:.3f}")
            print(f"✅ Success: {result.get('success')}")
        else:
            print(f"❌ Error: {response.text}")
            
    except Exception as e:
        print(f"❌ Base64 upload failed: {e}")

def simulate_flutter_request():
    """Simulate exactly what Flutter sends"""
    print("\n5️⃣ Simulating Exact Flutter Request...")
    print("-" * 40)
    
    base_url = "http://192.168.182.140:5000"
    
    try:
        # Read the image
        with open('healthy_rice_leaf.jpg', 'rb') as f:
            image_data = f.read()
        
        # Create the exact request Flutter would make
        files = {'image': ('healthy_rice_leaf.jpg', image_data, 'image/jpeg')}
        
        # Add headers that Flutter typically sends
        headers = {
            'User-Agent': 'Dart/3.0 (dart:io)',
            'Accept': 'application/json',
        }
        
        print("🔄 Sending request with Flutter-like headers...")
        response = requests.post(f"{base_url}/predict", files=files, headers=headers, timeout=30)
        
        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"\n✅ FLUTTER SIMULATION SUCCESS!")
            print(f"✅ Disease: {result['prediction']['disease']}")
            print(f"✅ Confidence: {result['prediction']['confidence']:.3f}")
            print(f"✅ Confidence Level: {result['prediction']['confidence_level']}")
            print(f"✅ Disease Type: {result['prediction']['disease_type']}")
            print(f"✅ Treatment: {result['prediction']['treatment'][:50]}...")
            
            print(f"\n📊 Top Predictions:")
            for i, pred in enumerate(result['top_predictions'][:3]):
                print(f"   {i+1}. {pred['disease']}: {pred['confidence']:.3f}")
                
        else:
            print(f"❌ FLUTTER SIMULATION FAILED!")
            print(f"❌ Status: {response.status_code}")
            print(f"❌ Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Flutter simulation error: {e}")

def check_backend_logs():
    """Check what the backend is actually receiving"""
    print("\n6️⃣ Backend Request Logging...")
    print("-" * 40)
    print("👀 Check your backend console for request logs when you test in Flutter app")
    print("🔍 Look for:")
    print("   - POST /predict requests")
    print("   - Any error messages")
    print("   - Processing time")
    print("   - Response data")

def test_image_consistency():
    """Test if same image gives consistent results"""
    print("\n7️⃣ Testing Image Consistency...")
    print("-" * 40)
    
    base_url = "http://192.168.182.140:5000"
    
    predictions = []
    
    for i in range(3):
        try:
            with open('healthy_rice_leaf.jpg', 'rb') as f:
                files = {'image': f}
                response = requests.post(f"{base_url}/predict", files=files, timeout=20)
            
            if response.status_code == 200:
                result = response.json()
                disease = result['prediction']['disease']
                confidence = result['prediction']['confidence']
                predictions.append((disease, confidence))
                print(f"Test {i+1}: {disease} ({confidence:.3f})")
            else:
                print(f"Test {i+1}: Error {response.status_code}")
                
        except Exception as e:
            print(f"Test {i+1}: Exception {e}")
    
    # Check consistency
    if len(predictions) > 0:
        first_disease = predictions[0][0]
        consistent = all(pred[0] == first_disease for pred in predictions)
        
        if consistent:
            print(f"✅ Consistent predictions: {first_disease}")
        else:
            print(f"❌ Inconsistent predictions: {predictions}")

def main():
    print("🔍 Complete Flutter-Backend Connection Diagnosis")
    print("=" * 60)
    print(f"⏰ Test started at: {datetime.now()}")
    
    test_all_endpoints()
    test_prediction_methods()
    simulate_flutter_request()
    test_image_consistency()
    check_backend_logs()
    
    print(f"\n" + "=" * 60)
    print("🎯 Diagnosis Complete!")
    print("\n📋 Summary:")
    print("1. All API endpoints should return 200 status")
    print("2. Predictions should be consistent")
    print("3. Both multipart and base64 methods should work")
    print("4. Flutter simulation should match direct API calls")
    print("\n💡 If there are discrepancies, the issue is in the connection layer!")

if __name__ == "__main__":
    main()