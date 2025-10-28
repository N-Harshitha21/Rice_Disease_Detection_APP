#!/usr/bin/env python3
"""
Test the backend with a real image to verify prediction works
"""

import requests
import json
from PIL import Image
import numpy as np
import os

def create_test_rice_image():
    """Create a simple RGB test image that should work"""
    # Create a 224x224 RGB image with some green colors (like rice leaves)
    image = Image.new('RGB', (224, 224), color=(50, 150, 50))  # Green color
    
    # Add some variation to make it more realistic
    img_array = np.array(image)
    
    # Add some noise and patterns
    for i in range(0, 224, 20):
        for j in range(0, 224, 20):
            img_array[i:i+10, j:j+10] = [30, 120, 30]  # Darker green patches
    
    # Convert back to PIL image
    test_image = Image.fromarray(img_array.astype('uint8'))
    
    # Save as JPEG
    test_image.save('test_rice_leaf.jpg', 'JPEG', quality=85)
    return 'test_rice_leaf.jpg'

def test_prediction_api():
    """Test the prediction API with a real image"""
    print("🔍 Testing Backend Prediction API...")
    print("=" * 50)
    
    # Create test image
    print("1️⃣ Creating test rice leaf image...")
    image_path = create_test_rice_image()
    print(f"✅ Created: {image_path}")
    
    # Test file upload prediction
    print("\n2️⃣ Testing file upload prediction...")
    try:
        url = "http://localhost:5000/predict"
        
        with open(image_path, 'rb') as f:
            files = {'image': f}
            response = requests.post(url, files=files, timeout=30)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Prediction Success!")
            print(f"✅ Disease: {result['prediction']['disease']}")
            print(f"✅ Confidence: {result['prediction']['confidence']:.3f}")
            print(f"✅ Confidence Level: {result['prediction']['confidence_level']}")
            print(f"✅ Treatment: {result['prediction']['treatment'][:60]}...")
            
            print("\n📊 Top 3 predictions:")
            for pred in result['top_predictions'][:3]:
                print(f"   - {pred['disease']}: {pred['confidence']:.3f}")
                
        else:
            print(f"❌ Request failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Exception: {e}")
    
    # Test base64 prediction
    print("\n3️⃣ Testing base64 prediction...")
    try:
        import base64
        
        with open(image_path, 'rb') as f:
            image_data = f.read()
            base64_data = base64.b64encode(image_data).decode('utf-8')
        
        url = "http://localhost:5000/predict"
        headers = {'Content-Type': 'application/json'}
        data = {'image_base64': base64_data}
        
        response = requests.post(url, headers=headers, json=data, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Base64 Prediction Success!")
            print(f"✅ Disease: {result['prediction']['disease']}")
            print(f"✅ Confidence: {result['prediction']['confidence']:.3f}")
        else:
            print(f"❌ Base64 request failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Base64 Exception: {e}")
    
    # Clean up
    print("\n4️⃣ Cleaning up...")
    if os.path.exists(image_path):
        os.remove(image_path)
        print(f"✅ Deleted: {image_path}")
    
    print("\n" + "=" * 50)
    print("🎯 Backend API Test Complete!")

if __name__ == "__main__":
    test_prediction_api()