import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'lib/services/rice_disease_api_service.dart';

void main() async {
  print('🔍 Testing Prediction Flow...');
  print('=' * 50);
  
  // Test with a dummy image (creating a small test image)
  print('\n1️⃣ Creating test image...');
  
  // Create a simple test image file (3x3 pixels, saved as PNG)
  final testImageBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG header
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
    0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x03, // 3x3 image
    0x08, 0x02, 0x00, 0x00, 0x00, 0xD9, 0x4A, 0x22,
    0xE1, 0x00, 0x00, 0x00, 0x12, 0x49, 0x44, 0x41,
    0x54, 0x08, 0x99, 0x01, 0x07, 0x00, 0xF8, 0xFF,
    0x00, 0xFF, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00,
    0x02, 0x02, 0x01, 0x48, 0xAF, 0x0E, 0xB7, 0x00,
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82
  ]);
  
  final testImageFile = File('test_image.png');
  await testImageFile.writeAsBytes(testImageBytes);
  print('✅ Test image created: ${testImageFile.path}');
  print('✅ File size: ${await testImageFile.length()} bytes');
  
  // Test 1: Predict from file
  print('\n2️⃣ Testing prediction from file...');
  try {
    final response = await RiceDiseaseApiService.predictFromFile(testImageFile);
    
    if (response.success) {
      print('✅ Prediction Success!');
      print('✅ Disease: ${response.data?.prediction.disease}');
      print('✅ Confidence: ${response.data?.prediction.confidence.toStringAsFixed(3)}');
      print('✅ Confidence Level: ${response.data?.prediction.confidenceLevel}');
      print('✅ Treatment: ${response.data?.prediction.treatment.substring(0, 50)}...');
      print('✅ Top 3 predictions:');
      for (var pred in response.data!.topPredictions) {
        print('   - ${pred.disease}: ${pred.confidence.toStringAsFixed(3)}');
      }
    } else {
      print('❌ Prediction Failed: ${response.error}');
    }
  } catch (e) {
    print('❌ Prediction Exception: $e');
  }
  
  // Test 2: Predict from bytes
  print('\n3️⃣ Testing prediction from bytes...');
  try {
    final imageBytes = await testImageFile.readAsBytes();
    final response = await RiceDiseaseApiService.predictFromBytes(imageBytes);
    
    if (response.success) {
      print('✅ Bytes Prediction Success!');
      print('✅ Disease: ${response.data?.prediction.disease}');
      print('✅ Confidence: ${response.data?.prediction.confidence.toStringAsFixed(3)}');
    } else {
      print('❌ Bytes Prediction Failed: ${response.error}');
    }
  } catch (e) {
    print('❌ Bytes Prediction Exception: $e');
  }
  
  // Test 3: Predict from base64
  print('\n4️⃣ Testing prediction from base64...');
  try {
    final imageBytes = await testImageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final response = await RiceDiseaseApiService.predictFromBase64(base64Image);
    
    if (response.success) {
      print('✅ Base64 Prediction Success!');
      print('✅ Disease: ${response.data?.prediction.disease}');
      print('✅ Confidence: ${response.data?.prediction.confidence.toStringAsFixed(3)}');
    } else {
      print('❌ Base64 Prediction Failed: ${response.error}');
    }
  } catch (e) {
    print('❌ Base64 Prediction Exception: $e');
  }
  
  // Clean up
  print('\n5️⃣ Cleaning up...');
  await testImageFile.delete();
  print('✅ Test image deleted');
  
  print('\n' + '=' * 50);
  print('🎯 Prediction Flow Test Complete!');
  print('\n💡 If all tests passed, the backend is working correctly.');
  print('   The issue might be in the Flutter app UI or provider logic.');
}