import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSaveResults = true;
  bool _highAccuracyMode = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Settings Section
          _buildSectionHeader('General'),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Receive alerts and updates',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            icon: Icons.save,
            title: 'Auto-save Results',
            subtitle: 'Automatically save detection results',
            value: _autoSaveResults,
            onChanged: (value) {
              setState(() {
                _autoSaveResults = value;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Detection Settings Section
          _buildSectionHeader('Detection Settings'),
          _buildSwitchTile(
            icon: Icons.high_quality,
            title: 'High Accuracy Mode',
            subtitle: 'Use enhanced processing (slower)',
            value: _highAccuracyMode,
            onChanged: (value) {
              setState(() {
                _highAccuracyMode = value;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildDropdownTile(
            icon: Icons.language,
            title: 'Language',
            value: _selectedLanguage,
            items: ['English', 'हिंदी', 'বাংলা', 'தமிழ்'],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
          _buildDropdownTile(
            icon: Icons.palette,
            title: 'Theme',
            value: _selectedTheme,
            items: ['Light', 'Dark', 'System'],
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Data & Privacy Section
          _buildSectionHeader('Data & Privacy'),
          _buildTile(
            icon: Icons.cloud_sync,
            title: 'Sync Data',
            subtitle: 'Sync your data across devices',
            onTap: () {
              _showSyncDialog();
            },
          ),
          _buildTile(
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Delete all saved results and history',
            onTap: () {
              _showClearDataDialog();
            },
            textColor: Colors.red,
          ),
          
          const SizedBox(height: 24),
          
          // Account Section
          _buildSectionHeader('Account'),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return _buildTile(
                icon: Icons.person,
                title: 'Account Information',
                subtitle: authProvider.user?.email ?? 'Not signed in',
                onTap: () {
                  _showAccountInfo(authProvider);
                },
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Version Info
          Center(
            child: Text(
              'Rice Disease Detector v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          underline: Container(),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppTheme.primaryGreen),
        title: Text(title, style: TextStyle(color: textColor)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Data'),
        content: const Text('Your data is automatically synced when you\'re signed in. All detection results are saved to your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete all your saved detection results and history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAccountInfo(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${authProvider.user?.email ?? 'Not signed in'}'),
            const SizedBox(height: 8),
            Text('User ID: ${authProvider.user?.uid ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Joined: ${authProvider.user?.createdAt.toString().split(' ')[0] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    // TODO: Implement clear all data functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All data has been cleared'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}