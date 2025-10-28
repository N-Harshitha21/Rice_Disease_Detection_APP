import 'lib/services/rice_disease_api_service.dart';

void main() async {
  print('🔍 Testing Flutter API Service...');
  print('=' * 50);
  
  // Test 1: Health Check using Flutter service
  print('\n1️⃣ Testing Health Check via Flutter Service...');
  try {
    final healthResponse = await RiceDiseaseApiService.checkHealth();
    
    if (healthResponse.success) {
      print('✅ Health Check Success!');
      print('✅ Status: ${healthResponse.data?.status}');
      print('✅ Model Loaded: ${healthResponse.data?.modelLoaded}');
      print('✅ Timestamp: ${healthResponse.data?.timestamp}');
    } else {
      print('❌ Health Check Failed: ${healthResponse.error}');
    }
  } catch (e) {
    print('❌ Health Check Exception: $e');
  }
  
  // Test 2: Get Diseases
  print('\n2️⃣ Testing Get Diseases...');
  try {
    final diseasesResponse = await RiceDiseaseApiService.getDiseases();
    
    if (diseasesResponse.success) {
      print('✅ Diseases Retrieved: ${diseasesResponse.data?.length} diseases');
      for (var disease in diseasesResponse.data!) {
        print('   - ${disease.name} (${disease.type})');
      }
    } else {
      print('❌ Get Diseases Failed: ${diseasesResponse.error}');
    }
  } catch (e) {
    print('❌ Get Diseases Exception: $e');
  }
  
  // Test 3: Get Model Info
  print('\n3️⃣ Testing Get Model Info...');
  try {
    final modelResponse = await RiceDiseaseApiService.getModelInfo();
    
    if (modelResponse.success) {
      print('✅ Model Info Retrieved!');
      print('✅ Architecture: ${modelResponse.data?.architecture}');
      print('✅ Classes: ${modelResponse.data?.numClasses}');
      print('✅ Input Size: ${modelResponse.data?.inputSize}');
    } else {
      print('❌ Get Model Info Failed: ${modelResponse.error}');
    }
  } catch (e) {
    print('❌ Get Model Info Exception: $e');
  }
  
  print('\n' + '=' * 50);
  print('🎯 Flutter API Service Test Complete!');
}