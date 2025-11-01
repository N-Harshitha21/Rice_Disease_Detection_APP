import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/disease_info_model.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final DiseaseInfo disease;

  const DiseaseDetailScreen({
    super.key,
    required this.disease,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                disease.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      disease.severityColor.withOpacity(0.8),
                      disease.severityColor,
                    ],
                  ),
                ),
                child: disease.imagePath != null
                    ? Image.asset(
                        disease.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Card
                  _buildBasicInfoCard(context),
                  
                  const SizedBox(height: 20),
                  
                  // Symptoms Section
                  _buildSection(
                    context,
                    'Symptoms',
                    Icons.warning,
                    disease.symptoms,
                    AppTheme.errorRed,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Causes Section
                  _buildSection(
                    context,
                    'Causes & Conditions',
                    Icons.info,
                    disease.causes,
                    AppTheme.warningOrange,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Prevention Section
                  _buildSection(
                    context,
                    'Prevention Methods',
                    Icons.shield,
                    disease.preventionMethods,
                    AppTheme.successGreen,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Treatment Section
                  _buildSection(
                    context,
                    'Treatment Methods',
                    Icons.healing,
                    disease.treatmentMethods,
                    AppTheme.primaryGreen,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Additional Info
                  _buildAdditionalInfoCard(context),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            disease.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Scientific Name
          Row(
            children: [
              Icon(Icons.science, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  disease.scientificName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Category and Severity
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  'Category',
                  disease.category,
                  _getCategoryColor(disease.category),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  'Severity',
                  disease.severity,
                  disease.severityColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Yield Loss
          Row(
            children: [
              Icon(Icons.trending_down, color: AppTheme.errorRed, size: 20),
              const SizedBox(width: 8),
              Text(
                'Potential Yield Loss: ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${disease.yieldLoss.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            disease.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Affected Stages
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: disease.affectedStages.map((stage) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  stage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<String> items,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Items List
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.secondaryGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Tips',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '• Regular field monitoring helps in early detection\n'
            '• Integrated disease management is most effective\n'
            '• Consult agricultural experts for severe infestations\n'
            '• Keep records of disease occurrence for future planning\n'
            '• Use our AI detection for quick field diagnosis',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppTheme.primaryGreen.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Fungal':
        return AppTheme.errorRed;
      case 'Bacterial':
        return AppTheme.warningOrange;
      case 'Viral':
        return AppTheme.primaryGreen;
      case 'Insect':
        return AppTheme.accentOrange;
      case 'Normal':
        return AppTheme.successGreen;
      default:
        return AppTheme.textSecondary;
    }
  }
}