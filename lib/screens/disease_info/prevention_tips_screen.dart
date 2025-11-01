import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class PreventionTipsScreen extends StatelessWidget {
  const PreventionTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prevention Tips'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Healthy Rice, Better Harvest',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prevention is always better than cure. Follow these best practices for disease-free rice cultivation.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Prevention Categories
            ..._getPreventionCategories().map((category) {
              return Column(
                children: [
                  _buildCategoryCard(context, category),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),

            // Emergency Contact Card
            _buildEmergencyContactCard(context),
          ],
        ),
      ),
    );
  }

  List<PreventionCategory> _getPreventionCategories() {
    return [
      PreventionCategory(
        title: 'Field Preparation',
        icon: Icons.landscape,
        color: AppTheme.primaryGreen,
        tips: [
          'Prepare fields properly with good drainage',
          'Remove crop residues and weeds thoroughly',
          'Apply organic matter to improve soil health',
          'Level fields to prevent water stagnation',
          'Test soil pH and adjust if necessary (6.0-7.0)',
          'Use certified, disease-free seeds',
        ],
      ),
      PreventionCategory(
        title: 'Water Management',
        icon: Icons.water_drop,
        color: Colors.blue,
        tips: [
          'Maintain proper water levels (2-5 cm)',
          'Avoid excessive flooding or drought stress',
          'Ensure good drainage during heavy rains',
          'Use clean irrigation water',
          'Practice alternate wetting and drying',
          'Monitor water quality regularly',
        ],
      ),
      PreventionCategory(
        title: 'Nutrient Management',
        icon: Icons.grass,
        color: AppTheme.secondaryGreen,
        tips: [
          'Apply balanced NPK fertilizers',
          'Use organic fertilizers when possible',
          'Apply silicon amendments for disease resistance',
          'Avoid excessive nitrogen fertilization',
          'Monitor plant nutrition regularly',
          'Use micronutrients as needed',
        ],
      ),
      PreventionCategory(
        title: 'Crop Management',
        icon: Icons.agriculture,
        color: AppTheme.warningOrange,
        tips: [
          'Plant resistant varieties suitable for your area',
          'Maintain proper plant spacing',
          'Practice crop rotation with non-rice crops',
          'Remove diseased plants immediately',
          'Avoid late planting in disease-prone seasons',
          'Monitor crops regularly for early detection',
        ],
      ),
      PreventionCategory(
        title: 'Integrated Pest Management',
        icon: Icons.pest_control,
        color: AppTheme.errorRed,
        tips: [
          'Use biological control agents when available',
          'Apply pesticides only when necessary',
          'Rotate different classes of pesticides',
          'Encourage beneficial insects and birds',
          'Use pheromone traps for monitoring',
          'Follow pesticide application guidelines',
        ],
      ),
      PreventionCategory(
        title: 'Harvest & Post-Harvest',
        icon: Icons.agriculture,
        color: AppTheme.accentOrange,
        tips: [
          'Harvest at proper maturity stage',
          'Dry grains to appropriate moisture content',
          'Store in clean, dry conditions',
          'Remove infected grains before storage',
          'Use proper storage containers',
          'Monitor stored grain regularly',
        ],
      ),
    ];
  }

  Widget _buildCategoryCard(BuildContext context, PreventionCategory category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tips List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: category.tips.asMap().entries.map((entry) {
                final index = entry.key;
                final tip = entry.value;
                
                return Container(
                  margin: EdgeInsets.only(bottom: index < category.tips.length - 1 ? 16 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: category.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.errorRed.withOpacity(0.1),
            AppTheme.warningOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.errorRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Emergency Disease Outbreak',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorRed,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'If you notice severe disease symptoms spreading rapidly:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '• Contact your local agricultural extension officer immediately\n'
            '• Take photos for expert identification\n'
            '• Isolate affected areas to prevent spread\n'
            '• Use our AI detection for quick preliminary diagnosis\n'
            '• Follow expert recommendations for treatment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppTheme.errorRed.withOpacity(0.8),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use our AI detection feature for instant disease identification',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PreventionCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> tips;

  const PreventionCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.tips,
  });
}