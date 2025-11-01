#!/bin/bash
echo "🚀 Rice Disease API - Emergency Deployment"
echo "📊 Environment check:"
echo "Python: $(python --version)"
echo "Pip: $(pip --version)"

echo "📁 Files in directory:"
ls -la *.h5 *.py

echo "🔧 Memory info:"
free -h || echo "Memory info not available"

echo "📦 Installing requirements..."
pip install -r requirements_emergency.txt

echo "🚀 Starting emergency API server..."
exec gunicorn --bind 0.0.0.0:$PORT --timeout 300 --workers 1 --max-requests 100 --preload rice_disease_api_emergency:app
