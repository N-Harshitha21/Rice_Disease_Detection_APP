from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import io
from PIL import Image
import numpy as np
import tensorflow as tf
from datetime import datetime
import os
import requests

app = Flask(__name__)
CORS(app)

# Global variables
model = None

# RICE DISEASE CLASSES - Fixed to match your actual trained model
class_names = [
    'Bacterial Leaf Blight',      # maps to: bacterial_leaf_blight
    'Brown Spot',                 # maps to: brown_spot  
    'Healthy Rice Leaf',          # maps to: healthy
    'Leaf Blast',                 # maps to: leaf_blast
    'Leaf Scald',                 # maps to: leaf_scald
    'Leaf Smut',                  # maps to: leaf_smut
    'Not a Rice Leaf',            # maps to: not_a_rice_leaf
    'Rice Hispa',                 # maps to: rice_hispa
    'Sheath Blight'               # maps to: sheath_blight
]

# MODEL CONFIGURATION - Fixed for local model file
MODEL_CONFIG = {
    'model_path': 'rice_emergency_model.h5',  # Local model file in current directory
    'input_size': (224, 224),
    'rescale_factor': 1.0/255.0,
    'preprocessing': 'standard'
}

def load_model():
    """
    Load the model from local file
    """
    global model
    model_path = MODEL_CONFIG['model_path']

    try:
        # Check if model exists locally
        if not os.path.exists(model_path):
            print(f"❌ Model file '{model_path}' not found in current directory!")
            print("📁 Available files:")
            for file in os.listdir('.'):
                if file.endswith('.h5'):
                    print(f"   - {file}")
            return False

        # Load the model
        print(f"Loading model from {model_path}...")
        model = tf.keras.models.load_model(model_path)
        print("✅ Model loaded successfully!")
        print(f"Model input shape: {model.input_shape}")
        print(f"Model output shape: {model.output_shape}")
        return True

    except Exception as e:
        print(f"❌ Error loading model: {e}")
        print("🔧 This might be due to:")
        print("   1. Model file corruption")
        print("   2. TensorFlow version incompatibility")
        print("   3. Missing dependencies")
        return False

def preprocess_image(image):
    """
    Preprocess image for prediction
    UPDATE THIS based on your notebook's preprocessing steps
    """
    try:
        # Convert to RGB if needed
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Resize to model input size
        image = image.resize(MODEL_CONFIG['input_size'])
        
        # Convert to numpy array
        image_array = np.array(image, dtype=np.float32)
        
        # Apply preprocessing based on your model
        if MODEL_CONFIG['preprocessing'] == 'standard':
            # Standard rescaling (0-1)
            image_array = image_array * MODEL_CONFIG['rescale_factor']
        elif MODEL_CONFIG['preprocessing'] == 'imagenet':
            # ImageNet preprocessing (-1 to 1)
            image_array = image_array / 127.5 - 1
        elif MODEL_CONFIG['preprocessing'] == 'custom':
            # Add your custom preprocessing here
            # Example: normalize with specific mean/std
            mean = np.array([0.485, 0.456, 0.406])
            std = np.array([0.229, 0.224, 0.225])
            image_array = (image_array / 255.0 - mean) / std
        
        # Add batch dimension
        image_array = np.expand_dims(image_array, axis=0)
        
        return image_array
        
    except Exception as e:
        raise Exception(f"Image preprocessing failed: {e}")

def get_disease_treatment(disease_name):
    """Get treatment recommendations for each disease"""
    treatments = {
        'Bacterial Leaf Blight': 'Apply copper-based bactericides (Copper oxychloride 50% WP @ 3g/L). Improve field drainage and avoid overhead irrigation. Use resistant varieties like IR64.',
        'Brown Spot': 'Apply fungicides like Mancozeb 75% WP @ 2g/L or Carbendazim 50% WP @ 1g/L. Improve soil fertility with balanced NPK fertilizer.',
        'Healthy Rice Leaf': 'Continue current management practices. Regular monitoring for early disease detection. Maintain proper nutrition and water management.',
        'Leaf Blast': 'Apply systemic fungicides like Tricyclazole 75% WP @ 0.6g/L. Use blast-resistant varieties. Avoid excessive nitrogen fertilization.',
        'Leaf scald': 'Apply fungicides at early infection stage. Remove infected plant debris. Improve air circulation in the field.',
        'Leaf Smut': 'Apply fungicides like Tebuconazole. Remove affected tillers. Use disease-free seeds and resistant varieties.',
        'Not a Rice Leaf': 'This appears to be not a rice leaf. Please take a photo of a rice leaf for accurate disease detection.',
        'Rice Hispa': 'Apply insecticides like Chlorpyrifos 20% EC @ 2ml/L. Use pheromone traps. Remove grassy weeds around field boundaries.',
        'Sheath Blight': 'Apply fungicides like Validamycin 3% L @ 2.5ml/L. Improve field drainage. Reduce plant density and apply silicon fertilizers.'
    }
    return treatments.get(disease_name, 'Consult with agricultural expert for specific treatment recommendations.')

