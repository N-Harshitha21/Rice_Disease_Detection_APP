from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import io
from PIL import Image
import numpy as np
import tensorflow as tf
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

# Global variables
model = None
class_names = [
    'Bacterial Leaf Blight',
    'Brown Spot', 
    'Healthy Rice Leaf',
    'Leaf Blast',
    'Leaf scald',
    'Narrow Brown Leaf Spot',
    'Rice Hispa',
    'Sheath Blight'
]

def load_model():
    """Load your trained model from Kaggle"""
    global model
    try:
        # Replace with your actual model path
        model_path = "your_model.h5"  # Update this path
        model = tf.keras.models.load_model(model_path)
        print(f"Model loaded successfully from {model_path}")
        return True
    except Exception as e:
        print(f"Error loading model: {e}")
        return False

def preprocess_image(image):
    """Preprocess image for prediction - UPDATE THIS based on your Kaggle preprocessing"""
    try:
        # Resize image to model input size
        image = image.convert('RGB')
        image = image.resize((224, 224))  # Update size if different
        
        # Convert to numpy array
        image_array = np.array(image)
        
        # Normalize (update this based on your Kaggle preprocessing)
        image_array = image_array / 255.0
        
        # Add batch dimension
        image_array = np.expand_dims(image_array, axis=0)
        
        return image_array
    except Exception as e:
        raise Exception(f"Image preprocessing failed: {e}")

def get_disease_treatment(disease_name):
    """Get treatment recommendations for each disease"""
    treatments = {
        'Bacterial Leaf Blight': 'Apply copper-based bactericides (Copper oxychloride). Improve field drainage and water management.',
        'Brown Spot': 'Apply fungicides (Mancozeb 75% WP @ 2g/L). Improve soil fertility with balanced NPK fertilizer.',
        'Healthy Rice Leaf': 'Continue current management practices. Monitor regularly for early disease detection.',
        'Leaf Blast': 'Apply systemic fungicides (Tricyclazole 75% WP). Use blast-resistant varieties.',
        'Leaf scald': 'Apply fungicides at early infection stage. Improve air circulation in field.',
        'Narrow Brown Leaf Spot': 'Apply fungicides during early infection. Improve field sanitation practices.',
        'Rice Hispa': 'Apply insecticides (Chlorpyrifos 20% EC). Use pheromone traps for monitoring.',
        'Sheath Blight': 'Apply fungicides (Validamycin 3% L @ 2.5ml/L). Improve field drainage.'
    }
    return treatments.get(disease_name, 'Consult with agricultural expert for treatment recommendations.')

@app.route('/health', methods=['GET'])
def health_check():
    """Check if API and model are working"""
    return jsonify({
        "status": "healthy",
        "model_loaded": model is not None,
        "timestamp": datetime.now().isoformat()
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Predict disease from uploaded image"""
    try:
        # Handle file upload
        if 'image' in request.files:
            image_file = request.files['image']
            image = Image.open(image_file)
        # Handle base64 image
        elif request.is_json and 'image_base64' in request.json:
            image_data = base64.b64decode(request.json['image_base64'])
            image = Image.open(io.BytesIO(image_data))
        else:
            return jsonify({"error": "No image provided"}), 400

        if model is None:
            return jsonify({"error": "Model not loaded"}), 500

        # Preprocess image
        processed_image = preprocess_image(image)
        
        # Make prediction
        predictions = model.predict(processed_image)[0]
        
        # Get top prediction
        predicted_class_idx = np.argmax(predictions)
        predicted_disease = class_names[predicted_class_idx]
        confidence = float(predictions[predicted_class_idx])
        
        # Get top 3 predictions
        top_indices = np.argsort(predictions)[-3:][::-1]
        top_predictions = []
        all_predictions = {}
        
        for i, idx in enumerate(top_indices):
            top_predictions.append({
                "disease": class_names[idx],
                "confidence": float(predictions[idx])
            })
        
        # All predictions
        for i, class_name in enumerate(class_names):
            all_predictions[class_name] = float(predictions[i])
        
        # Determine confidence level
        if confidence >= 0.9:
            confidence_level = "Very High"
            reliability = "Very Reliable"
        elif confidence >= 0.8:
            confidence_level = "High"
            reliability = "Reliable"
        elif confidence >= 0.7:
            confidence_level = "Medium"
            reliability = "Moderately Reliable"
        else:
            confidence_level = "Low"
            reliability = "Low Reliability"
        
        # Get treatment
        treatment = get_disease_treatment(predicted_disease)
        
        # Determine disease type
        disease_type = "healthy" if "healthy" in predicted_disease.lower() else "disease"
        
        result = {
            "success": True,
            "prediction": {
                "disease": predicted_disease,
                "disease_type": disease_type,
                "confidence": confidence,
                "confidence_level": confidence_level,
                "reliability": reliability,
                "treatment": treatment,
                "is_valid_input": True
            },
            "top_predictions": top_predictions,
            "all_predictions": all_predictions,
            "timestamp": datetime.now().isoformat()
        }
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/diseases', methods=['GET'])
def get_diseases():
    """Get all supported diseases"""
    diseases = []
    for disease_name in class_names:
        disease_type = "healthy" if "healthy" in disease_name.lower() else "disease"
        diseases.append({
            "name": disease_name,
            "type": disease_type,
            "treatment": get_disease_treatment(disease_name)
        })
    
    return jsonify({"diseases": diseases})

@app.route('/model-info', methods=['GET'])
def get_model_info():
    """Get model information"""
    if model is None:
        return jsonify({"error": "Model not loaded"}), 500
    
    # Get model info
    input_shape = model.input_shape[1:]  # Remove batch dimension
    total_params = model.count_params()
    
    return jsonify({
        "model_info": {
            "architecture": "Rice Disease Detection Model",
            "input_size": list(input_shape),
            "num_classes": len(class_names),
            "classes": class_names,
            "model_file": "kaggle_trained_model.h5",
            "parameters": int(total_params)
        }
    })

if __name__ == '__main__':
    print("Loading model...")
    if load_model():
        print("✅ Model loaded successfully!")
        print("🚀 Starting Flask API server...")
        app.run(debug=True, host='0.0.0.0', port=5000)
    else:
        print("❌ Failed to load model. Please check the model path.")