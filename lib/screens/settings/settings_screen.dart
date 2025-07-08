import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Switch between light and dark theme'),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      secondary: Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile(
                      title: const Text('Push Notifications'),
                      subtitle: const Text('Receive notifications for appointments and messages'),
                      value: themeProvider.notificationsEnabled,
                      onChanged: (value) {
                        themeProvider.toggleNotifications();
                      },
                      secondary: const Icon(Icons.notifications),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Read our privacy policy'),
                  leading: const Icon(Icons.privacy_tip),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showPrivacyPolicy(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Terms of Service'),
                  subtitle: const Text('Read our terms of service'),
                  leading: const Icon(Icons.description),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showTermsOfService(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('About'),
                  subtitle: const Text('App version and information'),
                  leading: const Icon(Icons.info),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Sign Out'),
              subtitle: const Text('Sign out of your account'),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () => _showSignOutDialog(context),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Medicare v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a sample privacy policy. In a real app, this would contain the actual privacy policy text explaining how user data is collected, used, and protected.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a sample terms of service. In a real app, this would contain the actual terms and conditions for using the application.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Medicare',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.local_hospital,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'Medicare is a comprehensive patient mobile app that helps you manage your healthcare journey with ease.',
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}