def get_confidence_level(confidence):
    """Determine confidence level based on prediction score"""
    if confidence >= 0.9:
        return "Very High", "Very Reliable"
    elif confidence >= 0.8:
        return "High", "Reliable"
    elif confidence >= 0.7:
        return "Medium", "Moderately Reliable"
    elif confidence >= 0.6:
        return "Low", "Needs Verification"
    else:
        return "Very Low", "Manual Inspection Required"

@app.route('/health', methods=['GET'])
def health_check():
    """Check if API and model are working"""
    return jsonify({
        "status": "healthy",
        "model_loaded": model is not None,
        "model_config": MODEL_CONFIG if model is not None else None,
        "num_classes": len(class_names),
        "timestamp": datetime.now().isoformat()
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Predict disease from uploaded image"""
    try:
        # Handle file upload
        if 'image' in request.files:
            image_file = request.files['image']
            if image_file.filename == '':
                return jsonify({"error": "No image file selected"}), 400
            image = Image.open(image_file)
            
        # Handle base64 image
        elif request.is_json and 'image_base64' in request.json:
            try:
                image_data = base64.b64decode(request.json['image_base64'])
                image = Image.open(io.BytesIO(image_data))
            except Exception as e:
                return jsonify({"error": f"Invalid base64 image: {str(e)}"}), 400
        else:
            return jsonify({"error": "No image provided. Send as 'image' file or 'image_base64' in JSON"}), 400

        if model is None:
            return jsonify({"error": "Model not loaded. Check server logs."}), 500

        # Preprocess image
        try:
            processed_image = preprocess_image(image)
        except Exception as e:
            return jsonify({"error": f"Image preprocessing failed: {str(e)}"}), 400
        
        # Make prediction
        try:
            predictions = model.predict(processed_image, verbose=0)[0]
        except Exception as e:
            return jsonify({"error": f"Model prediction failed: {str(e)}"}), 500
        
        # Get top prediction
        predicted_class_idx = np.argmax(predictions)
        predicted_disease = class_names[predicted_class_idx]
        confidence = float(predictions[predicted_class_idx])
        
        # Get confidence level and reliability
        confidence_level, reliability = get_confidence_level(confidence)
        
        # Get top 3 predictions
        top_indices = np.argsort(predictions)[-3:][::-1]
        top_predictions = []
        
        for idx in top_indices:
            top_predictions.append({
                "disease": class_names[idx],
                "confidence": float(predictions[idx])
            })
        
        # All predictions
        all_predictions = {}
        for i, class_name in enumerate(class_names):
            all_predictions[class_name] = float(predictions[i])
        
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
        return jsonify({"error": f"Prediction failed: {str(e)}"}), 500

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
    
    try:
        # Get model info
        input_shape = model.input_shape[1:]  # Remove batch dimension
        total_params = model.count_params()
        
        return jsonify({
            "model_info": {
                "architecture": "Rice Disease Detection Model (Kaggle)",
                "input_size": list(input_shape),
                "num_classes": len(class_names),
                "classes": class_names,
                "model_file": MODEL_CONFIG['model_path'],
                "parameters": int(total_params),
                "preprocessing": MODEL_CONFIG['preprocessing'],
                "input_resolution": MODEL_CONFIG['input_size']
            }
        })
    except Exception as e:
        return jsonify({"error": f"Failed to get model info: {str(e)}"}), 500

@app.route('/', methods=['GET'])
def root_endpoint():
    """Root endpoint"""
    return jsonify({
        "message": "🌾 Rice Disease Detection API",
        "status": "running",
        "model_loaded": model is not None,
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "predict": "/predict", 
            "diseases": "/diseases",
            "model_info": "/model-info",
            "test": "/test"
        },
        "documentation": "Use POST /predict with image file or base64 data",
        "timestamp": datetime.now().isoformat()
    })

@app.route('/test', methods=['GET'])
def test_endpoint():
    """Simple test endpoint"""
    return jsonify({
        "message": "Rice Disease API is working!",
        "model_loaded": model is not None,
        "endpoints": ["/health", "/predict", "/diseases", "/model-info", "/test"],
        "timestamp": datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("🌾 Rice Disease Detection API")
    print("=" * 40)
    print("Loading model...")
    
    if load_model():
        print("✅ Model loaded successfully!")
        print(f"📊 Classes: {len(class_names)}")
        print(f"🎯 Input size: {MODEL_CONFIG['input_size']}")
        print("🚀 Starting Flask API server...")
        print("📍 API will be available at:")
        print("   - Local: http://localhost:5000")
        print("   - Network: http://YOUR_IP:5000")
        print("\n🔗 Test endpoints:")
        print("   - GET  /health     - Check API status")
        print("   - POST /predict    - Predict disease")
        print("   - GET  /diseases   - List all diseases")
        print("   - GET  /model-info - Model information")
        print("   - GET  /test       - Simple test")
        print("=" * 40)
        
        app.run(debug=True, host='0.0.0.0', port=5000)
    else:
        print("❌ Failed to load model.")
        print("\n🔧 Troubleshooting:")
        print("1. Check if your .h5 model file is in the current directory")
        print("2. Update MODEL_CONFIG['model_path'] with correct filename")
        print("3. Make sure the model file is compatible with current TensorFlow version")
        print("4. Run extract_model_info.py to analyze your notebook")