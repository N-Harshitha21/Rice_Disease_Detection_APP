#!/usr/bin/env python3
"""
Fix the class mapping based on actual model behavior
"""

import tensorflow as tf
import numpy as np
from PIL import Image

# Test different class orders to find the correct one
possible_class_mappings = {
    'mapping_1': ['Bacterial Leaf Blight', 'Brown Spot', 'Healthy Rice Leaf', 'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Sheath Blight', 'Unknown'],
    
    'mapping_2': ['Healthy Rice Leaf', 'Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Sheath Blight', 'Unknown'],
    
    'mapping_3': ['Brown Spot', 'Bacterial Leaf Blight', 'Healthy Rice Leaf', 'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Sheath Blight', 'Unknown'],
    
    'mapping_4': ['Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 'Healthy Rice Leaf', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Sheath Blight', 'Unknown'],
    
    'mapping_5': ['Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 'Leaf scald', 'Healthy Rice Leaf', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Sheath Blight', 'Unknown'],
    
    'mapping_6': ['Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Healthy Rice Leaf', 'Rice Hispa', 'Sheath Blight', 'Unknown'],
    
    'mapping_7': ['Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Healthy Rice Leaf', 'Sheath Blight', 'Unknown'],
    
    'mapping_8': ['Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot', 'Rice Hispa', 'Sheath Blight', 'Healthy Rice Leaf', 'Unknown']
}

def analyze_model_expectations():
    """Analyze what the model expects based on its behavior"""
    print("🔍 Analyzing Model Class Expectations...")
    print("=" * 60)
    
    model = tf.keras.models.load_model('rice_emergency_model.h5')
    
    # Create strongly healthy-looking image (very green)
    healthy_img = create_very_healthy_image()
    healthy_pred = predict_with_model(model, healthy_img)
    
    # Create strongly diseased-looking image (brown with spots)
    diseased_img = create_very_diseased_image()
    diseased_pred = predict_with_model(model, diseased_img)
    
    print("Healthy image predictions:")
    for i, conf in enumerate(healthy_pred):
        print(f"  Index {i}: {conf:.6f}")
    
    print(f"\nHealthy image top prediction: Index {np.argmax(healthy_pred)}")
    
    print("\nDiseased image predictions:")
    for i, conf in enumerate(diseased_pred):
        print(f"  Index {i}: {conf:.6f}")
    
    print(f"\nDiseased image top prediction: Index {np.argmax(diseased_pred)}")
    
    # Find which index consistently gets high scores for healthy images
    healthy_index = np.argmax(healthy_pred)
    
    print(f"\n🎯 Analysis:")
    print(f"Model thinks healthy images are class index: {healthy_index}")
    
    # Test each mapping
    print(f"\n📊 Testing different class mappings:")
    for mapping_name, class_list in possible_class_mappings.items():
        if len(class_list) == 9:
            predicted_class = class_list[healthy_index]
            print(f"{mapping_name}: Healthy image → {predicted_class}")
            
            if 'healthy' in predicted_class.lower():
                print(f"  ✅ {mapping_name} might be correct!")
                return class_list
    
    return None

def create_very_healthy_image():
    """Create a very obviously healthy green rice leaf"""
    # Bright healthy green
    img = Image.new('RGB', (224, 224), color=(0, 128, 0))
    img_array = np.array(img)
    
    # Add some natural leaf patterns
    for i in range(10, 214, 20):
        img_array[i:i+5, :] = [0, 150, 0]  # Leaf veins
    
    return Image.fromarray(img_array.astype('uint8'))

def create_very_diseased_image():
    """Create a very obviously diseased brown/spotted leaf"""
    # Brown diseased color
    img = Image.new('RGB', (224, 224), color=(139, 69, 19))
    img_array = np.array(img)
    
    # Add dark disease spots
    for i in range(20, 200, 30):
        for j in range(20, 200, 30):
            img_array[i:i+10, j:j+10] = [50, 25, 10]  # Dark spots
    
    return Image.fromarray(img_array.astype('uint8'))

def predict_with_model(model, image):
    """Make prediction using same preprocessing as API"""
    if image.mode != 'RGB':
        image = image.convert('RGB')
    
    image = image.resize((224, 224))
    image_array = np.array(image, dtype=np.float32)
    image_array = image_array / 255.0
    image_array = np.expand_dims(image_array, axis=0)
    
    predictions = model.predict(image_array, verbose=0)[0]
    return predictions

if __name__ == "__main__":
    correct_mapping = analyze_model_expectations()
    
    if correct_mapping:
        print(f"\n✅ Suggested correct class mapping:")
        for i, class_name in enumerate(correct_mapping):
            print(f"  {i}: {class_name}")
            
        print(f"\n🔧 Update rice_disease_api.py with this mapping!")
    else:
        print(f"\n❌ Could not determine correct mapping automatically")
        print(f"💡 Try manually checking your Kaggle notebook for the exact class order")