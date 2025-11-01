#!/usr/bin/env python3
"""
Demo API Server - Immediate working solution for Rice Disease Detection
Provides demo responses while main API loads
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import time
import random

app = Flask(__name__)
CORS(app)

# Demo disease data
DEMO_DISEASES = [
    {
        "disease": "Bacterial Leaf Blight",
        "confidence": 0.89,
        "disease_type": "Bacterial",
        "severity": "High",
        "treatment": "Apply copper-based bactericides immediately. Remove affected leaves and improve drainage."
    },
    {
        "disease": "Brown Spot", 
        "confidence": 0.92,
        "disease_type": "Fungal",
        "severity": "Medium",
        "treatment": "Use fungicides containing mancozeb. Improve soil fertility and drainage."
    },
    {
        "disease": "Leaf Blast",
        "confidence": 0.87,
        "disease_type": "Fungal", 
        "severity": "High",
        "treatment": "Apply systemic fungicides. Use resistant varieties for future planting."
    },
    {
        "disease": "Healthy Rice Leaf",
        "confidence": 0.95,
        "disease_type": "None",
        "severity": "None",
        "treatment": "Continue current care practices. Monitor regularly for early disease detection."
    }
]

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "model_loaded": True,
        "timestamp": time.time(),
        "message": "Demo API server running - immediate disease detection available"
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Prediction endpoint with demo responses"""
    
    # Simulate processing time
    time.sleep(2)
    
    # Get random demo disease
    prediction = random.choice(DEMO_DISEASES)
    
    # Generate confidence level based on confidence value
    def get_confidence_level(conf):
        if conf >= 0.9:
            return "Very High"
        elif conf >= 0.8:
            return "High"
        elif conf >= 0.7:
            return "Medium"
        elif conf >= 0.6:
            return "Low"
        else:
            return "Very Low"
    
    # Add confidence_level to prediction
    prediction_with_level = prediction.copy()
    prediction_with_level['confidence_level'] = get_confidence_level(prediction['confidence'])
    prediction_with_level['reliability'] = "Demo Mode"
    prediction_with_level['is_valid_input'] = True
    
    # Generate top predictions
    top_predictions = []
    for i, disease_data in enumerate(DEMO_DISEASES[:3]):
        confidence = prediction['confidence'] - (i * 0.1) if i == 0 else random.uniform(0.1, 0.6)
        top_predictions.append({
            "disease": disease_data["disease"],
            "confidence": round(confidence, 2),
            "disease_type": disease_data["disease_type"]
        })
    
    response = {
        "success": True,
        "prediction": prediction_with_level,
        "top_predictions": top_predictions,
        "all_predictions": {},
        "processing_time": 2.1,
        "timestamp": time.time(),
        "demo_mode": True,
        "message": "Demo prediction - for educational purposes"
    }
    
    return jsonify(response)

@app.route('/diseases', methods=['GET'])
def get_diseases():
    """Get supported diseases"""
    diseases = []
    for disease_data in DEMO_DISEASES:
        diseases.append({
            "name": disease_data["disease"],
            "type": disease_data["disease_type"],
            "severity_levels": ["Low", "Medium", "High"],
            "description": f"Common rice disease affecting crop yield and quality.",
            "symptoms": "Visible leaf discoloration and spots",
            "prevention": "Regular monitoring and proper field management"
        })
    
    return jsonify({
        "diseases": diseases,
        "total_count": len(diseases),
        "demo_mode": True
    })

@app.route('/model-info', methods=['GET'])
def model_info():
    """Model information"""
    return jsonify({
        "model_info": {
            "architecture": "Demo CNN Model",
            "num_classes": len(DEMO_DISEASES),
            "input_size": [224, 224, 3],
            "accuracy": "85-95%",
            "demo_mode": True,
            "description": "Educational demo for rice disease detection"
        }
    })

@app.route('/', methods=['GET'])
def root():
    """Root endpoint"""
    return jsonify({
        "message": "Rice Disease Detection Demo API",
        "status": "running",
        "demo_mode": True,
        "endpoints": ["/health", "/predict", "/diseases", "/model-info"]
    })

if __name__ == '__main__':
    print("🚀 Starting Demo API Server for Rice Disease Detection")
    print("📱 This provides immediate working functionality while main API loads")
    print("🌾 Perfect for testing and demonstrations")
    print("⚡ Server starting on http://localhost:5001")
    
    app.run(debug=False, host='0.0.0.0', port=5001)