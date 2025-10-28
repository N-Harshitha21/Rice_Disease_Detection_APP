#!/usr/bin/env python3
"""
Simulate what happens when real photos are uploaded via Flutter app
"""

import requests
import json
import base64
from PIL import Image, ImageDraw
import io
import numpy as np

def create_realistic_test_images():
    """Create test images that simulate real-world scenarios"""
    
    # 1. Human face simulation (should NOT be rice)
    print("1️⃣ Creating human face simulation...")
    human_img = Image.new('RGB', (400, 400), color=(220, 180, 140))  # Skin color
    draw = ImageDraw.Draw(human_img)
    # Add face features
    draw.ellipse([150, 120, 250, 180], fill=(200, 150, 120))  # Face shape
    draw.ellipse([170, 140, 180, 150], fill=(50, 50, 50))     # Left eye
    draw.ellipse([200, 140, 210, 150], fill=(50, 50, 50))     # Right eye
    draw.ellipse([185, 160, 195, 170], fill=(150, 100, 80))   # Nose
    human_img.save('test_human.jpg', 'JPEG', quality=85)
    
    # 2. Healthy rice leaf simulation
    print("2️⃣ Creating healthy rice leaf simulation...")
    healthy_img = Image.new('RGB', (400, 400), color=(50, 150, 50))  # Green base
    draw = ImageDraw.Draw(healthy_img)
    # Add leaf veins
    for i in range(50, 350, 20):
        draw.line([(i, 50), (i, 350)], fill=(40, 130, 40), width=2)
    # Add horizontal veins
    for j in range(100, 300, 30):
        draw.line([(50, j), (350, j)], fill=(45, 140, 45), width=1)
    healthy_img.save('test_healthy_leaf.jpg', 'JPEG', quality=85)
    
    # 3. Diseased rice leaf simulation
    print("3️⃣ Creating diseased rice leaf simulation...")
    diseased_img = Image.new('RGB', (400, 400), color=(120, 100, 60))  # Brown base
    draw = ImageDraw.Draw(diseased_img)
    # Add disease spots
    for i in range(5):
        x = np.random.randint(50, 350)
        y = np.random.randint(50, 350)
        draw.ellipse([x-15, y-15, x+15, y+15], fill=(80, 40, 20))
    diseased_img.save('test_diseased_leaf.jpg', 'JPEG', quality=85)
    
    return ['test_human.jpg', 'test_healthy_leaf.jpg', 'test_diseased_leaf.jpg']

def test_image_via_api(image_path, description):
    """Test an image through the API exactly like Flutter would"""
    print(f"\n🔍 Testing {description}...")
    print(f"📁 File: {image_path}")
    
    try:
        # Method 1: File upload (like Flutter MultipartFile)
        print("📤 Testing via file upload...")
        url = "http://localhost:5000/predict"
        
        with open(image_path, 'rb') as f:
            files = {'image': f}
            response = requests.post(url, files=files, timeout=20)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Prediction: {result['prediction']['disease']}")
            print(f"✅ Confidence: {result['prediction']['confidence']:.3f}")
            print(f"✅ Type: {result['prediction']['disease_type']}")
            
            # Check if result makes sense
            if description == "human face" and "healthy" not in result['prediction']['disease'].lower():
                print("⚠️  Warning: Human face detected as rice disease!")
            elif description == "healthy rice leaf" and "healthy" in result['prediction']['disease'].lower():
                print("🎉 Correct: Healthy leaf detected as healthy!")
            elif description == "diseased rice leaf" and "healthy" not in result['prediction']['disease'].lower():
                print("🎉 Correct: Diseased leaf detected as disease!")
            
            print("📊 Top 3 predictions:")
            for pred in result['top_predictions'][:3]:
                print(f"   - {pred['disease']}: {pred['confidence']:.3f}")
                
        else:
            print(f"❌ API Error: {response.status_code}")
            print(f"Response: {response.text}")
        
        # Method 2: Base64 upload (alternative Flutter method)
        print("📤 Testing via base64...")
        with open(image_path, 'rb') as f:
            image_data = f.read()
            base64_data = base64.b64encode(image_data).decode('utf-8')
        
        url = "http://localhost:5000/predict"
        headers = {'Content-Type': 'application/json'}
        data = {'image_base64': base64_data}
        
        response = requests.post(url, headers=headers, json=data, timeout=20)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Base64 Prediction: {result['prediction']['disease']}")
            print(f"✅ Base64 Confidence: {result['prediction']['confidence']:.3f}")
        else:
            print(f"❌ Base64 Error: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Exception: {e}")

def analyze_image_properties(image_path):
    """Analyze image properties that might affect prediction"""
    print(f"\n📊 Analyzing {image_path}...")
    
    with Image.open(image_path) as img:
        print(f"📏 Size: {img.size}")
        print(f"🎨 Mode: {img.mode}")
        print(f"📁 Format: {img.format}")
        
        # Convert to RGB and resize like the API does
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        img_resized = img.resize((224, 224))
        img_array = np.array(img_resized, dtype=np.float32)
        
        print(f"📈 Pixel value ranges:")
        print(f"   Red: {img_array[:,:,0].min():.1f} - {img_array[:,:,0].max():.1f}")
        print(f"   Green: {img_array[:,:,1].min():.1f} - {img_array[:,:,1].max():.1f}")
        print(f"   Blue: {img_array[:,:,2].min():.1f} - {img_array[:,:,2].max():.1f}")
        
        # Check if image is predominantly green (healthy rice)
        avg_green = img_array[:,:,1].mean()
        avg_red = img_array[:,:,0].mean()
        avg_blue = img_array[:,:,2].mean()
        
        if avg_green > avg_red and avg_green > avg_blue:
            print("🟢 Image is predominantly green")
        elif avg_red > avg_green and avg_red > avg_blue:
            print("🔴 Image is predominantly red")
        else:
            print("🟤 Image has mixed colors")

def main():
    print("🔍 Testing Real Photo Scenarios...")
    print("=" * 60)
    
    # Create test images
    test_images = create_realistic_test_images()
    
    descriptions = [
        "human face",
        "healthy rice leaf", 
        "diseased rice leaf"
    ]
    
    # Test each image
    for img_path, desc in zip(test_images, descriptions):
        analyze_image_properties(img_path)
        test_image_via_api(img_path, desc)
        print("-" * 40)
    
    # Clean up
    import os
    for img_path in test_images:
        if os.path.exists(img_path):
            os.remove(img_path)
            print(f"🗑️ Deleted {img_path}")
    
    print("\n" + "=" * 60)
    print("🎯 Real Photo Test Complete!")
    
    print("\n💡 If all images predict as Rice Hispa:")
    print("1. Model may be overtrained on Rice Hispa")
    print("2. Training data was imbalanced")
    print("3. Model expects different image characteristics")
    print("4. Need to retrain with balanced dataset")

if __name__ == "__main__":
    main()