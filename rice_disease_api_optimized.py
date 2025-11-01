from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import io
from PIL import Image
import numpy as np
import os
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Global variables
model = None
tf = None

# RICE DISEASE CLASSES
class_names = [
    'Bacterial Leaf Blight',
    'Brown Spot', 
    'Healthy Rice Leaf',
    'Leaf Blast',
    'Leaf Scald',
    'Leaf Smut',
    'Not a Rice Leaf',
    'Rice Hispa',
    'Sheath Blight'
]

MODEL_CONFIG = {
    'model_path': 'rice_emergency_model.h5',
    'input_size': (224, 224),
    'rescale_factor': 1.0/255.0,
    'preprocessing': 'standard'
}

def lazy_load_tensorflow():
    """Lazy load TensorFlow only when needed"""
    global tf
    if tf is None:
        try:
            print("Loading TensorFlow...")
            import tensorflow as tf_module
            tf = tf_module
            # Configure TensorFlow for cloud deployment
            tf.config.set_soft_device_placement(True)
            print(f"✅ TensorFlow {tf.__version__} loaded successfully")
            return True
        except Exception as e:
            print(f"❌ TensorFlow loading failed: {e}")
            return False
    return True

def load_model_safe():
    """Safe model loading with comprehensive error handling"""
    global model
    
    if not lazy_load_tensorflow():
        return False
    
    model_path = MODEL_CONFIG['model_path']
    
    try:
        # Check file exists
        if not os.path.exists(model_path):
            print(f"❌ Model file not found: {model_path}")
            return False
        
        file_size = os.path.getsize(model_path)
        print(f"📊 Model file size: {file_size:,} bytes")
        
        if file_size < 1000000:  # Less than 1MB
            print("⚠️ Warning: Model file seems too small")
            return False
        
        # Load with specific configuration for cloud
        print("Loading model with cloud-optimized settings...")
        
        # Try loading with custom objects if needed
        try:
            model = tf.keras.models.load_model(model_path, compile=False)
        except Exception as e1:
            print(f"First load attempt failed: {e1}")
            try:
                # Try with compile=True
                model = tf.keras.models.load_model(model_path, compile=True)
            except Exception as e2:
                print(f"Second load attempt failed: {e2}")
                return False
        
        print("✅ Model loaded successfully!")
        print(f"Model input shape: {model.input_shape}")
        print(f"Model output shape: {model.output_shape}")
        
        # Test prediction to ensure model works
        test_input = np.random.random((1, 224, 224, 3)).astype(np.float32)
        test_pred = model.predict(test_input, verbose=0)
        print(f"✅ Model test prediction successful: {test_pred.shape}")
        
        return True
        
    except Exception as e:
        print(f"❌ Model loading failed: {e}")
        print(f"Error type: {type(e).__name__}")
        return False

def preprocess_image(image):
    """Optimized image preprocessing"""
    try:
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        image = image.resize(MODEL_CONFIG['input_size'])
        image_array = np.array(image, dtype=np.float32)
        image_array = image_array * MODEL_CONFIG['rescale_factor']
        image_array = np.expand_dims(image_array, axis=0)
        
        return image_array
    except Exception as e:
        raise Exception(f"Image preprocessing failed: {e}")

def get_disease_treatment(disease_name):
    """Get treatment recommendations"""
    treatments = {
        'Bacterial Leaf Blight': 'Apply copper-based bactericides (Copper oxychloride 50% WP @ 3g/L). Improve field drainage.',
        'Brown Spot': 'Apply fungicides like Mancozeb 75% WP @ 2g/L. Improve soil fertility.',
        'Healthy Rice Leaf': 'Continue current management practices. Regular monitoring recommended.',
        'Leaf Blast': 'Apply systemic fungicides like Tricyclazole 75% WP @ 0.6g/L.',
        'Leaf Scald': 'Apply fungicides at early infection stage. Remove infected debris.',
        'Leaf Smut': 'Apply fungicides like Tebuconazole. Remove affected tillers.',
        'Not a Rice Leaf': 'This appears to be not a rice leaf. Please use rice leaf images.',
        'Rice Hispa': 'Apply insecticides like Chlorpyrifos 20% EC @ 2ml/L.',
        'Sheath Blight': 'Apply fungicides like Validamycin 3% L @ 2.5ml/L. Improve drainage.'
    }
    return treatments.get(disease_name, 'Consult agricultural expert for treatment.')

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "model_loaded": model is not None,
        "tensorflow_available": tf is not None,
        "model_config": MODEL_CONFIG if model is not None else None,
        "num_classes": len(class_names),
        "timestamp": datetime.now().isoformat()
    })

@app.route('/load-model', methods=['POST'])
def force_load_model():
    """Force model loading endpoint for debugging"""
    success = load_model_safe()
    return jsonify({
        "model_load_attempt": success,
        "model_loaded": model is not None,
        "tensorflow_available": tf is not None,
        "timestamp": datetime.now().isoformat()
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Predict disease from image"""
    try:
        # Auto-load model if not loaded
        if model is None:
            print("Model not loaded, attempting to load...")
            if not load_model_safe():
                return jsonify({"error": "Model loading failed. Try /load-model endpoint."}), 500
        
        # Handle image input
        if 'image' in request.files:
            image_file = request.files['image']
            if image_file.filename == '':
                return jsonify({"error": "No image file selected"}), 400
            image = Image.open(image_file)
            
        elif request.is_json and 'image_base64' in request.json:
            try:
                image_data = base64.b64decode(request.json['image_base64'])
                image = Image.open(io.BytesIO(image_data))
            except Exception as e:
                return jsonify({"error": f"Invalid base64 image: {str(e)}"}), 400
        else:
            return jsonify({"error": "No image provided"}), 400

        # Process and predict
        processed_image = preprocess_image(image)
        predictions = model.predict(processed_image, verbose=0)[0]
        
        # Get results
        predicted_class_idx = np.argmax(predictions)
        predicted_disease = class_names[predicted_class_idx]
        confidence = float(predictions[predicted_class_idx])
        
        # Build response
        result = {
            "success": True,
            "prediction": {
                "disease": predicted_disease,
                "confidence": confidence,
                "treatment": get_disease_treatment(predicted_disease),
                "is_valid_input": True
            },
            "timestamp": datetime.now().isoformat()
        }
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({"error": f"Prediction failed: {str(e)}"}), 500

@app.route('/diseases', methods=['GET'])
def get_diseases():
    """Get supported diseases"""
    diseases = [{"name": name, "treatment": get_disease_treatment(name)} for name in class_names]
    return jsonify({"diseases": diseases})

@app.route('/', methods=['GET'])
def root():
    """Root endpoint"""
    return jsonify({
        "message": "🌾 Rice Disease Detection API",
        "status": "running",
        "model_loaded": model is not None,
        "version": "1.1.0",
        "endpoints": {
            "health": "/health",
            "predict": "/predict",
            "diseases": "/diseases", 
            "load_model": "/load-model"
        }
    })

@app.route('/test', methods=['GET'])
def test():
    """Test endpoint"""
    return jsonify({
        "message": "API is working!",
        "model_loaded": model is not None,
        "tensorflow_loaded": tf is not None
    })

# Initialize on startup
print("🚀 Rice Disease API Starting...")
print("📊 Attempting initial model load...")
load_model_safe()

if __name__ == '__main__':
    PORT = int(os.environ.get('PORT', 5000))
    print(f"🌐 Starting server on port {PORT}")
    app.run(debug=False, host='0.0.0.0', port=PORT)
