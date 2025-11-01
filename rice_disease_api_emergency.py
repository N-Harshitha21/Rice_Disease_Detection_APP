from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import io
from PIL import Image
import numpy as np
import os
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Global variables
model = None
class_names = [
    'Bacterial Leaf Blight', 'Brown Spot', 'Healthy Rice Leaf',
    'Leaf Blast', 'Leaf Scald', 'Leaf Smut', 'Not a Rice Leaf',
    'Rice Hispa', 'Sheath Blight'
]

def load_model_emergency():
    """Emergency model loading with maximum compatibility"""
    global model
    
    try:
        logger.info("🚀 Emergency model loading starting...")
        
        # Import TensorFlow with minimal config
        import tensorflow as tf
        logger.info(f"✅ TensorFlow {tf.__version__} imported")
        
        # Configure for minimal memory usage
        tf.config.set_soft_device_placement(True)
        
        # Try to allocate GPU memory incrementally
        gpus = tf.config.experimental.list_physical_devices('GPU')
        if gpus:
            try:
                for gpu in gpus:
                    tf.config.experimental.set_memory_growth(gpu, True)
            except:
                pass
        
        model_path = 'rice_emergency_model.h5'
        
        if not os.path.exists(model_path):
            logger.error(f"❌ Model file not found: {model_path}")
            return False
        
        file_size = os.path.getsize(model_path)
        logger.info(f"📊 Model file size: {file_size:,} bytes")
        
        if file_size < 1000000:
            logger.error("❌ Model file too small")
            return False
        
        # Load model with minimal settings
        logger.info("📥 Loading model...")
        model = tf.keras.models.load_model(model_path, compile=False)
        
        logger.info("✅ Model loaded successfully!")
        logger.info(f"📐 Input shape: {model.input_shape}")
        logger.info(f"📐 Output shape: {model.output_shape}")
        
        # Test prediction
        test_input = np.random.random((1, 224, 224, 3)).astype(np.float32)
        test_pred = model.predict(test_input, verbose=0)
        logger.info(f"✅ Test prediction successful: {test_pred.shape}")
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Model loading failed: {e}")
        logger.error(f"Error type: {type(e).__name__}")
        import traceback
        logger.error(f"Traceback: {traceback.format_exc()}")
        return False

def preprocess_image_simple(image):
    """Simple, reliable image preprocessing"""
    try:
        # Convert to RGB
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Resize to model input size
        image = image.resize((224, 224))
        
        # Convert to array and normalize
        image_array = np.array(image, dtype=np.float32)
        image_array = image_array / 255.0
        
        # Add batch dimension
        image_array = np.expand_dims(image_array, axis=0)
        
        return image_array
        
    except Exception as e:
        raise Exception(f"Image preprocessing failed: {e}")

def get_treatment_info(disease_name):
    """Get treatment for detected disease"""
    treatments = {
        'Bacterial Leaf Blight': 'Apply copper-based bactericides (Copper oxychloride 50% WP @ 3g/L). Improve field drainage and avoid over-fertilization with nitrogen.',
        'Brown Spot': 'Apply fungicides like Mancozeb 75% WP @ 2g/L. Improve soil fertility with balanced fertilizers and ensure proper water management.',
        'Healthy Rice Leaf': 'Continue current management practices. Regular monitoring and preventive measures recommended.',
        'Leaf Blast': 'Apply systemic fungicides like Tricyclazole 75% WP @ 0.6g/L. Remove infected debris and improve air circulation.',
        'Leaf Scald': 'Apply fungicides at early infection stage. Remove infected plant debris and improve field hygiene.',
        'Leaf Smut': 'Apply fungicides like Tebuconazole 25% EC @ 1ml/L. Remove and destroy affected tillers immediately.',
        'Not a Rice Leaf': 'This appears to be not a rice leaf. Please capture clear images of rice leaves for accurate detection.',
        'Rice Hispa': 'Apply contact insecticides like Chlorpyrifos 20% EC @ 2ml/L. Remove grassy weeds that serve as alternate hosts.',
        'Sheath Blight': 'Apply fungicides like Validamycin 3% L @ 2.5ml/L. Improve drainage and avoid dense planting.'
    }
    return treatments.get(disease_name, 'Consult your local agricultural extension officer for specific treatment recommendations.')

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "model_loaded": model is not None,
        "version": "emergency-v1.0",
        "num_classes": len(class_names),
        "timestamp": datetime.now().isoformat(),
        "message": "🌾 Rice Disease Detection API - Emergency Cloud Version"
    })

