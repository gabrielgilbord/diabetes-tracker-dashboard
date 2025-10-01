import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String? _selectedLanguage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language_code') ?? 'en';
      _isLoading = false;
    });
  }

  Future<void> _changeLanguage(String? languageCode) async {
    if (languageCode == null || languageCode == _selectedLanguage) {
      return;
    }

    setState(() {
      _selectedLanguage = languageCode;
    });

    // Update the app's locale
    LocalizedApp.setLocale(context, Locale(languageCode));
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(localizations?.selectLanguage ?? 'Select Language'),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        items: [
          DropdownMenuItem(
            value: 'en',
            child: Text(localizations?.english ?? 'English'),
          ),
          DropdownMenuItem(
            value: 'es',
            child: Text(localizations?.spanish ?? 'Español'),
          ),
        ],
        onChanged: _changeLanguage,
      ),
    );
  }
}
