@echo off
echo 🌾 Starting Rice Disease Detection Backend System
echo ================================================

echo.
echo 1️⃣ Starting Main Backend (Port 5000)...
start "Rice Disease API" cmd /k "python rice_disease_api.py"

timeout /t 3 /nobreak >nul

echo.
echo 2️⃣ Starting Debug Interceptor (Port 5001)...
start "Debug Interceptor" cmd /k "python debug_flutter_issue.py"

timeout /t 2 /nobreak >nul

echo.
echo ✅ Both servers started!
echo.
echo 📍 Main API: http://192.168.182.140:5000
echo 🔍 Debug API: http://192.168.182.140:5001
echo.
echo 📱 Your Flutter app should connect to: http://192.168.182.140:5001
echo.
echo 💡 Test your Flutter app now and watch the Debug window for logs!
echo.
pause