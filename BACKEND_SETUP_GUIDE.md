# 🚀 **Backend Setup Guide - Kaggle to Flutter Connection**

## **📋 Quick Setup Steps**

### **Step 1: Get Your Model from Kaggle**

#### **Option A: Download Model File**
1. **Go to your Kaggle notebook**
2. **Navigate to the Output section**
3. **Download your trained model** (usually `.h5` or `.pkl` file)
4. **Place it in your project folder**

#### **Option B: Copy Training Code**
1. **Copy your model training code** from Kaggle
2. **Save the trained model** locally
3. **Use the saved model** in the Flask API

### **Step 2: Setup Local Environment**

```bash
# Create virtual environment
python -m venv rice_disease_env

# Activate virtual environment
# Windows:
rice_disease_env\Scripts\activate
# Mac/Linux:
source rice_disease_env/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### **Step 3: Configure the Flask API**

**Edit `flask_api_template.py`:**

1. **Update model path** (line 21):
```python
model_path = "your_model.h5"  # Replace with your actual model file
```

2. **Update preprocessing** (line 32-50):
```python
def preprocess_image(image):
    # UPDATE THIS based on your Kaggle preprocessing
    image = image.convert('RGB')
    image = image.resize((224, 224))  # Use your model's input size
    image_array = np.array(image)
    image_array = image_array / 255.0  # Use your normalization method
    image_array = np.expand_dims(image_array, axis=0)
    return image_array
```

3. **Update class names** (line 11-20):
```python
class_names = [
    # Replace with your exact class names from Kaggle
    'Bacterial Leaf Blight',
    'Brown Spot', 
    'Healthy Rice Leaf',
    # ... add all your classes
]
```

### **Step 4: Test the Backend**

```bash
# Run the Flask API
python flask_api_template.py
```

**Expected output:**
```
Loading model...
✅ Model loaded successfully!
🚀 Starting Flask API server...
* Running on all addresses (0.0.0.0)
* Running on http://127.0.0.1:5000
* Running on http://YOUR_IP:5000
```

**Test the API:**
```bash
# Test health endpoint
curl http://localhost:5000/health

# Expected response:
{
  "status": "healthy",
  "model_loaded": true,
  "timestamp": "2024-01-15T10:30:00"
}
```

### **Step 5: Update Flutter Frontend**

**Edit `lib/services/rice_disease_api_service.dart`** (line 8):
```dart
static const String baseUrl = 'http://YOUR_IP:5000'; // Update this
```

**For testing:**
- **Local**: `http://localhost:5000`
- **Network**: `http://192.168.x.x:5000` (your computer's IP)
- **Production**: `https://your-deployed-api.com`

### **Step 6: Test Complete Connection**

1. **Start backend**: `python flask_api_template.py`
2. **Start Flutter app**: `flutter run`
3. **Take a photo** in the app
4. **Check if prediction works**

## **🔧 Troubleshooting**

### **Common Issues:**

#### **Model Loading Error**
```python
# Check if model file exists
import os
print(os.path.exists("your_model.h5"))

# Try different loading methods
model = tf.keras.models.load_model("your_model.h5", compile=False)
```

#### **Image Preprocessing Mismatch**
- **Make sure preprocessing matches** your Kaggle training
- **Check input shape**: `model.input_shape`
- **Verify normalization**: Same as training (0-1 or -1 to 1)

#### **Connection Issues**
- **Check firewall**: Allow port 5000
- **Use correct IP**: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- **CORS enabled**: Flask-CORS is installed

#### **Prediction Errors**
- **Class names order**: Must match training order
- **Model compatibility**: TensorFlow version match

## **📊 API Endpoints Reference**

### **Health Check**
```http
GET /health
Response: {
  "status": "healthy",
  "model_loaded": true,
  "timestamp": "2024-01-15T10:30:00"
}
```

### **Predict Disease**
```http
POST /predict
Content-Type: multipart/form-data
Body: image file

OR

POST /predict
Content-Type: application/json
Body: {"image_base64": "base64_encoded_image"}
```

### **Get All Diseases**
```http
GET /diseases
Response: {
  "diseases": [
    {
      "name": "Bacterial Leaf Blight",
      "type": "disease",
      "treatment": "Apply copper-based bactericides..."
    }
  ]
}
```

### **Get Model Info**
```http
GET /model-info
Response: {
  "model_info": {
    "architecture": "Rice Disease Detection Model",
    "input_size": [224, 224, 3],
    "num_classes": 8,
    "classes": ["Bacterial Leaf Blight", ...],
    "parameters": 25600000
  }
}
```

## **🚀 Deployment Options**

### **Option 1: Local Development**
- **Backend**: `python flask_api_template.py`
- **Frontend**: `flutter run`
- **URL**: `http://localhost:5000`

### **Option 2: Cloud Deployment**

#### **Heroku:**
```bash
# Create Procfile
echo "web: gunicorn flask_api_template:app" > Procfile

# Deploy
git init
git add .
git commit -m "Initial commit"
heroku create your-app-name
git push heroku main
```

#### **Railway/Render:**
- **Upload your code** to GitHub
- **Connect repository** to platform
- **Set start command**: `python flask_api_template.py`

### **Option 3: Use Kaggle Directly (Advanced)**
- **Deploy notebook as API** using Kaggle's deployment features
- **Or use Kaggle Kernels API** for predictions

## **✅ Success Checklist**

- [ ] Model downloaded from Kaggle
- [ ] Flask API template configured
- [ ] Model loads successfully
- [ ] Health endpoint returns 200
- [ ] Prediction endpoint works
- [ ] Flutter app connects to backend
- [ ] End-to-end prediction works

## **🎯 Next Steps**

1. **Share your Kaggle notebook link** for specific help
2. **Test with real rice images**
3. **Deploy to cloud** for production use
4. **Optimize performance** if needed

**Need help with any specific step?** Share your Kaggle code and I'll help customize the setup!