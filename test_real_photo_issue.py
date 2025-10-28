#!/usr/bin/env python3
"""
Test why the model predicts Rice Hispa for everything
"""

import tensorflow as tf
import numpy as np
from PIL import Image
import requests

def test_different_images():
    """Test model with completely different types of images"""
    print("🔍 Testing Model Bias Issue...")
    print("=" * 60)
    
    model = tf.keras.models.load_model('rice_emergency_model.h5')
    
    # Test 1: Pure white image
    print("1️⃣ Testing pure white image...")
    white_img = Image.new('RGB', (224, 224), color=(255, 255, 255))
    pred = predict_image(model, white_img)
    print(f"Top prediction: {np.argmax(pred)} (confidence: {np.max(pred):.3f})")
    print(f"All predictions: {pred}")
    
    # Test 2: Pure black image
    print("\n2️⃣ Testing pure black image...")
    black_img = Image.new('RGB', (224, 224), color=(0, 0, 0))
    pred = predict_image(model, black_img)
    print(f"Top prediction: {np.argmax(pred)} (confidence: {np.max(pred):.3f})")
    
    # Test 3: Pure red image
    print("\n3️⃣ Testing pure red image...")
    red_img = Image.new('RGB', (224, 224), color=(255, 0, 0))
    pred = predict_image(model, red_img)
    print(f"Top prediction: {np.argmax(pred)} (confidence: {np.max(pred):.3f})")
    
    # Test 4: Random noise image
    print("\n4️⃣ Testing random noise image...")
    noise_array = np.random.randint(0, 256, (224, 224, 3), dtype=np.uint8)
    noise_img = Image.fromarray(noise_array)
    pred = predict_image(model, noise_img)
    print(f"Top prediction: {np.argmax(pred)} (confidence: {np.max(pred):.3f})")
    
    # Test 5: Check if all predictions are the same
    all_same = True
    first_pred = np.argmax(predict_image(model, white_img))
    
    for color in [(255, 255, 255), (0, 0, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255)]:
        img = Image.new('RGB', (224, 224), color=color)
        pred_idx = np.argmax(predict_image(model, img))
        if pred_idx != first_pred:
            all_same = False
            break
    
    if all_same:
        print(f"\n❌ PROBLEM FOUND: Model always predicts class {first_pred} (Rice Hispa)")
        print("This suggests:")
        print("1. Model is overfitted/biased")
        print("2. Wrong preprocessing")
        print("3. Model corrupted")
    else:
        print(f"\n✅ Model gives different predictions for different inputs")

def predict_image(model, image):
    """Predict with exact same preprocessing as API"""
    if image.mode != 'RGB':
        image = image.convert('RGB')
    
    image = image.resize((224, 224))
    image_array = np.array(image, dtype=np.float32)
    
    # Same preprocessing as API
    image_array = image_array / 255.0  # rescale=1./255
    image_array = np.expand_dims(image_array, axis=0)
    
    predictions = model.predict(image_array, verbose=0)[0]
    return predictions

def test_different_preprocessing():
    """Test if different preprocessing helps"""
    print("\n5️⃣ Testing different preprocessing methods...")
    
    model = tf.keras.models.load_model('rice_emergency_model.h5')
    test_img = Image.new('RGB', (224, 224), color=(0, 128, 0))  # Green
    
    # Method 1: Current (0-1 normalization)
    img_array = np.array(test_img.resize((224, 224)), dtype=np.float32)
    img_array = img_array / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    pred1 = model.predict(img_array, verbose=0)[0]
    print(f"Method 1 (0-1): Class {np.argmax(pred1)}, conf {np.max(pred1):.3f}")
    
    # Method 2: ImageNet normalization (-1 to 1)
    img_array = np.array(test_img.resize((224, 224)), dtype=np.float32)
    img_array = (img_array / 127.5) - 1.0
    img_array = np.expand_dims(img_array, axis=0)
    pred2 = model.predict(img_array, verbose=0)[0]
    print(f"Method 2 (-1,1): Class {np.argmax(pred2)}, conf {np.max(pred2):.3f}")
    
    # Method 3: No normalization (0-255)
    img_array = np.array(test_img.resize((224, 224)), dtype=np.float32)
    img_array = np.expand_dims(img_array, axis=0)
    pred3 = model.predict(img_array, verbose=0)[0]
    print(f"Method 3 (0-255): Class {np.argmax(pred3)}, conf {np.max(pred3):.3f}")
    
    # Method 4: Standard ImageNet mean/std
    img_array = np.array(test_img.resize((224, 224)), dtype=np.float32)
    img_array = img_array / 255.0
    mean = np.array([0.485, 0.456, 0.406])
    std = np.array([0.229, 0.224, 0.225])
    img_array = (img_array - mean) / std
    img_array = np.expand_dims(img_array, axis=0)
    pred4 = model.predict(img_array, verbose=0)[0]
    print(f"Method 4 (ImageNet): Class {np.argmax(pred4)}, conf {np.max(pred4):.3f}")

def check_model_layers():
    """Check model architecture for issues"""
    print("\n6️⃣ Checking model architecture...")
    
    model = tf.keras.models.load_model('rice_emergency_model.h5')
    
    print(f"Model input shape: {model.input_shape}")
    print(f"Model output shape: {model.output_shape}")
    print(f"Number of layers: {len(model.layers)}")
    
    # Check if model has proper softmax activation
    last_layer = model.layers[-1]
    print(f"Last layer: {last_layer}")
    print(f"Last layer activation: {getattr(last_layer, 'activation', 'None')}")

if __name__ == "__main__":
    test_different_images()
    test_different_preprocessing()
    check_model_layers()
    
    print("\n" + "=" * 60)
    print("🎯 Diagnosis Complete!")
    print("\n💡 If model always predicts Rice Hispa:")
    print("1. The model may be overfitted")
    print("2. Wrong preprocessing method")
    print("3. Model training data was imbalanced")
    print("4. Model file may be corrupted")