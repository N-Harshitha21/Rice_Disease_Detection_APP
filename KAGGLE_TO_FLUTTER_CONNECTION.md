# 🔗 **Kaggle Model → Flutter App Connection Guide**

## ✅ **What I Found in Your Notebook:**

Based on analyzing your `Rice_leaf_disease_dataset_using the Deep_Learning.ipynb`:

- **🤖 Model Architecture**: MobileNet/EfficientNet with Sequential layers
- **📏 Input Size**: 224x224 pixels 
- **🔧 Preprocessing**: Rescale by 1./255 (0-1 normalization)
- **💾 Model File**: `rice_emergency_model.h5`
- **⚙️ Training**: Adam optimizer, categorical_crossentropy loss

## 🚀 **Quick Start (3 Steps)**

### **Step 1: Get Your Model File**
```bash
# Download from Kaggle notebook output section:
# rice_emergency_model.h5
# Place it in this project folder
```

### **Step 2: Setup Backend**
```bash
# Run the automated setup
python setup_backend.py

# Or manually:
pip install -r requirements.txt
python rice_disease_api.py
```

### **Step 3: Connect Flutter**
```bash
# Update lib/services/rice_disease_api_service.dart line 8:
static const String baseUrl = 'http://YOUR_IP:5000';

# Run Flutter app:
flutter pub get
flutter run
```

## 📁 **Files Created for You:**

1. **`rice_disease_api.py`** - ✅ Customized Flask API for your model
2. **`setup_backend.py`** - ✅ Automated setup script
3. **`extract_model_info.py`** - ✅ Notebook analysis tool
4. **`start_backend.bat`** - ✅ Windows startup script
5. **`requirements.txt`** - ✅ Python dependencies

## 🔧 **Detailed Setup Instructions**

### **1. Download Your Model**

Go to your Kaggle notebook and download:
- **Output file**: `rice_emergency_model.h5`
- **Place it** in this project directory (same folder as `rice_disease_api.py`)

### **2. Install Dependencies**

```bash
# Create virtual environment (recommended)
python -m venv rice_env
rice_env\Scripts\activate  # Windows
# source rice_env/bin/activate  # Mac/Linux

# Install packages
pip install -r requirements.txt
```

### **3. Test Backend**

```bash
# Run the API server
python rice_disease_api.py

# Expected output:
🌾 Rice Disease Detection API
========================================
Loading model...
✅ Model loaded successfully!
📊 Classes: 8
🎯 Input size: (224, 224)
🚀 Starting Flask API server...
📍 API will be available at:
   - Local: http://localhost:5000
   - Network: http://YOUR_IP:5000
```

### **4. Test API Endpoints**

```bash
# Test health check
curl http://localhost:5000/health

# Expected response:
{
  "status": "healthy",
  "model_loaded": true,
  "num_classes": 8,
  "timestamp": "2024-01-15T10:30:00"
}
```

### **5. Update Flutter App**

**Edit `lib/services/rice_disease_api_service.dart`:**

```dart
// Line 8: Update the base URL
static const String baseUrl = 'http://192.168.1.100:5000'; // Your computer's IP

// For Android Emulator use:
// static const String baseUrl = 'http://10.0.2.2:5000';

// For iOS Simulator use:
// static const String baseUrl = 'http://localhost:5000';
```

**Find Your IP Address:**
```bash
# Windows
ipconfig

# Mac/Linux  
ifconfig

# Look for something like: 192.168.1.100
```

### **6. Test Complete Connection**

1. **Start backend**: `python rice_disease_api.py`
2. **Start Flutter**: `flutter run`
3. **Take photo** in app
4. **Check prediction** works

## 🐛 **Troubleshooting**

### **Model Loading Issues**

