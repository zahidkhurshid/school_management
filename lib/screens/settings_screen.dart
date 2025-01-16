import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _useSystemTheme = true;
  bool _showNotifications = true;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _useSystemTheme = prefs.getBool('useSystemTheme') ?? true;
      _showNotifications = prefs.getBool('showNotifications') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('useSystemTheme', _useSystemTheme);
    await prefs.setBool('showNotifications', _showNotifications);
    await prefs.setString('language', _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: Text(
                  'Use System Theme',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  'Automatically switch between light and dark themes',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                value: _useSystemTheme,
                onChanged: (value) {
                  setState(() {
                    _useSystemTheme = value;
                    if (!value) {
                      _isDarkMode = Theme.of(context).brightness == Brightness.dark;
                    }
                  });
                  _saveSettings();
                },
              ),
              if (!_useSystemTheme)
                SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    'Enable dark theme',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                    _saveSettings();
                  },
                ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: Text(
                  'Enable Notifications',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  'Receive notifications about attendance and events',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                value: _showNotifications,
                onChanged: (value) {
                  setState(() => _showNotifications = value);
                  _saveSettings();
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Language',
            children: [
              ListTile(
                title: Text(
                  'Select Language',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  _selectedLanguage,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Select Language',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _languages
                            .map(
                              (language) => RadioListTile<String>(
                                title: Text(
                                  language,
                                  style: GoogleFonts.poppins(),
                                ),
                                value: language,
                                groupValue: _selectedLanguage,
                                onChanged: (value) {
                                  Navigator.pop(context, value);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() => _selectedLanguage = result);
                    _saveSettings();
                  }
                },
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                title: Text(
                  'Version',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  '1.0.0',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
              ListTile(
                title: Text(
                  'Developer',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  'Your Name',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
