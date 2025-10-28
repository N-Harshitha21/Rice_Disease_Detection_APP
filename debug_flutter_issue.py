#!/usr/bin/env python3
"""
Debug what's happening when Flutter app sends requests
"""

import time
import threading
from flask import Flask, request, jsonify
import requests
import json

# Create a simple logging server to capture what Flutter sends
debug_app = Flask(__name__)

@debug_app.route('/predict', methods=['POST'])
def debug_predict():
    """Capture and log what Flutter actually sends"""
    print("\n" + "="*60)
    print("🔍 FLUTTER REQUEST CAPTURED!")
    print("="*60)
    
    # Log request details
    print(f"📡 Method: {request.method}")
    print(f"📡 Content-Type: {request.content_type}")
    print(f"📡 Headers: {dict(request.headers)}")
    print(f"📡 Form data keys: {list(request.form.keys())}")
    print(f"📡 Files: {list(request.files.keys())}")
    
    # Check if image is present
    if 'image' in request.files:
        image_file = request.files['image']
        print(f"📁 Image filename: {image_file.filename}")
        print(f"📁 Image content type: {image_file.content_type}")
        
        # Save the image to see what Flutter is sending
        debug_filename = f"debug_flutter_image_{int(time.time())}.jpg"
        image_file.save(debug_filename)
        print(f"💾 Saved Flutter image as: {debug_filename}")
        
        # Forward to real API and capture response
        try:
            # Reset file pointer
            image_file.seek(0)
            
            # Forward to real API
            files = {'image': (image_file.filename, image_file.read(), image_file.content_type)}
            response = requests.post('http://localhost:5000/predict', files=files, timeout=30)
            
            print(f"🔄 Forwarded to real API: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                print(f"🎯 Real API Result: {result['prediction']['disease']}")
                print(f"📊 Confidence: {result['prediction']['confidence']:.3f}")
                
                # Return the real result to Flutter
                return jsonify(result)
            else:
                print(f"❌ Real API Error: {response.text}")
                return jsonify({"error": "Real API failed"}), 500
                
        except Exception as e:
            print(f"❌ Forward failed: {e}")
            return jsonify({"error": str(e)}), 500
    
    elif request.is_json and 'image_base64' in request.json:
        print(f"📁 Base64 image length: {len(request.json['image_base64'])}")
        
        # Forward base64 to real API
        try:
            headers = {'Content-Type': 'application/json'}
            response = requests.post('http://localhost:5000/predict', 
                                   headers=headers, 
                                   json=request.json, 
                                   timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                print(f"🎯 Real API Result: {result['prediction']['disease']}")
                return jsonify(result)
            else:
                print(f"❌ Real API Error: {response.text}")
                return jsonify({"error": "Real API failed"}), 500
                
        except Exception as e:
            print(f"❌ Forward failed: {e}")
            return jsonify({"error": str(e)}), 500
    
    else:
        print("❌ No image found in request!")
        return jsonify({"error": "No image provided"}), 400

@debug_app.route('/health', methods=['GET'])
def debug_health():
    """Proxy health check to main API"""
    try:
        response = requests.get('http://localhost:5000/health', timeout=10)
        print(f"🔍 Health check proxied - Status: {response.status_code}")
        return response.json(), response.status_code
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return jsonify({"error": str(e)}), 500

@debug_app.route('/diseases', methods=['GET'])
def debug_diseases():
    """Proxy diseases endpoint to main API"""
    try:
        response = requests.get('http://localhost:5000/diseases', timeout=10)
        print(f"🔍 Diseases endpoint proxied - Status: {response.status_code}")
        return response.json(), response.status_code
    except Exception as e:
        print(f"❌ Diseases endpoint failed: {e}")
        return jsonify({"error": str(e)}), 500

@debug_app.route('/model-info', methods=['GET'])
def debug_model_info():
    """Proxy model-info endpoint to main API"""
    try:
        response = requests.get('http://localhost:5000/model-info', timeout=10)
        print(f"🔍 Model-info endpoint proxied - Status: {response.status_code}")
        return response.json(), response.status_code
    except Exception as e:
        print(f"❌ Model-info endpoint failed: {e}")
        return jsonify({"error": str(e)}), 500

def start_debug_server():
    """Start debug server in background"""
    debug_app.run(host='0.0.0.0', port=5001, debug=False)

def main():
    print("🔍 Flutter Debug Interceptor")
    print("="*60)
    print("This will capture and analyze what your Flutter app actually sends")
    print("")
    print("📋 Instructions:")
    print("1. Update your Flutter app API URL to: http://192.168.182.140:5001")
    print("2. Change line 8 in lib/services/rice_disease_api_service.dart:")
    print("   static const String baseUrl = 'http://192.168.182.140:5001';")
    print("3. Run your Flutter app and take a photo")
    print("4. Watch this console for detailed logging")
    print("")
    print("🚀 Starting debug server on port 5001...")
    print("📡 Forwarding requests to real API on port 5000")
    print("="*60)
    
    # Start the debug server
    start_debug_server()

if __name__ == "__main__":
    main()