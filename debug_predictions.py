#!/usr/bin/env python3
"""
Debug script to check model predictions and class mappings
"""

import tensorflow as tf
import numpy as np
from PIL import Image
import requests
import json

# Current class names in API
current_class_names = [
    'Bacterial Leaf Blight',
    'Brown Spot',
    'Healthy Rice Leaf', 
    'Leaf Blast',
    'Leaf scald',
    'Narrow Brown Leaf Spot',
    'Rice Hispa',
    'Sheath Blight',
    'Unknown/Other'
]

# Common rice disease class orders from different datasets
possible_class_orders = [
    # Order 1: Alphabetical
    ['Bacterial Leaf Blight', 'Brown Spot', 'Healthy Rice Leaf', 'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Sheath Blight', 'Unknown'],
    
    # Order 2: Healthy first
    ['Healthy Rice Leaf', 'Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Sheath Blight', 'Unknown'],
    
    # Order 3: Disease severity order
    ['Leaf Blast', 'Bacterial Leaf Blight', 'Sheath Blight', 'Brown Spot', 'Narrow Brown Leaf Spot', 'Leaf scald', 'Rice Hispa', 'Healthy Rice Leaf', 'Unknown'],
    
    # Order 4: Common kaggle dataset order
    ['Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Sheath Blight', 'Healthy Rice Leaf', 'Unknown']
]

def load_and_test_model():
    """Load model and test with different scenarios"""
    print("🔍 Debugging Model Predictions...")
    print("=" * 60)
    
    # Load model
    model = tf.keras.models.load_model('rice_emergency_model.h5')
    print(f"✅ Model loaded: {model.output_shape}")
    
    # Test 1: Create a "healthy" looking image (green)
    print("\n1️⃣ Testing with healthy-looking image (green)...")
    healthy_image = create_healthy_image()
    predictions = predict_image(model, healthy_image)
    print(f"Predictions: {predictions}")
    print(f"Top class index: {np.argmax(predictions)}")
    print(f"Current mapping: {current_class_names[np.argmax(predictions)]}")
    print(f"Confidence: {np.max(predictions):.3f}")
    
    # Test 2: Create a "diseased" looking image (brown/yellow)
    print("\n2️⃣ Testing with diseased-looking image (brown)...")
    diseased_image = create_diseased_image()
    predictions = predict_image(model, diseased_image)
    print(f"Predictions: {predictions}")
    print(f"Top class index: {np.argmax(predictions)}")
    print(f"Current mapping: {current_class_names[np.argmax(predictions)]}")
    print(f"Confidence: {np.max(predictions):.3f}")
    
    # Test 3: Show all prediction distributions
    print("\n3️⃣ Detailed prediction analysis...")
    for i, (name, conf) in enumerate(zip(current_class_names, predictions)):
        print(f"Class {i}: {name:<25} = {conf:.6f}")
    
    # Test 4: Try different class orders
    print("\n4️⃣ Testing possible class orders...")
    for order_idx, class_order in enumerate(possible_class_orders):
        if len(class_order) == 9:
            predicted_class = class_order[np.argmax(predictions)]
            print(f"Order {order_idx + 1}: {predicted_class}")
    
    return predictions

def create_healthy_image():
    """Create a green healthy-looking rice leaf image"""
    # Green color typical of healthy rice leaves
    image = Image.new('RGB', (224, 224), color=(34, 139, 34))  # Forest green
    
    # Add some natural variation
    img_array = np.array(image)
    
    # Add lighter green patches
    for i in range(0, 224, 30):
        for j in range(0, 224, 30):
            if (i + j) % 60 == 0:
                img_array[i:i+15, j:j+15] = [50, 160, 50]  # Lighter green
    
    return Image.fromarray(img_array.astype('uint8'))

def create_diseased_image():
    """Create a brown/yellow diseased-looking image"""
    # Brown/yellow color typical of diseased rice leaves
    image = Image.new('RGB', (224, 224), color=(139, 119, 34))  # Brown/yellow
    
    # Add some variation
    img_array = np.array(image)
    
    # Add darker brown spots
    for i in range(0, 224, 25):
        for j in range(0, 224, 25):
            if (i + j) % 50 == 0:
                img_array[i:i+12, j:j+12] = [101, 67, 33]  # Dark brown
    
    return Image.fromarray(img_array.astype('uint8'))

def predict_image(model, image):
    """Predict on an image using the same preprocessing as API"""
    # Convert to RGB if needed
    if image.mode != 'RGB':
        image = image.convert('RGB')
    
    # Resize to 224x224
    image = image.resize((224, 224))
    
    # Convert to numpy array
    image_array = np.array(image, dtype=np.float32)
    
    # Apply same preprocessing as API
    image_array = image_array / 255.0  # rescale=1./255
    
    # Add batch dimension
    image_array = np.expand_dims(image_array, axis=0)
    
    # Predict
    predictions = model.predict(image_array, verbose=0)[0]
    
    return predictions

def test_api_consistency():
    """Test if API gives same results as direct model"""
    print("\n5️⃣ Testing API consistency...")
    
    # Create test image
    test_image = create_healthy_image()
    test_image.save('debug_test.jpg', 'JPEG')
    
    # Test via API
    try:
        url = "http://localhost:5000/predict"
        with open('debug_test.jpg', 'rb') as f:
            files = {'image': f}
            response = requests.post(url, files=files, timeout=10)
        
        if response.status_code == 200:
            api_result = response.json()
            print(f"✅ API Result: {api_result['prediction']['disease']}")
            print(f"✅ API Confidence: {api_result['prediction']['confidence']:.3f}")
            
            # Compare with direct model prediction
            model = tf.keras.models.load_model('rice_emergency_model.h5')
            direct_predictions = predict_image(model, test_image)
            direct_class = current_class_names[np.argmax(direct_predictions)]
            
            print(f"🔄 Direct Model: {direct_class}")
            print(f"🔄 Direct Confidence: {np.max(direct_predictions):.3f}")
            
            if api_result['prediction']['disease'] == direct_class:
                print("✅ API and direct model match!")
            else:
                print("❌ API and direct model don't match!")
                
        else:
            print(f"❌ API Error: {response.status_code}")
            
    except Exception as e:
        print(f"❌ API Test failed: {e}")
    
    # Clean up
    import os
    if os.path.exists('debug_test.jpg'):
        os.remove('debug_test.jpg')

if __name__ == "__main__":
    predictions = load_and_test_model()
    test_api_consistency()
    
    print("\n" + "=" * 60)
    print("🎯 Debug Analysis Complete!")
    print("\n💡 Recommendations:")
    print("1. Check if 'Healthy Rice Leaf' should be at index 2 or different position")
    print("2. Verify class order matches your Kaggle training data")
    print("3. Test with real rice leaf photos to validate predictions")