@app.route('/predict', methods=['POST'])
def predict_disease():
    """Main prediction endpoint"""
    try:
        # Check if model is loaded
        if model is None:
            logger.warning("Model not loaded, attempting emergency load...")
            if not load_model_emergency():
                return jsonify({
                    "error": "Model loading failed. Please try again in a few moments.",
                    "success": False
                }), 500
        
        # Handle image input
        image = None
        
        if 'image' in request.files:
            # File upload
            image_file = request.files['image']
            if image_file.filename == '':
                return jsonify({"error": "No image file selected"}), 400
            image = Image.open(image_file)
            
        elif request.is_json and 'image_base64' in request.json:
            # Base64 image
            try:
                image_data = base64.b64decode(request.json['image_base64'])
                image = Image.open(io.BytesIO(image_data))
            except Exception as e:
                return jsonify({"error": f"Invalid base64 image: {str(e)}"}), 400
        else:
            return jsonify({"error": "No image provided. Send as 'image' file or 'image_base64' in JSON."}), 400

        # Preprocess image
        processed_image = preprocess_image_simple(image)
        
        # Make prediction
        logger.info("🔮 Making prediction...")
        predictions = model.predict(processed_image, verbose=0)[0]
        
        # Get results
        predicted_class_idx = np.argmax(predictions)
        predicted_disease = class_names[predicted_class_idx]
        confidence = float(predictions[predicted_class_idx])
        
        logger.info(f"✅ Prediction: {predicted_disease} ({confidence:.2f})")
        
        # Prepare response
        result = {
            "success": True,
            "prediction": {
                "disease": predicted_disease,
                "confidence": confidence,
                "treatment": get_treatment_info(predicted_disease),
                "all_predictions": {
                    class_names[i]: float(predictions[i]) 
                    for i in range(len(class_names))
                }
            },
            "timestamp": datetime.now().isoformat(),
            "version": "emergency-v1.0"
        }
        
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Prediction error: {e}")
        return jsonify({
            "error": f"Prediction failed: {str(e)}",
            "success": False
        }), 500

@app.route('/', methods=['GET'])
def root():
    """Root endpoint"""
    return jsonify({
        "message": "🌾 Rice Disease Detection API - Emergency Cloud Version",
        "status": "running",
        "model_loaded": model is not None,
        "version": "emergency-v1.0",
        "endpoints": {
            "health": "/health - Check API status",
            "predict": "/predict - Detect rice diseases",
            "root": "/ - This information"
        },
        "info": "Optimized for cloud deployment with reliable model loading"
    })

@app.route('/diseases', methods=['GET'])
def get_diseases():
    """Get list of detectable diseases"""
    diseases_info = []
    for disease in class_names:
        diseases_info.append({
            "name": disease,
            "treatment": get_treatment_info(disease)
        })
    
    return jsonify({
        "diseases": diseases_info,
        "total_classes": len(class_names)
    })

# Initialize model on startup
logger.info("🚀 Starting Rice Disease Detection API - Emergency Version")
logger.info("📊 Attempting model load on startup...")

if load_model_emergency():
    logger.info("✅ Startup model loading successful!")
else:
    logger.warning("⚠️ Startup model loading failed - will retry on first request")

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    logger.info(f"🌐 Starting server on port {port}")
    app.run(debug=False, host='0.0.0.0', port=port)
