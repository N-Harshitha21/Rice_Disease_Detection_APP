import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Flutter to Backend Connection...');
  print('=' * 50);
  
  const String baseUrl = 'http://192.168.182.140:5000';
  
  // Test 1: Health Check
  print('\n1️⃣ Testing Health Endpoint...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 10));
    
    print('✅ Status Code: ${response.statusCode}');
    print('✅ Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Model Loaded: ${data['model_loaded']}');
    }
  } catch (e) {
    print('❌ Health Check Failed: $e');
  }
  
  // Test 2: Model Info
  print('\n2️⃣ Testing Model Info Endpoint...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/model-info'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 10));
    
    print('✅ Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Model Classes: ${data['model_info']['num_classes']}');
      print('✅ Architecture: ${data['model_info']['architecture']}');
    } else {
      print('❌ Error Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Model Info Failed: $e');
  }
  
  // Test 3: Diseases Endpoint
  print('\n3️⃣ Testing Diseases Endpoint...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/diseases'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 10));
    
    print('✅ Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Number of Diseases: ${data['diseases'].length}');
    }
  } catch (e) {
    print('❌ Diseases Failed: $e');
  }
  
  print('\n' + '=' * 50);
  print('🎯 Connection Test Complete!');
}