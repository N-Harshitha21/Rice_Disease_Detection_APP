#!/usr/bin/env python3
"""
Test API with correct understanding of class mapping
"""

import requests
import json
from PIL import Image
import numpy as np

def create_healthy_rice_image():
    """Create a healthy-looking rice leaf image"""
    # Create a green healthy image
    img = Image.new('RGB', (300, 300), color=(0, 128, 0))
    img_array = np.array(img)
    
    # Add some leaf-like patterns
    for i in range(50, 250, 25):
        img_array[i:i+3, :] = [0, 150, 0]  # Leaf veins
        
    for j in range(50, 250, 40):
        img_array[:, j:j+2] = [0, 140, 0]  # Cross veins
    
    return Image.fromarray(img_array.astype('uint8'))

def create_diseased_rice_image():
    """Create a diseased-looking rice leaf image"""
    # Create a brown/spotted diseased image
    img = Image.new('RGB', (300, 300), color=(139, 69, 19))
    img_array = np.array(img)
    
    # Add disease spots
    for i in range(30, 270, 40):
        for j in range(30, 270, 40):
            img_array[i:i+15, j:j+15] = [60, 30, 10]  # Dark disease spots
            
    # Add some yellow/brown patches
    for i in range(60, 240, 60):
        for j in range(60, 240, 60):
            img_array[i:i+20, j:j+20] = [160, 130, 50]  # Yellow patches
    
    return Image.fromarray(img_array.astype('uint8'))

def test_api_predictions():
    """Test API with healthy and diseased images"""
    print("🔍 Testing API with Correct Expectations...")
    print("=" * 60)
    
    # Test 1: Healthy image
    print("1️⃣ Testing with healthy rice leaf image...")
    healthy_img = create_healthy_rice_image()
    healthy_img.save('test_healthy.jpg', 'JPEG', quality=90)
    
    try:
        url = "http://localhost:5000/predict"
        with open('test_healthy.jpg', 'rb') as f:
            files = {'image': f}
            response = requests.post(url, files=files, timeout=15)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Prediction: {result['prediction']['disease']}")
            print(f"✅ Confidence: {result['prediction']['confidence']:.3f}")
            print(f"✅ Confidence Level: {result['prediction']['confidence_level']}")
            
            if 'healthy' in result['prediction']['disease'].lower():
                print("🎉 CORRECT! Healthy image detected as healthy!")
            else:
                print("❌ WRONG! Healthy image detected as disease")
                
            print("📊 Top 3 predictions:")
            for pred in result['top_predictions'][:3]:
                print(f"   - {pred['disease']}: {pred['confidence']:.3f}")
                
        else:
            print(f"❌ API Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Exception: {e}")
    
    # Test 2: Diseased image
    print(f"\n2️⃣ Testing with diseased rice leaf image...")
    diseased_img = create_diseased_rice_image()
    diseased_img.save('test_diseased.jpg', 'JPEG', quality=90)
    
    try:
        url = "http://localhost:5000/predict"
        with open('test_diseased.jpg', 'rb') as f:
            files = {'image': f}
            response = requests.post(url, files=files, timeout=15)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Prediction: {result['prediction']['disease']}")
            print(f"✅ Confidence: {result['prediction']['confidence']:.3f}")
            print(f"✅ Confidence Level: {result['prediction']['confidence_level']}")
            
            if 'healthy' not in result['prediction']['disease'].lower():
                print("🎉 CORRECT! Diseased image detected as disease!")
            else:
                print("❌ WRONG! Diseased image detected as healthy")
                
            print("📊 Top 3 predictions:")
            for pred in result['top_predictions'][:3]:
                print(f"   - {pred['disease']}: {pred['confidence']:.3f}")
                
        else:
            print(f"❌ API Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Exception: {e}")
    
    # Test 3: Check all disease info
    print(f"\n3️⃣ Checking disease information...")
    try:
        url = "http://localhost:5000/diseases"
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Total diseases: {len(result['diseases'])}")
            
            healthy_count = 0
            disease_count = 0
            
            for disease in result['diseases']:
                if disease['type'] == 'healthy':
                    healthy_count += 1
                    print(f"🟢 {disease['name']} (Healthy)")
                else:
                    disease_count += 1
                    print(f"🔴 {disease['name']} (Disease)")
            
            print(f"\n📈 Summary: {healthy_count} healthy, {disease_count} disease classes")
            
    except Exception as e:
        print(f"❌ Disease info failed: {e}")
    
    # Clean up
    import os
    for file in ['test_healthy.jpg', 'test_diseased.jpg']:
        if os.path.exists(file):
            os.remove(file)
    
    print(f"\n" + "=" * 60)
    print("🎯 API Prediction Test Complete!")

if __name__ == "__main__":
    test_api_predictions()