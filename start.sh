#!/bin/bash
echo "🚀 Starting Rice Disease Detection API on Render.com"
echo "📁 Current directory: $(pwd)"
echo "📊 Available files:"
ls -la *.h5 || echo "No .h5 files found"

echo "🐍 Python version: $(python --version)"
echo "📦 TensorFlow version:"
python -c "import tensorflow as tf; print(f'TensorFlow: {tf.__version__}')" || echo "TensorFlow not available"

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
exec gunicorn --bind 0.0.0.0:$PORT --timeout 600 --workers 1 --preload rice_disease_api:app
