import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DiseaseInfo {
  final String name;
  final String scientificName;
  final String category;
  final String severity;
  final Color severityColor;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> preventionMethods;
  final List<String> treatmentMethods;
  final String? imagePath;
  final double yieldLoss;
  final List<String> affectedStages;

  const DiseaseInfo({
    required this.name,
    required this.scientificName,
    required this.category,
    required this.severity,
    required this.severityColor,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.preventionMethods,
    required this.treatmentMethods,
    this.imagePath,
    required this.yieldLoss,
    required this.affectedStages,
  });

  static List<DiseaseInfo> getAllDiseases() {
    return [
      // 1. Bacterial Leaf Blight
      const DiseaseInfo(
        name: 'Bacterial Leaf Blight',
        scientificName: 'Xanthomonas oryzae pv. oryzae',
        category: 'Bacterial',
        severity: 'High',
        severityColor: AppTheme.errorRed,
        description: 'One of the most serious bacterial diseases of rice, causing significant yield losses. The disease affects leaves, causing characteristic yellow to white stripes along leaf margins.',
        symptoms: [
          'Yellow to white stripes along leaf margins',
          'Water-soaked lesions that turn yellow',
          'Leaves dry up and die in severe cases',
          'Kresek symptom (wilting of seedlings)',
          'Greyish-green water-soaked areas',
        ],
        causes: [
          'High humidity (above 70%)',
          'Temperature between 25-30°C',
          'Wounds from insects or mechanical injury',
          'Contaminated seeds',
          'Infected crop residues',
          'Flooding conditions',
        ],
        preventionMethods: [
          'Use certified disease-free seeds',
          'Plant resistant varieties',
          'Maintain proper field sanitation',
          'Avoid injury to plants during cultivation',
          'Control weeds and alternate hosts',
          'Proper water management',
        ],
        treatmentMethods: [
          'Apply copper-based bactericides',
          'Use streptomycin sulfate (where permitted)',
          'Remove and destroy infected plants',
          'Apply balanced fertilizers',
          'Avoid overhead irrigation',
          'Crop rotation with non-host crops',
        ],
        yieldLoss: 20.0,
        affectedStages: ['Seedling', 'Tillering', 'Booting', 'Flowering'],
      ),

      // 2. Brown Spot
      const DiseaseInfo(
        name: 'Brown Spot',
        scientificName: 'Bipolaris oryzae',
        category: 'Fungal',
        severity: 'Medium',
        severityColor: AppTheme.warningOrange,
        description: 'A common fungal disease that causes brown spots on rice leaves and grains. It can significantly reduce grain quality and yield, especially under stress conditions.',
        symptoms: [
          'Small circular to oval brown spots on leaves',
          'Dark brown spots with light centers',
          'Spots may have yellow halos',
          'Affected grains become discolored',
          'Seedling blight in severe cases',
        ],
        causes: [
          'High humidity and moderate temperatures',
          'Nutrient deficiency (especially silica)',
          'Drought stress',
          'Poor soil conditions',
          'Infected seeds',
          'Wind-blown spores',
        ],
        preventionMethods: [
          'Use healthy, certified seeds',
          'Maintain adequate soil nutrition',
          'Apply silica amendments',
          'Ensure proper drainage',
          'Avoid water stress',
          'Plant resistant varieties',
        ],
        treatmentMethods: [
          'Apply fungicides (tricyclazole, propiconazole)',
          'Improve soil fertility',
          'Apply potassium and silica fertilizers',
          'Seed treatment with fungicides',
          'Remove infected plant debris',
          'Proper water management',
        ],
        yieldLoss: 15.0,
        affectedStages: ['All stages', 'Especially grain filling'],
      ),

      // 3. Leaf Blast
      const DiseaseInfo(
        name: 'Leaf Blast',
        scientificName: 'Magnaporthe oryzae',
        category: 'Fungal',
        severity: 'High',
        severityColor: AppTheme.errorRed,
        description: 'The most destructive disease of rice worldwide. It affects leaves, nodes, and panicles, causing significant yield losses if not controlled properly.',
        symptoms: [
          'Diamond-shaped lesions with gray centers',
          'Brown to reddish-brown borders',
          'Small water-soaked spots initially',
          'Lesions may coalesce and kill leaves',
          'Neck blast on panicles',
        ],
        causes: [
          'High humidity (above 90%)',
          'Temperature 20-30°C',
          'Dense plant canopy',
          'Excessive nitrogen fertilization',
          'Poor air circulation',
          'Continuous rice cultivation',
        ],
        preventionMethods: [
          'Plant resistant varieties',
          'Avoid excessive nitrogen application',
          'Maintain proper plant spacing',
          'Use clean seeds',
          'Crop rotation',
          'Remove infected crop residues',
        ],
        treatmentMethods: [
          'Apply fungicides (tricyclazole, isoprothiolane)',
          'Reduce nitrogen fertilizer',
          'Improve field drainage',
          'Apply silica amendments',
          'Remove infected plants',
          'Balanced fertilization',
        ],
        yieldLoss: 50.0,
        affectedStages: ['All stages', 'Most critical at tillering and heading'],
      ),

      // 4. Leaf Scald
      const DiseaseInfo(
        name: 'Leaf Scald',
        scientificName: 'Monographella albescens',
        category: 'Fungal',
        severity: 'Medium',
        severityColor: AppTheme.warningOrange,
        description: 'A fungal disease that causes scalded appearance on rice leaves. It typically occurs in cooler, humid conditions and can reduce photosynthetic capacity.',
        symptoms: [
          'Large irregular brown blotches',
          'Lesions have distinct margins',
          'Scalded or burned appearance',
          'Lesions start from leaf tips',
          'May cover entire leaf blade',
        ],
        causes: [
          'Cool, humid weather',
          'Temperature 15-25°C',
          'High relative humidity',
          'Dense plant growth',
          'Poor air circulation',
          'Infected seeds or debris',
        ],
        preventionMethods: [
          'Plant resistant varieties',
          'Maintain proper plant spacing',
          'Ensure good field drainage',
          'Use certified clean seeds',
          'Remove crop residues',
          'Avoid late planting',
        ],
        treatmentMethods: [
          'Apply fungicides (propiconazole, tebuconazole)',
          'Improve air circulation',
          'Reduce plant density',
          'Apply balanced fertilizers',
          'Remove infected leaves',
          'Adjust planting time',
        ],
        yieldLoss: 10.0,
        affectedStages: ['Tillering', 'Booting', 'Heading'],
      ),

      // 5. Leaf Smut
      const DiseaseInfo(
        name: 'Leaf Smut',
        scientificName: 'Entyloma oryzae',
        category: 'Fungal',
        severity: 'Low',
        severityColor: AppTheme.successGreen,
        description: 'A fungal disease that produces black sooty masses on rice leaves. Generally causes minor damage but can affect plant vigor and grain quality.',
        symptoms: [
          'Small black sooty spots on leaves',
          'Spots may be linear or angular',
          'Black powdery masses of spores',
          'Yellowing around infected areas',
          'Reduced plant vigor',
        ],
        causes: [
          'High humidity and warm temperatures',
          'Poor field sanitation',
          'Dense plant populations',
          'Infected crop residues',
          'Wind dispersal of spores',
          'Stress conditions',
        ],
        preventionMethods: [
          'Maintain field sanitation',
          'Use resistant varieties',
          'Proper plant spacing',
          'Remove infected plant debris',
          'Balanced fertilization',
          'Good drainage',
        ],
        treatmentMethods: [
          'Apply systemic fungicides',
          'Remove infected plants',
          'Improve air circulation',
          'Apply potassium fertilizers',
          'Reduce plant density',
          'Clean cultivation practices',
        ],
        yieldLoss: 5.0,
        affectedStages: ['Vegetative stages', 'Early reproductive'],
      ),

      // 6. Rice Hispa
      const DiseaseInfo(
        name: 'Rice Hispa',
        scientificName: 'Dicladispa armigera',
        category: 'Insect',
        severity: 'Medium',
        severityColor: AppTheme.warningOrange,
        description: 'An insect pest that creates characteristic white streaks on rice leaves by scraping the leaf surface. Adult beetles and larvae both cause damage.',
        symptoms: [
          'White transparent streaks on leaves',
          'Parallel lines along leaf veins',
          'Scraped leaf surface appearance',
          'Reduced green leaf area',
          'Stunted plant growth',
        ],
        causes: [
          'Adult hispa beetles feeding',
          'Larvae mining inside leaves',
          'High humidity conditions',
          'Dense crop canopy',
          'Presence of alternate hosts',
          'Migration from nearby fields',
        ],
        preventionMethods: [
          'Use light traps for monitoring',
          'Maintain clean field bunds',
          'Remove alternate host plants',
          'Proper field sanitation',
          'Avoid dense planting',
          'Use resistant varieties',
        ],
        treatmentMethods: [
          'Apply insecticides (chlorpyrifos, cartap)',
          'Use light traps for adult control',
          'Encourage natural enemies',
          'Hand picking where feasible',
          'Spray neem-based products',
          'Apply systemic insecticides',
        ],
        yieldLoss: 15.0,
        affectedStages: ['Tillering', 'Early vegetative'],
      ),

      // 7. Sheath Blight
      const DiseaseInfo(
        name: 'Sheath Blight',
        scientificName: 'Rhizoctonia solani',
        category: 'Fungal',
        severity: 'High',
        severityColor: AppTheme.errorRed,
        description: 'A major fungal disease that affects rice sheaths and stems. It spreads rapidly under favorable conditions and can cause significant yield losses.',
        symptoms: [
          'Elliptical lesions on leaf sheaths',
          'Lesions with brown margins and gray centers',
          'Sclerotia formation on infected tissues',
          'Lodging of plants in severe cases',
          'Reduced grain filling',
        ],
        causes: [
          'High humidity and temperature',
          'Dense plant canopy',
          'Excessive nitrogen fertilization',
          'Poor air circulation',
          'Infected soil or crop residues',
          'Close plant spacing',
        ],
        preventionMethods: [
          'Avoid excessive nitrogen application',
          'Maintain proper plant spacing',
          'Ensure good drainage',
          'Use certified clean seeds',
          'Remove crop residues',
          'Plant resistant varieties',
        ],
        treatmentMethods: [
          'Apply fungicides (validamycin, hexaconazole)',
          'Reduce nitrogen fertilizer',
          'Improve air circulation',
          'Apply potassium fertilizers',
          'Remove infected plant parts',
          'Balanced fertilization',
        ],
        yieldLoss: 25.0,
        affectedStages: ['Tillering', 'Booting', 'Heading', 'Grain filling'],
      ),

      // 8. Healthy Rice Leaf
      const DiseaseInfo(
        name: 'Healthy Rice Leaf',
        scientificName: 'Oryza sativa (Normal)',
        category: 'Normal',
        severity: 'None',
        severityColor: AppTheme.successGreen,
        description: 'Represents a healthy rice leaf with no signs of disease or pest damage. Healthy leaves are essential for optimal photosynthesis and grain production.',
        symptoms: [
          'Bright green color',
          'No spots or lesions',
          'Upright leaf posture',
          'Smooth leaf surface',
          'No discoloration',
        ],
        causes: [
          'Optimal growing conditions',
          'Balanced nutrition',
          'Good water management',
          'Disease-free environment',
          'Proper plant spacing',
          'Resistant varieties',
        ],
        preventionMethods: [
          'Maintain optimal nutrition',
          'Ensure proper water management',
          'Use certified seeds',
          'Practice integrated pest management',
          'Monitor field regularly',
          'Maintain field sanitation',
        ],
        treatmentMethods: [
          'Continue good practices',
          'Regular monitoring',
          'Preventive measures',
          'Balanced fertilization',
          'Proper irrigation',
          'Integrated management',
        ],
        yieldLoss: 0.0,
        affectedStages: ['All stages (maintain health)'],
      ),
    ];
  }

  static DiseaseInfo? getDiseaseByName(String name) {
    try {
      return getAllDiseases().firstWhere(
        (disease) => disease.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static List<DiseaseInfo> getDiseasesByCategory(String category) {
    return getAllDiseases().where((disease) => disease.category == category).toList();
  }

  static List<DiseaseInfo> getDiseasesBySeverity(String severity) {
    return getAllDiseases().where((disease) => disease.severity == severity).toList();
  }
}