```python
# Check if file exists
import os
print(os.path.exists("rice_emergency_model.h5"))

# Check file size
file_size = os.path.getsize("rice_emergency_model.h5") / (1024*1024)
print(f"Model size: {file_size:.2f} MB")

# Try loading manually
import tensorflow as tf
model = tf.keras.models.load_model("rice_emergency_model.h5")
print(f"Model input shape: {model.input_shape}")
```

### **Connection Issues**

**Flutter can't connect to backend:**
- ✅ Backend is running on correct IP/port
- ✅ Firewall allows port 5000
- ✅ Phone/emulator on same network
- ✅ CORS is enabled (Flask-CORS installed)

**Test connection:**
```bash
# From phone browser, visit:
http://YOUR_IP:5000/health

# Should show JSON response
```

### **Prediction Errors**

**Wrong class names:**
```python
# Check your model's expected classes
# Update class_names list in rice_disease_api.py if needed
```

**Preprocessing mismatch:**
```python
# Your model expects: 224x224, rescaled by 1./255
# This is already configured in the API
```

## 🌐 **Deployment Options**

### **Local Development**
- ✅ Backend: `python rice_disease_api.py`
- ✅ Frontend: `flutter run`
- ✅ Perfect for testing

### **Cloud Deployment**

**Heroku (Free tier available):**
```bash
# Create Procfile
echo "web: gunicorn rice_disease_api:app" > Procfile

# Deploy
git init
git add .
git commit -m "Deploy rice disease API"
heroku create your-rice-app
git push heroku main

# Update Flutter with: https://your-rice-app.herokuapp.com
```

**Railway/Render:**
- Upload code to GitHub
- Connect repository
- Set start command: `python rice_disease_api.py`

### **Production Considerations**

```python
# For production, update rice_disease_api.py:
if __name__ == '__main__':
    # Development
    app.run(debug=True, host='0.0.0.0', port=5000)
    
    # Production
    # app.run(debug=False, host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
```

## 📊 **API Reference**

### **Endpoints Your Flutter App Uses:**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Check API status |
| `/predict` | POST | Predict disease from image |
| `/diseases` | GET | Get all disease info |
| `/model-info` | GET | Get model details |

### **Prediction Request:**

```javascript
// Multipart file upload
POST /predict
Content-Type: multipart/form-data
Body: image file

// OR Base64 image
POST /predict
Content-Type: application/json
Body: {
  "image_base64": "data:image/jpeg;base64,/9j/4AAQ..."
}
```

### **Prediction Response:**

```json
{
  "success": true,
  "prediction": {
    "disease": "Bacterial Leaf Blight",
    "confidence": 0.92,
    "confidence_level": "Very High",
    "treatment": "Apply copper-based bactericides...",
    "disease_type": "disease"
  },
  "top_predictions": [
    {"disease": "Bacterial Leaf Blight", "confidence": 0.92},
    {"disease": "Brown Spot", "confidence": 0.05}
  ],
  "all_predictions": {
    "Bacterial Leaf Blight": 0.92,
    "Brown Spot": 0.05,
    "Healthy Rice Leaf": 0.02
  }
}
```

## ✅ **Success Checklist**

- [ ] Downloaded `rice_emergency_model.h5` from Kaggle
- [ ] Placed model file in project directory
- [ ] Installed Python dependencies (`pip install -r requirements.txt`)
- [ ] Backend starts successfully (`python rice_disease_api.py`)
- [ ] Health endpoint returns 200 (`curl localhost:5000/health`)
- [ ] Updated Flutter API URL (`lib/services/rice_disease_api_service.dart`)
- [ ] Flutter app connects to backend
- [ ] End-to-end prediction works (photo → result)

## 🎯 **Next Steps**

1. **Test with real rice images** from your dataset
2. **Deploy to cloud** for production use  
3. **Optimize model size** if needed for mobile
4. **Add error handling** for edge cases
5. **Monitor API performance** and usage

**🎉 You're ready to connect your Kaggle model to your Flutter app!**

---

**Need help?** Check the specific error messages and refer to the troubleshooting section above.