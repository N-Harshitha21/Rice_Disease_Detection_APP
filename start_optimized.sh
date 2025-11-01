#!/bin/bash
echo "🚀 Starting Optimized Rice Disease API"
echo "📁 Directory: $(pwd)"
echo "📊 Model file:"
ls -la *.h5 || echo "No model files found"

echo "🐍 Environment:"
python --version
python -c "import sys; print(f'Python path: {sys.executable}')"

echo "📦 TensorFlow check:"
python -c "
try:
    import tensorflow as tf
    print(f'✅ TensorFlow {tf.__version__} available')
    print(f'🔧 Devices: {tf.config.list_physical_devices()}')
except Exception as e:
    print(f'❌ TensorFlow error: {e}')
"

echo "🔥 Starting server with extended timeout..."
exec gunicorn --bind 0.0.0.0:$PORT --timeout 600 --workers 1 --preload rice_disease_api_optimized:app
