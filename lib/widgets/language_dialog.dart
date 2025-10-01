import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/generated/app_localizations.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context);
    
    return AlertDialog(
      title: Text(localizations?.selectLanguage ?? 'Select Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(localizations?.english ?? 'English'),
            leading: Radio<String>(
              value: 'en',
              groupValue: Localizations.localeOf(context).languageCode,
              onChanged: (String? value) async {
                if (value != null) {
                  await LocalizedApp.setLocale(context, Locale(value));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ),
          ListTile(
            title: Text(localizations?.spanish ?? 'Español'),
            leading: Radio<String>(
              value: 'es',
              groupValue: currentLocale.languageCode,
              onChanged: (String? value) async {
                if (value != null) {
                  await LocalizedApp.setLocale(context, Locale(value));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
