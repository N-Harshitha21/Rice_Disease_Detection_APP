import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/disease_result_model.dart';
import '../services/rice_disease_api_service.dart' as api;

class DiseaseDetectionProvider extends ChangeNotifier {
  
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;
  DiseaseResultModel? _latestResult;
  List<DiseaseResultModel> _detectionHistory = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;
  DiseaseResultModel? get latestResult => _latestResult;
  List<DiseaseResultModel> get detectionHistory => _detectionHistory;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Pick image from camera
  Future<bool> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _latestResult = null; // Clear previous result
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to capture image: ${e.toString()}');
      return false;
    }
  }

  // Pick image from gallery
  Future<bool> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _latestResult = null; // Clear previous result
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to select image: ${e.toString()}');
      return false;
    }
  }

  // Analyze selected image for disease detection
  Future<bool> analyzeImage() async {
    if (_selectedImage == null) {
      _setError('No image selected for analysis');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      // Call the rice disease API service
      final apiResponse = await api.RiceDiseaseApiService.predictFromFile(_selectedImage!);
      
      if (apiResponse.success && apiResponse.data != null) {
        // Convert API response to DiseaseResultModel
        final result = _convertApiResponseToModel(apiResponse.data!, _selectedImage!.path);
        
        _latestResult = result;
        _detectionHistory.insert(0, result); // Add to beginning of history
        
        // Keep only last 50 results
        if (_detectionHistory.length > 50) {
          _detectionHistory = _detectionHistory.take(50).toList();
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(apiResponse.error ?? 'Failed to analyze image. Please try again.');
        return false;
      }
    } catch (e) {
      _setError('Analysis failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get treatment recommendations for a specific disease
  List<String> getTreatmentRecommendations(String diseaseName) {
    final treatments = {
      'Bacterial Leaf Blight': [
        '🔬 Apply copper-based bactericides (Copper oxychloride)',
        '💧 Improve field drainage and water management',
        '🌱 Use resistant rice varieties (IR64, Swarna-Sub1)',
        '🗑️ Remove and destroy infected plant debris',
        '⏰ Apply treatment early in the morning or evening',
      ],
      'Brown Spot': [
        '🧪 Apply fungicides (Mancozeb 75% WP @ 2g/L)',
        '🌾 Improve soil fertility with balanced NPK fertilizer',
        '📏 Maintain proper plant spacing (20x15 cm)',
        '🌱 Use certified disease-free seeds',
        '💧 Ensure proper water management',
      ],
      'Healthy Rice Leaf': [
        '✅ Continue current management practices',
        '👀 Monitor regularly for early disease detection',
        '🌾 Maintain proper nutrition and water management',
        '🧹 Keep field clean and weed-free',
        '📊 Regular soil testing and nutrient management',
      ],
      'Leaf Blast': [
        '💊 Apply systemic fungicides (Tricyclazole 75% WP)',
        '🛡️ Use blast-resistant varieties (Pusa Basmati-1)',
        '🚫 Avoid excessive nitrogen fertilization',
        '💧 Maintain alternate wetting and drying',
        '🌬️ Ensure good air circulation in fields',
      ],
      'Leaf scald': [
        '🧪 Apply fungicides at early infection stage',
        '🌬️ Improve air circulation in field',
        '✂️ Remove infected leaves and plant debris',
        '🌱 Use resistant cultivars when available',
        '💧 Avoid overhead irrigation',
      ],
      'Narrow Brown Leaf Spot': [
        '⏰ Apply fungicides during early infection',
        '🧹 Improve field sanitation practices',
        '⚖️ Use balanced fertilization program',
        '📏 Ensure proper plant spacing',
        '🌾 Use healthy, certified seeds',
      ],
      'Rice Hispa': [
        '🐛 Apply insecticides (Chlorpyrifos 20% EC)',
        '🪤 Use pheromone traps for monitoring',
        '🌿 Remove grassy weeds around field',
        '🐞 Encourage natural predators (spiders, birds)',
        '🚜 Use mechanical control methods',
      ],
      'Sheath Blight': [
        '💊 Apply fungicides (Validamycin 3% L @ 2.5ml/L)',
        '💧 Improve field drainage',
        '📉 Reduce plant density',
        '⚡ Apply silicon fertilizers to strengthen plants',
        '🌾 Use resistant varieties when available',
      ],
    };

    return treatments[diseaseName] ?? [
      '🔍 Consult with agricultural expert',
      '📞 Contact local extension services',
      '🌾 Monitor plant health regularly',
    ];
  }

  // Get severity level based on confidence
  String getSeverityLevel(double confidence) {
    if (confidence >= 0.9) return 'Very High';
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.7) return 'Moderate';
    if (confidence >= 0.6) return 'Low';
    return 'Very Low';
  }

  // Get severity color
  Color getSeverityColor(double confidence) {
    if (confidence >= 0.9) return Colors.red;
    if (confidence >= 0.8) return Colors.orange;
    if (confidence >= 0.7) return Colors.yellow[700]!;
    if (confidence >= 0.6) return Colors.lightGreen;
    return Colors.green;
  }

  // Get confidence level description
  String getConfidenceDescription(double confidence) {
    if (confidence >= 0.8) {
      return 'High confidence prediction - Recommended for immediate action';
    } else if (confidence >= 0.6) {
      return 'Medium confidence - Consider expert verification';
    } else {
      return 'Low confidence - Manual inspection strongly recommended';
    }
  }

  // Clear selected image and result
  void clearSelection() {
    _selectedImage = null;
    _latestResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Remove result from history
  void removeFromHistory(String resultId) {
    _detectionHistory.removeWhere((result) => result.id == resultId);
    notifyListeners();
  }

  // Clear all history
  void clearHistory() {
    _detectionHistory.clear();
    notifyListeners();
  }

  // Convert API response to DiseaseResultModel
  DiseaseResultModel _convertApiResponseToModel(api.PredictionResult apiResult, String imagePath) {
    // Convert top predictions from API format to model format
    final topPredictions = apiResult.topPredictions.asMap().entries.map((entry) {
      return PredictionResult(  // This refers to the model's PredictionResult
        diseaseName: entry.value.disease,
        confidence: entry.value.confidence,
        rank: entry.key + 1,
      );
    }).toList();

    // Get treatment recommendations for the predicted disease
    final treatments = getTreatmentRecommendations(apiResult.prediction.disease);
    
    // Generate recommendation based on confidence
    final recommendation = _getRecommendation(apiResult.prediction.confidence, apiResult.prediction.disease);

    return DiseaseResultModel(
      predictedDisease: apiResult.prediction.disease,
      confidence: apiResult.prediction.confidence,
      confidenceLevel: apiResult.prediction.confidenceLevel,
      topPredictions: topPredictions,
      imagePath: imagePath,
      recommendation: recommendation,
      treatmentSteps: treatments,
    );
  }

  // Generate recommendation based on confidence and disease
  String _getRecommendation(double confidence, String disease) {
    if (confidence >= 0.8) {
      if (disease.toLowerCase().contains('healthy')) {
        return 'Your rice plant appears healthy! Continue with current care practices.';
      } else {
        return 'High confidence detection. Immediate treatment recommended.';
      }
    } else if (confidence >= 0.6) {
      return 'Moderate confidence. Consider consulting with an agricultural expert.';
    } else {
      return 'Low confidence prediction. Manual inspection by an expert is strongly recommended.';
    }
  }

  // Get statistics from detection history
  Map<String, dynamic> getDetectionStatistics() {
    if (_detectionHistory.isEmpty) {
      return {
        'totalDetections': 0,
        'healthyCount': 0,
        'diseasedCount': 0,
        'averageConfidence': 0.0,
        'mostCommonDisease': 'None',
        'diseaseDistribution': <String, int>{},
      };
    }

    final diseaseCount = <String, int>{};
    double totalConfidence = 0.0;
    int healthyCount = 0;
    int diseasedCount = 0;

    for (final result in _detectionHistory) {
      totalConfidence += result.confidence;
      
      if (result.predictedDisease.toLowerCase().contains('healthy')) {
        healthyCount++;
      } else {
        diseasedCount++;
      }

      diseaseCount[result.predictedDisease] = 
          (diseaseCount[result.predictedDisease] ?? 0) + 1;
    }

    final mostCommonDisease = diseaseCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'totalDetections': _detectionHistory.length,
      'healthyCount': healthyCount,
      'diseasedCount': diseasedCount,
      'averageConfidence': totalConfidence / _detectionHistory.length,
      'mostCommonDisease': mostCommonDisease,
      'diseaseDistribution': diseaseCount,
    };
  }
}