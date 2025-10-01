import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'widgets/language_dialog.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import 'l10n/generated/app_localizations.dart';
import 'widgets/language_selector.dart';
import 'screens/daily_mood_screen.dart';
import 'screens/ble_reader_screen.dart';
import 'battery_optimization_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getOrCreateDeviceId();

  // Load saved language preference
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language_code') ?? 'es'; // Por defecto español
  
  runApp(
    LocalizedApp(
      locale: Locale(languageCode),
      child: const DiabetesTrackerApp(),
    ),
  );
}

class LocalizedApp extends StatefulWidget {
  final Locale locale;
  final Widget child;

  const LocalizedApp({
    Key? key,
    required this.locale,
    required this.child,
  }) : super(key: key);

  static Future<void> setLocale(BuildContext context, Locale newLocale) async {
    final state = context.findAncestorStateOfType<LocalizedAppState>();
    if (state != null) {
      await state.setLocale(newLocale);
    }
  }

  @override
  LocalizedAppState createState() => LocalizedAppState();
}

class LocalizedAppState extends State<LocalizedApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'es'; // Por defecto español
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<void> setLocale(Locale newLocale) async {
    if (newLocale.languageCode == _locale?.languageCode) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    
    if (mounted) {
      setState(() {
        _locale = newLocale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
          labelMedium: TextStyle(color: Colors.black),
          labelSmall: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black54),
          hintStyle: TextStyle(color: Colors.black54),
          errorStyle: TextStyle(color: Colors.red),
        ),
      ),
      home: widget.child,
    );
  }
}

// Función helper para obtener ApiService con contexto
ApiService getApiService(BuildContext context) {
  return ApiService(context: context);
}

// Instancia global sin contexto (para casos donde no se necesita verificación de token)
final ApiService apiService = ApiService();

class DiabetesTrackerApp extends StatelessWidget {
  const DiabetesTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}



// ===================== PANTALLA DE INICIO =====================
// Reemplaza typedef y uso de Tuple3 por una clase simple
class MenuItem {
  final String title;
  final IconData icon;
  final Widget? screen;
  MenuItem(this.title, this.icon, this.screen);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? bomba;
  String? sexo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? sexoValue = prefs.getString('sexo');
    
    // Migración: convertir 'mujer' a 'female' si existe
    if (sexoValue == 'mujer') {
      sexoValue = 'female';
      await prefs.setString('sexo', sexoValue);
    }
    
    setState(() {
      bomba = prefs.getBool('bomba_insulina');
      sexo = sexoValue;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final localizations = AppLocalizations.of(context);
    final List<MenuItem> items = [
      MenuItem(localizations?.moodScreenTitle ?? 'How was your day?', Icons.emoji_emotions, const DailyMoodScreen()),
      if (bomba == false) MenuItem(localizations?.insulinRecord ?? 'Insulin Record', Icons.healing, InsulinForm()),
      MenuItem(localizations?.foodRecord ?? 'Food Record', Icons.fastfood, FoodForm()),
      MenuItem(localizations?.exerciseRecord ?? 'Exercise Record', Icons.fitness_center, ExerciseForm()),
      if (sexo == 'female') MenuItem(localizations?.periodRecord ?? 'Period Record', Icons.bloodtype, const PeriodFormScreen()),
      MenuItem(localizations?.viewRecords ?? 'View Records', Icons.bar_chart, ViewRecords()),
      // MenuItem(localizations?.readingBLE ?? 'BLE Reading', Icons.bluetooth, const BLEReaderScreen()),
      MenuItem(localizations?.settings ?? 'Settings', Icons.settings, const SettingsScreen()),
    ];

    double logoWidth = MediaQuery.of(context).size.width * 0.5;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0039AE),
        centerTitle: true,
        title: const Text(
          'Diabetes Tracker',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        toolbarHeight: 80,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                'assets/logo.png',
                    width: logoWidth,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isLandscape ? 3 : 2,
                        childAspectRatio: isLandscape ? 1.5 : 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return InkWell(
                          onTap: () async {
                            if (item.title == 'Registrar período') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PeriodFormScreen()),
                              );
                              return;
                            }
                            if (item.screen != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => item.screen!),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  size: isLandscape ? 32 : 40,
                                  color: const Color(0xFF0039AE),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    item.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isLandscape ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0039AE),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Versión y autores al pie de página
                  Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 12),
                    child: Column(
                      children: [
                        const Text(
                          'v3.15.1',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '© ULPGC & FIISC',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => BatteryOptimizationService.showOptimizationReminder(context),
                          icon: const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                          label: const Text(
                            'Ayuda: Optimización de Batería',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const CookieBanner(),
        ],
      ),
    );
  }
}

// ===================== PANTALLA DE AJUSTES =====================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  late final ApiService _apiService;
  
  @override
  void initState() {
    super.initState();
    _apiService = getApiService(context);
  }

  Future<void> _revokeConsent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username != null) {
        final revokeData = {
          'username': username,
        };

        bool success = await _apiService.sendFormData('revokeGDPRConsent', revokeData);

        if (success) {
          // Eliminar las preferencias de sesión y marcar que no hay consentimiento
          await prefs.remove('username');
          await prefs.remove('auth_token');
          await prefs.setBool('has_consented', false);
          // No modificamos is_first_login para que no pida cambiar contraseña

          // Mostrar mensaje y volver a la pantalla de login
          if (mounted) {
            final localizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations?.revokeConsentSuccess ?? 'Consent successfully revoked'),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          if (mounted) {
            final localizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations?.revokeConsentError ?? 'Error revoking consent'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.revokeConsentError ?? 'Error revoking consent'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAllData() async {
    final username = await _recuperarUsername();
    if (username == null) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.noUserFound ?? 'User not found')),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations?.deleteAllDataDialogTitle ?? 'Delete all data'),
          content: Text(
            localizations?.deleteAllDataDialogContent ?? 'Are you sure you want to delete all your data? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(localizations?.delete ?? 'Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _apiService.deleteAllUserData(username);
      if (success) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.deleteAllDataSuccess ?? 'All data deleted successfully')));
        await AuthService.logoutAndClearAll(context);
      } else {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.deleteAllDataError ?? 'Error deleting data')));
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations?.error ?? 'Error'}: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations?.settings ?? 'Settings',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0039AE),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations?.privacySettings ?? 'Privacy and Data',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0039AE),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.privacy_tip, color: Color(0xFF0039AE)),
                  label: Text(localizations?.privacyPolicy ?? 'Ver política de privacidad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0039AE),
                    side: const BorderSide(color: Color(0xFF0039AE)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => mostrarPoliticaPrivacidad(context),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.revokeConsent ?? 'Revoke Consent',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations?.revokeConsentDesc ?? 'You can revoke your consent to participate in the research at any time. This will log you out and you will not be able to access the app until you give your consent again.',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(localizations?.revokeConsentDialogTitle ?? 'Are you sure?'),
                                  content: Text(
                                    localizations?.revokeConsentDialogContent ?? 'By revoking your consent, you will be logged out and will not be able to access the app until you give your consent again. Your data will remain in the system.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text(localizations?.cancel ?? 'Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _revokeConsent();
                                      },
                                      child: Text(
                                        localizations?.revokeConsent ?? 'Revoke Consent',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  localizations?.revokeConsent ?? 'Revoke Consent',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                          child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                        localizations?.selectLanguageTitle ?? 'Language / Idioma',
                                style: const TextStyle(
                                  fontSize: 16,
                          fontWeight: FontWeight.bold,
                                ),
                              ),
                      const SizedBox(height: 8),
                      const LanguageSelector(),
                            ],
                          ),
                        ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.deleteAllData ?? 'Delete all data',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations?.deleteAllDataDesc ?? 'This action will delete all your insulin, food and exercise records. This action cannot be undone.',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _deleteAllData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  localizations?.deleteAllData ?? 'Delete all data',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
            ),
          ),
        ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Botón de logout
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.logout ?? 'Cerrar sesión',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations?.logoutDescription ?? 'Cierra tu sesión actual y vuelve a la pantalla de inicio de sesión.',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await AuthService.logout(context);
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: Text(
                            localizations?.logout ?? 'Cerrar sesión',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== COMPONENTES COMUNES =====================
Widget customTextField(
  String label,
  TextEditingController controller, {
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
      ),
      validator:
          (val) => val == null || val.isEmpty ? 'Campo obligatorio' : null,
    ),
  );
}

class FormScaffold extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final Future<void> Function() onSave;

  const FormScaffold({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0039AE),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
                children: [
                  ...children,
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                          await onSave();
                          formKey.currentState?.reset();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations?.savedSuccessfully ?? 'Record saved successfully'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0039AE),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          localizations?.save ?? 'Save',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== FORMULARIO INSULINA =====================
class InsulinForm extends StatefulWidget {
  const InsulinForm({super.key});

  @override
  State<InsulinForm> createState() => _InsulinFormState();
}

class _InsulinFormState extends State<InsulinForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController doseCtrl = TextEditingController();
  DateTime? selectedDateTime;
  String? insulinType;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.insulinFormTitle ?? 'Insulin Record'),
        backgroundColor: const Color(0xFF0039AE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        DropdownButtonFormField<String>(
          value: insulinType,
          onChanged: (String? newValue) {
            setState(() {
              insulinType = newValue;
            });
          },
                items: <String>[
                  localizations?.fastInsulin ?? 'Fast',
                  localizations?.slowInsulin ?? 'Slow'
                ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                    child: Text(value),
                );
              }).toList(),
          decoration: InputDecoration(
                  labelText: localizations?.insulinTypeLabel ?? 'Insulin Type',
          ),
          validator: (value) => value == null ? (localizations?.insulinTypeRequired ?? 'Select a type') : null,
        ),
              const SizedBox(height: 16),
              TextFormField(
                controller: doseCtrl,
                decoration: InputDecoration(
                  labelText: localizations?.insulinDoseLabel ?? 'Dose (IU)',
                ),
          keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations?.doseRequired ?? 'Enter dose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(localizations?.insulinDateTimeLabel ?? 'Date and Time of Application'),
              ElevatedButton(
                onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale('es'),
            );
            if (pickedDate != null) {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                });
              }
            }
          },
                child: Text(selectedDateTime != null ? '${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} ${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}' : (localizations?.selectDateTime ?? 'Select date and time')),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && selectedDateTime != null) {
                      final prefs = await SharedPreferences.getInstance();
                      final username = prefs.getString('username');
                      if (username == null) return;
                      await apiService.sendFormData('insulinForm', {
                        'username': username,
                        'insulinType': insulinType,
                        'dose': doseCtrl.text,
                        'date_time': selectedDateTime.toString(),
                        'actualDateTime': DateTime.now().toString(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.insulinSaved ?? 'Insulin registered successfully')));
                      Navigator.pop(context);
                    } else if (selectedDateTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.dateTimeRequired ?? 'Select date and time')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0039AE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(localizations?.save ?? 'Save', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== FORMULARIO COMIDA =====================
class FoodForm extends StatefulWidget {
  const FoodForm({super.key});

  @override
  State<FoodForm> createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController carbsCtrl = TextEditingController();
  String? foodType;
  String? quantity;
  DateTime? selectedDateTime;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.foodFormTitle ?? 'Food Record'),
        backgroundColor: const Color(0xFF0039AE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        DropdownButtonFormField<String>(
          value: foodType,
                items: [
                  DropdownMenuItem(value: localizations?.breakfast ?? 'Breakfast', child: Text(localizations?.breakfast ?? 'Breakfast')),
                  DropdownMenuItem(value: localizations?.lunch ?? 'Lunch', child: Text(localizations?.lunch ?? 'Lunch')),
                  DropdownMenuItem(value: localizations?.dinner ?? 'Dinner', child: Text(localizations?.dinner ?? 'Dinner')),
                  DropdownMenuItem(value: localizations?.snack ?? 'Snack', child: Text(localizations?.snack ?? 'Snack')),
                  DropdownMenuItem(value: localizations?.hypoglycemia ?? 'Hypoglycemia', child: Text(localizations?.hypoglycemia ?? 'Hypoglycemia')),
                ],
                onChanged: (v) => setState(() => foodType = v),
                decoration: InputDecoration(labelText: localizations?.foodTypeLabel ?? 'Food Type'),
                validator: (value) => value == null ? (localizations?.insulinTypeRequired ?? 'Select a type') : null,
              ),
              const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: quantity,
                items: [
                  DropdownMenuItem(value: localizations?.lessThanUsual ?? 'Less than usual', child: Text(localizations?.lessThanUsual ?? 'Less than usual')),
                  DropdownMenuItem(value: localizations?.sameAsUsual ?? 'Same as usual', child: Text(localizations?.sameAsUsual ?? 'Same as usual')),
                  DropdownMenuItem(value: localizations?.moreThanUsual ?? 'More than usual', child: Text(localizations?.moreThanUsual ?? 'More than usual')),
                ],
                onChanged: (v) => setState(() => quantity = v),
                decoration: InputDecoration(labelText: localizations?.foodAmountLabel ?? 'Amount'),
                validator: (value) => value == null ? (localizations?.insulinTypeRequired ?? 'Select a type') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: carbsCtrl,
                decoration: InputDecoration(
                  labelText: localizations?.carbsLabel ?? 'Carbohydrates (g)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations?.doseRequired ?? 'Enter dose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(localizations?.foodDateTimeLabel ?? 'Date and Time of the meal'),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es'),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedDateTime != null ? TimeOfDay.fromDateTime(selectedDateTime!) : TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Text(selectedDateTime != null ? '${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} ${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}' : (localizations?.selectDateTimeFood ?? 'Select date and time')),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && selectedDateTime != null) {
                      final prefs = await SharedPreferences.getInstance();
                      final username = prefs.getString('username');
                      if (username == null) return;
                      await apiService.sendFormData('foodForm', {
                        'username': username,
                        'foodType': foodType,
                        'quantity': quantity,
                        'carbs': carbsCtrl.text,
                        'dateTime': selectedDateTime.toString(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.foodRegisteredSnack ?? 'Food registered successfully')));
                      Navigator.pop(context);
                    } else if (selectedDateTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.selectDateTimeFood ?? 'Select date and time')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0039AE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(localizations?.save ?? 'Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== FORMULARIO EJERCICIO =====================
class ExerciseForm extends StatefulWidget {
  const ExerciseForm({super.key});

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionCtrl = TextEditingController();
  String? exerciseType;
  double intensity = 5;
  DateTime? startTime;
  DateTime? endTime;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.exerciseFormTitle ?? 'Exercise Record'),
        backgroundColor: const Color(0xFF0039AE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: exerciseType,
                items: [
                  DropdownMenuItem(value: 'Aerobico', child: Text(localizations?.aerobic ?? 'Aerobic')),
                  DropdownMenuItem(value: 'Fuerza', child: Text(localizations?.strength ?? 'Strength')),
                  DropdownMenuItem(value: 'HIT', child: Text(localizations?.hit ?? 'HIT')),
                ],
                onChanged: (v) => setState(() => exerciseType = v),
                decoration: InputDecoration(labelText: localizations?.exerciseTypeLabel ?? 'Exercise Type'),
                validator: (value) => value == null ? (localizations?.selectInsulinType ?? 'Select a type') : null,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(localizations?.intensity ?? 'Intensity'),
            Text(intensity.toInt().toString()),
          ],
        ),
        Slider(
          value: intensity,
          min: 1,
          max: 10,
          divisions: 9,
                label: intensity.round().toString(),
          activeColor: const Color(0xFF0039AE),
                onChanged: (double value) {
                  setState(() {
                    intensity = value;
                  });
                },
        ),
        const SizedBox(height: 16),
               Text(                 localizations?.startTime ?? 'Start Time',
),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es'),
    );
    if (picked != null) {
                    final pickedTime = await showTimePicker(
        context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        startTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Text(startTime != null ? '${startTime!.day}/${startTime!.month}/${startTime!.year} ${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}' : (localizations?.selectStartTime ?? 'Select start time')),
              ),
              const SizedBox(height: 16),
              Text(localizations?.endTime ?? 'End Time'),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es'),
                  );
                  if (picked != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
        setState(() {
                        endTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Text(endTime != null ? '${endTime!.day}/${endTime!.month}/${endTime!.year} ${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}' : (localizations?.selectEndTime ?? 'Select end time')),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionCtrl,
                decoration:  InputDecoration(
                  labelText: localizations?.description ?? 'Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && startTime != null && endTime != null) {
                      final prefs = await SharedPreferences.getInstance();
                      final username = prefs.getString('username');
                      if (username == null) return;
                      await apiService.sendFormData('exerciseForm', {
                        'username': username,
                        'exerciseType': exerciseType,
                        'intensity': intensity.toInt(),
                        'description': descriptionCtrl.text,
                        'startTime': startTime.toString(),
                        'endTime': endTime.toString(),
                        'dateTime': DateTime.now().toString(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.exerciseRecordedSuccessfully ?? 'Exercise recorded successfully')));
                      Navigator.pop(context);
                    } else if (startTime == null || endTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.selectStartAndEndTime ?? 'Select start and end time')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0039AE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(localizations?.save ?? 'Save', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== CONSULTA DE REGISTROS =====================
class ViewRecords extends StatefulWidget {
  const ViewRecords({super.key});

  @override
  State<ViewRecords> createState() => _ViewRecordsState();
}

class _ViewRecordsState extends State<ViewRecords> {
  Future<Map<String, dynamic>>? _allDataFuture;
  late final ApiService _apiService;
  bool _isLoading = false;
  String? _errorMessage;
  
  bool? bomba;
  String? sexo;
  bool isLoadingProfile = true;

  final List<String> insulinColumnTitles = ['Tipo', 'Dosis', 'Fecha y Hora'];
  final List<String> foodColumnTitles = ['Tipo', 'Cantidad', 'Carbohidratos', 'Fecha y Hora'];
  // Los títulos de ejercicio se definirán en el build donde está disponible localizations
  final List<String> periodColumnTitles = ['Inicio', 'Duración', 'Intensidad', 'Síntomas', 'Notas'];

  Map<String, bool> _expandedPanels = {
    'insulin': false,
    'food': false,
    'exercise': false,
    'period': false,
    'mood': false,
  };

  @override
  void initState() {
    super.initState();
    _apiService = getApiService(context);
    _loadProfileAndData();
  }

  Future<void> _loadProfileAndData() async {
    final prefs = await SharedPreferences.getInstance();
    String? sexoValue = prefs.getString('sexo');
    
    // Migración: convertir 'mujer' a 'female' si existe
    if (sexoValue == 'mujer') {
      sexoValue = 'female';
      await prefs.setString('sexo', sexoValue);
    }

        setState(() {
      bomba = prefs.getBool('bomba_insulina');
      sexo = sexoValue;
      isLoadingProfile = false;
    });
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = await _recuperarUsername();
      if (username == null) {
        setState(() {
          _errorMessage = 'No se encontró el usuario';
          _isLoading = false;
        });
        return;
      }

      final data = await _apiService.getAllData(username);
      setState(() {
        _allDataFuture = Future.value(data);
        _isLoading = false;
      });
      } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (isLoadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations?.viewRecordsTitle ?? 'View Records',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        backgroundColor: const Color(0xFF0039AE),
      ),
      body: Stack(
      children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
        children: [
                if (MediaQuery.of(context).orientation != Orientation.landscape)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0039AE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0039AE)),
                    ),
                  child: Text(
                      localizations?.controlDiabetesLikeBoss ?? '¡Controla tu diabetes como un jefe! 💪\nCada registro es un paso hacia una vida más saludable.',
                      textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF0039AE),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: _allDataFuture == null
                      ? const Center(child: CircularProgressIndicator())
                      : FutureBuilder<Map<String, dynamic>>(
          future: _allDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('${localizations?.error ?? 'Error'}: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(localizations?.noDataAvailable ?? 'No data available'),
              );
            }
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCharts(data),
                  const SizedBox(height: 24),
                  ExpansionPanelList(
                    expansionCallback: (panelIndex, isExpanded) {
                      setState(() {
                        final keys = <String>[];
                        if (bomba == null || bomba == false) keys.add('insulin');
                        keys.addAll(['food', 'exercise', 'mood']);
                        if (sexo == 'female') keys.add('period');
                        _expandedPanels[keys[panelIndex]] = !_expandedPanels[keys[panelIndex]]!;
                      });
                    },
                    children: _buildPanels(data),
                  ),
                ],
              ),
            );
          },
        ),
                ),
              ],
            ),
          ),
          ),
          const CookieBanner(),
        ],
      ),
    );
  }

  List<ExpansionPanel> _buildPanels(Map<String, dynamic> data) {
    final localizations = AppLocalizations.of(context);
    final panels = <ExpansionPanel>[];
    if (bomba == null || bomba == false) {
      panels.add(
        ExpansionPanel(
          headerBuilder: (context, isExpanded) => ListTile(
            leading: const Icon(Icons.healing, color: Color(0xFF0039AE)),
            title: Text(localizations?.insulinSection ?? 'Insulin', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildCardList(data['insulinData'], 'insulin'),
          ),
          isExpanded: _expandedPanels['insulin']!,
          canTapOnHeader: true,
        ),
      );
    }
    panels.addAll([
      ExpansionPanel(
        headerBuilder: (context, isExpanded) => ListTile(
          leading: const Icon(Icons.fastfood, color: Color(0xFF0039AE)),
          title: Text(localizations?.foodSection ?? 'Food', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildCardList(data['foodData'], 'food'),
        ),
        isExpanded: _expandedPanels['food']!,
        canTapOnHeader: true,
      ),
      ExpansionPanel(
        headerBuilder: (context, isExpanded) => ListTile(
          leading: const Icon(Icons.fitness_center, color: Color(0xFF0039AE)),
          title: Text(localizations?.exerciseSection ?? 'Exercise', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildCardList(data['exerciseData'], 'exercise'),
        ),
        isExpanded: _expandedPanels['exercise']!,
        canTapOnHeader: true,
      ),
      ExpansionPanel(
        headerBuilder: (context, isExpanded) => ListTile(
          leading: const Icon(Icons.emoji_emotions, color: Color(0xFF0039AE)),
          title: Text(localizations?.mood ?? 'Estado de ánimo', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildCardList(data['moodData'] ?? [], 'mood'),
        ),
        isExpanded: _expandedPanels['mood']!,
        canTapOnHeader: true,
      ),
    ]);
    if (sexo == 'female') {
      panels.add(
        ExpansionPanel(
          headerBuilder: (context, isExpanded) => ListTile(
            leading: const Icon(Icons.bloodtype, color: Color(0xFF0039AE)),
            title: Text(localizations?.periodSection ?? 'Period', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildCardList(data['periodData'] ?? [], 'period'),
          ),
          isExpanded: _expandedPanels['period']!,
          canTapOnHeader: true,
        ),
      );
    }
    return panels;
  }

  Widget _buildCardList(List<dynamic> data, String type) {
    final localizations = AppLocalizations.of(context);
    if (data.isEmpty) {
      String tipo = '';
      switch (type) {
        case 'insulin': tipo = localizations?.insulin ?? 'insulin'; break;
        case 'food': tipo = localizations?.food ?? 'food'; break;
        case 'exercise': tipo = localizations?.exercise ?? 'exercise'; break;
        case 'period': tipo = localizations?.period ?? 'period'; break;
        case 'mood': tipo = localizations?.mood ?? 'mood'; break;
        default: tipo = type;
      }
      return Center(
  child: Text(
    localizations?.noRecordsOfType(tipo) ?? 'No hay registros de $tipo',
  ),
);
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = data[index];
        DateTime? date;
        try { date = DateTime.parse(item['date_time'] ?? ''); } catch (_) { date = DateTime.now(); }
        String typeText = '';
        String valueText = '';
        IconData icon = Icons.info;
        Color color = const Color(0xFF0039AE);
        VoidCallback? onEdit;
        List<Widget> extraFields = [];
        switch (type) {
          case 'insulin':
            typeText = item['insulinType'] ?? (localizations?.notSpecified ?? 'Not specified');
            valueText = '${item['dose']?.toString() ?? '0'} ${localizations?.units ?? 'units'}';
            icon = Icons.healing;
            onEdit = () => _editInsulinRecord(item);
            extraFields = [
              Text('${localizations?.insulinTypeColon ?? 'Type:'} ${item['insulinType'] ?? (localizations?.notSpecified ?? 'Not specified')}'),
              Text('${localizations?.doseColon ?? 'Dose:'} ${item['dose'] ?? '-'} ${localizations?.units ?? 'units'}'),
              Text('${localizations?.dateTimeColon ?? 'Date and time:'} ${item['date_time'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(item['date_time'])) : '-'}'),
            ];
            break;
          case 'food':
            typeText = item['food_type'] ?? (localizations?.notSpecified ?? 'Not specified');
            valueText = '${item['carbs']?.toString() ?? '0'} ${localizations?.grams ?? 'g'}';
            icon = Icons.fastfood;
            onEdit = () => _editFoodRecord(item);
            extraFields = [
              Text('${localizations?.foodTypeColon ?? 'Type:'} ${item['food_type'] ?? '-'}'),
              Text('${localizations?.quantityColon ?? 'Quantity:'} ${item['quantity'] ?? '-'}'),
              Text('${localizations?.carbsColon ?? 'Carbohydrates:'} ${item['carbs'] ?? '-'} ${localizations?.grams ?? 'g'}'),
              Text('${localizations?.dateTimeColon ?? 'Date and time:'} ${item['date_time'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(item['date_time'])) : '-'}'),
            ];
            break;
          case 'exercise':
            typeText = item['exercise_type'] ?? (localizations?.notSpecified ?? 'No especificado');
            valueText = item['exercise_description']?.toString() ?? (localizations?.withoutDescription ?? 'Sin descripción');
            icon = Icons.fitness_center;
            onEdit = () => _editExerciseRecord(item);
            extraFields = [
              Text('${localizations?.exerciseTypeColon ?? 'Type:'} ${item['exercise_type'] ?? '-'}'),
              Text('${localizations?.intensityColon ?? 'Intensity:'} ${item['intensity'] ?? '-'}'),
              Text('${localizations?.startTimeColon ?? 'Start time:'} ${item['exercise_start_time'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(item['exercise_start_time'])) : '-'}'),
              Text('${localizations?.endTimeColon ?? 'End time:'} ${item['exercise_end_time'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(item['exercise_end_time'])) : '-'}'),
              Text('${localizations?.descriptionColon ?? 'Description:'} ${item['exercise_description'] ?? (localizations?.withoutDescription ?? 'Sin descripción')}'),
              Text('${localizations?.dateTimeColon ?? 'Date and time:'} ${item['date_time'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(item['date_time'])) : '-'}'),
            ];
            break;
          case 'period':
            typeText = 'Período';
            String start = '';
            String end = '';
            try {
              if (item['startDate'] != null) {
                final d = DateTime.parse(item['startDate']);
                start = DateFormat('dd/MM/yyyy').format(d);
              }
              if (item['endDate'] != null) {
                final d = DateTime.parse(item['endDate']);
                end = DateFormat('dd/MM/yyyy').format(d);
              }
            } catch (_) {}
            valueText = '$start - $end (${item['intensity'] ?? ''})';
            icon = Icons.bloodtype;
            onEdit = () => _editPeriodRecord(item);
            extraFields = [
              Text('Inicio: $start'),
              Text('Fin: $end'),
              Text('Intensidad: ${item['intensity'] ?? '-'}'),
              Text('Síntomas: ${item['symptoms'] ?? '-'}'),
              Text('Notas: ${item['notes'] ?? '-'}'),
            ];
            break;
          case 'mood':
            typeText = localizations?.mood ?? 'Estado de ánimo';
            valueText = 'Valor: ${item['mood_value'] ?? '-'}';
            icon = Icons.emoji_emotions;
            onEdit = () => _editMoodRecord(item);
            extraFields = [
              if (item['out_of_routine'] == true)
                Text('Fuera de rutina: ${item['routine_description'] ?? ''}'),
              Text('Emociones: ${(item['emotions'] as List).join(', ')}'),
              if (item['other_emotion'] != null && item['other_emotion'].toString().isNotEmpty)
                Text('Otra emoción: ${item['other_emotion']}'),
            ];
            break;
        }
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
          children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      typeText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF0039AE)),
                      onPressed: onEdit,
                      tooltip: localizations?.edit ?? 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context, item, type),
                      tooltip: localizations?.delete ?? 'Eliminar',
                    ),
          ],
        ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(valueText, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                ...extraFields,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Mostrar diálogo de confirmación para eliminar un registro
  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> item, String type) {
    final localizations = AppLocalizations.of(context);
    String recordType = '';
    String recordInfo = '';
    
    switch (type) {
      case 'insulin':
        recordType = localizations?.insulin ?? 'Insulina';
        recordInfo = '${item['insulinType'] ?? ''} - ${item['dose'] ?? ''} ${localizations?.units ?? 'unidades'}';
        break;
      case 'food':
        recordType = localizations?.food ?? 'Comida';
        recordInfo = '${item['food_type'] ?? ''} - ${item['carbs'] ?? ''} ${localizations?.grams ?? 'g'}';
        break;
      case 'exercise':
        recordType = localizations?.exercise ?? 'Ejercicio';
        recordInfo = '${item['exercise_type'] ?? ''} - ${item['intensity'] ?? ''}';
        break;
      case 'period':
        recordType = localizations?.period ?? 'Período';
        recordInfo = '${item['startDate'] ?? ''} - ${item['endDate'] ?? ''}';
        break;
      case 'mood':
        recordType = localizations?.mood ?? 'Estado de ánimo';
        recordInfo = 'Valor: ${item['mood_value'] ?? ''}';
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.deleteRecord ?? 'Eliminar registro'),
          content: Text(
            '${localizations?.deleteRecordConfirmation ?? '¿Estás seguro de que quieres eliminar este registro de'} $recordType?\n\n$recordInfo\n\n${localizations?.deleteRecordWarning ?? 'Esta acción no se puede deshacer.'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations?.cancel ?? 'Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord(item, type);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(localizations?.delete ?? 'Eliminar'),
            ),
          ],
        );
      },
    );
  }

  /// Eliminar un registro específico
  Future<void> _deleteRecord(Map<String, dynamic> item, String type) async {
    final localizations = AppLocalizations.of(context);
    String? recordId = item['id']?.toString();
    
    if (recordId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations?.deleteRecordError ?? 'Error: No se pudo identificar el registro'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool success = false;
    String recordType = '';

    try {
      switch (type) {
        case 'insulin':
          recordType = localizations?.insulin ?? 'Insulina';
          success = await _apiService.deleteInsulinRecord(recordId);
          break;
        case 'food':
          recordType = localizations?.food ?? 'Comida';
          success = await _apiService.deleteFoodRecord(recordId);
          break;
        case 'exercise':
          recordType = localizations?.exercise ?? 'Ejercicio';
          success = await _apiService.deleteExerciseRecord(recordId);
          break;
        case 'period':
          recordType = localizations?.period ?? 'Período';
          success = await _apiService.deletePeriodRecord(recordId);
          break;
        case 'mood':
          recordType = localizations?.mood ?? 'Estado de ánimo';
          success = await _apiService.deleteMoodRecord(recordId);
          break;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations?.deleteRecordSuccess ?? 'Registro eliminado correctamente'}: $recordType'),
            backgroundColor: Colors.green,
          ),
        );
        // Recargar los datos
        _loadProfileAndData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations?.deleteRecordError ?? 'Error al eliminar el registro'}: $recordType'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations?.deleteRecordError ?? 'Error al eliminar el registro'}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCharts(Map<String, dynamic> data) {
    final localizations = AppLocalizations.of(context);
    // Procesar datos de insulina
    Map<String, double> dailyInsulin = {};
    for (var insulin in data['insulinData']) {
      try {
        if (insulin['date_time'] == null) continue;
        final date = DateTime.parse(insulin['date_time']);
        final dateStr = '${date.day}/${date.month}';
        final dose = double.tryParse(insulin['dose']?.toString() ?? '0') ?? 0;
        dailyInsulin[dateStr] = (dailyInsulin[dateStr] ?? 0) + dose;
      } catch (e) {
        print('Error procesando registro de insulina: $e');
        continue;
      }
    }

    // Procesar datos de comida
    Map<String, Map<String, double>> dailyCarbs = {};
    for (var food in data['foodData']) {
      try {
        if (food['date_time'] == null) continue;
        final date = DateTime.parse(food['date_time']);
        final dateStr = '${date.day}/${date.month}';
        final carbs = double.tryParse(food['carbs']?.toString() ?? '0') ?? 0;
        final type = food['food_type'] ?? 'Otros';
        
        if (!dailyCarbs.containsKey(dateStr)) {
          dailyCarbs[dateStr] = {};
        }
        dailyCarbs[dateStr]![type] = (dailyCarbs[dateStr]![type] ?? 0) + carbs;
      } catch (e) {
        print('Error procesando registro de comida: $e');
        continue;
      }
    }

    // Ordenar fechas
    final dates = dailyInsulin.keys.toList()..sort((a, b) {
      try {
        final aParts = a.split('/');
        final bParts = b.split('/');
        if (aParts[1] != bParts[1]) return int.parse(aParts[1]).compareTo(int.parse(bParts[1]));
        return int.parse(aParts[0]).compareTo(int.parse(bParts[0]));
      } catch (e) {
        print('Error ordenando fechas: $e');
        return 0;
      }
    });

    // Calcular promedios
    double avgInsulin = 0;
    if (dailyInsulin.isNotEmpty) {
      try {
        avgInsulin = dailyInsulin.values.reduce((a, b) => a + b) / dailyInsulin.length;
      } catch (e) {
        print('Error calculando promedio de insulina: $e');
      }
    }

    // Si no hay datos, mostrar mensaje
    if (dailyInsulin.isEmpty && dailyCarbs.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos para mostrar',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF0039AE),
          ),
        ),
      );
    }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child:  Text(
                 localizations?.dataAnalysis ?? 'Data Analysis',
                  style: TextStyle(
                fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0039AE),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
          if (dailyInsulin.isNotEmpty && (bomba == null || bomba == false)) ...[
            // Gráfico de insulina solo si bomba es false o null
            Container(
              height: 350,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                         localizations?.dailyInsulinDose ?? 'Daily Insulin Dose',
                  style: TextStyle(
                            fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0039AE),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0039AE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${localizations?.average ?? 'Average'}: ${avgInsulin.toStringAsFixed(1)} u',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0039AE),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 5,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= dates.length) return const Text('');
                                return Text(
                                  dates[value.toInt()],
                                  style: const TextStyle(
                                    color: Color(0xFF0039AE),
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Color(0xFF0039AE),
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 42,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xFF0039AE), width: 1),
                        ),
                        minX: 0,
                        maxX: (dates.length - 1).toDouble(),
                        minY: 0,
                        maxY: (dailyInsulin.values.isEmpty ? 10 : dailyInsulin.values.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble(),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(dates.length, (index) {
                              return FlSpot(
                                index.toDouble(),
                                dailyInsulin[dates[index]] ?? 0,
                              );
                            }),
                            isCurved: true,
                            color: const Color(0xFF0039AE),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF0039AE).withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
                const SizedBox(height: 24),
          ],
          if (dailyCarbs.isNotEmpty) ...[
            Container(
              height: 350,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                    // 'Promedio de Carbohidratos por Tipo',
                 localizations?.averageCarbsByType ?? 'Average Carbohydrates by Type',

                  style: TextStyle(
                      fontSize: 18,
                    fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _getCarbsDistribution(dailyCarbs),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getCarbsDistribution(Map<String, Map<String, double>> dailyCarbs) {
    // Calcular promedios por tipo de comida
    Map<String, double> typeAverages = {};
    Map<String, int> typeCounts = {};
    
    for (var dayCarbs in dailyCarbs.values) {
      for (var entry in dayCarbs.entries) {
        typeAverages[entry.key] = (typeAverages[entry.key] ?? 0) + entry.value;
        typeCounts[entry.key] = (typeCounts[entry.key] ?? 0) + 1;
      }
    }
    
    // Calcular promedios finales
    typeAverages.forEach((type, total) {
      typeAverages[type] = total / (typeCounts[type] ?? 1);
    });

    final colors = [
      Colors.green,
      Colors.lightGreen,
      Colors.greenAccent,
      Colors.teal,
      Colors.tealAccent,
    ];

    return typeAverages.entries.map((entry) {
      final index = typeAverages.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${entry.key}\n${entry.value.toStringAsFixed(1)}g',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildTable(List<dynamic> data, List<String> columnTitles, String type) {
    if (data.isEmpty) {
      String tipo = '';
      switch (type) {
        case 'insulin':
          tipo = 'insulina';
          break;
        case 'food':
          tipo = 'comidas';
          break;
        case 'exercise':
          tipo = 'ejercicio';
          break;
        case 'period':
          tipo = 'período';
          break;
        default:
          tipo = type;
      }
      return Center(
        child: Text('No hay registros de $tipo'),
      );
    }
    if (type == 'period') {
          return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Inicio')),
            DataColumn(label: Text('Duración')),
            DataColumn(label: Text('Intensidad')),
            DataColumn(label: Text('Síntomas')),
            DataColumn(label: Text('Notas')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: data.map<DataRow>((item) {
            String inicio = '';
            String duracion = '';
            try {
              if (item['startDate'] != null && item['endDate'] != null) {
                final start = DateTime.parse(item['startDate']);
                final end = DateTime.parse(item['endDate']);
                inicio = '${start.day}/${start.month}/${start.year}';
                duracion = end.difference(start).inDays.toString() + ' Días';
              } else if (item['startDate'] != null) {
                final start = DateTime.parse(item['startDate']);
                inicio = '${start.day}/${start.month}/${start.year}';
              }
            } catch (_) {}
            return DataRow(
              cells: [
                DataCell(Text(inicio)),
                DataCell(Text(duracion)),
                DataCell(Text(item['intensity'] ?? '')),
                DataCell(Text(item['symptoms'] ?? '')),
                DataCell(Text(item['notes'] ?? '')),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF0039AE)),
                    onPressed: () => _editPeriodRecord(item),
                  ),
                ),
              ],
                    );
                  }).toList(),
            ),
      );
    }
    final columns = [
      const DataColumn(
        label: Text(
          'Fecha',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0039AE),
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'Hora',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0039AE),
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'Tipo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0039AE),
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'Valor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0039AE),
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'Acciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0039AE),
          ),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                maxWidth: MediaQuery.of(context).orientation == Orientation.landscape 
                    ? constraints.maxWidth 
                    : 800,
              ),
              child: DataTable(
                columns: columns,
                rows: data.map<DataRow>((item) {
                  DateTime? date;
                  try {
                    date = DateTime.parse(item['date_time'] ?? '');
                  } catch (e) {
                    date = DateTime.now();
                  }
                  final localizations = AppLocalizations.of(context);
                  String typeText = '';
                  switch (type) {
                    case 'insulin':
                      typeText = item['insulinType'] ?? 'No especificado';
                      break;
                    case 'food':
                      typeText = item['food_type'] ?? 'No especificado';
                      break;
                    case 'exercise':
                      typeText = item['exercise_type'] ?? 'No especificado';
                      break;
                    case 'period':
                      typeText = 'Período';
                      break;
                    case 'mood':
                      typeText = localizations?.mood ?? 'Estado de ánimo';
                      break;
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text('${date.day}/${date.month}/${date.year}')),
                      DataCell(Text('${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}')),
                      DataCell(Text(typeText)),
                      DataCell(Text(_getValueText(item, type))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF0039AE)),
                          onPressed: () {
                            switch (type) {
                              case 'insulin':
                                _editInsulinRecord(item);
                                break;
                              case 'food':
                                _editFoodRecord(item);
                                break;
                              case 'exercise':
                                _editExerciseRecord(item);
                                break;
                              case 'period':
                                _editPeriodRecord(item);
                                break;
                              case 'mood':
                                _editMoodRecord(item);
                                break;
                            }
                          },
                        ),
                      ),
                    ],
                      );
                    }).toList(),
              ),
            ),
            ),
          );
        },
    );
  }

  String _getValueText(Map<String, dynamic> item, String type) {
    switch (type) {
      case 'insulin':
        return '${item['dose']?.toString() ?? '0'} unidades';
      case 'food':
        return '${item['carbs']?.toString() ?? '0'} g';
      case 'exercise':
        return item['exercise_type']?.toString() ?? 'No especificado';
      case 'period':
        return '${item['startDate']} - ${item['endDate']} (${item['intensity']})';
      case 'mood':
        return 'Valor: ${item['mood_value'] ?? '-'}';
      default:
        return 'No especificado';
    }
  }

  Future<void> _editInsulinRecord(Map<String, dynamic> record) async {
    final localizations = AppLocalizations.of(context);
    final TextEditingController doseCtrl = TextEditingController(text: record['dose'].toString());
    final DateTime initialDateTime = DateTime.tryParse(record['date_time'] ?? '') ?? DateTime.now();
    final TextEditingController dateTimeCtrl = TextEditingController(text: DateFormat('dd/MM/yyyy HH:mm').format(initialDateTime));
    String? insulinType = record['insulin_type'];
    
    // Mapear valores antiguos a nuevos valores traducidos
    if (insulinType == 'Lenta') {
      insulinType = localizations?.slowInsulin ?? 'Slow';
    } else if (insulinType == 'Rápida') {
      insulinType = localizations?.fastInsulin ?? 'Fast';
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.editInsulinRecord ?? 'Edit Insulin Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
              DropdownButtonFormField<String>(
                value: insulinType,
                items: [
                  DropdownMenuItem(value: localizations?.fastInsulin ?? 'Fast', child: Text(localizations?.fastInsulin ?? 'Fast')),
                  DropdownMenuItem(value: localizations?.slowInsulin ?? 'Slow', child: Text(localizations?.slowInsulin ?? 'Slow')),
                ],
                onChanged: (String? newValue) {
                  insulinType = newValue;
                },
                decoration: InputDecoration(
                  labelText: localizations?.insulinTypeLabel ?? 'Insulin Type',
                ),
              ),
              TextField(
                controller: doseCtrl,
                decoration: InputDecoration(
                  labelText: localizations?.insulinDoseLabel ?? 'Dose (IU)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateTimeCtrl,
                decoration: InputDecoration(
                  labelText: localizations?.dateTime ?? 'Date and Time',
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime initialDateTime = DateTime.tryParse(record['date_time'] ?? '') ?? DateTime.now();
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDateTime,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es'),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(initialDateTime),
                    );
                    if (pickedTime != null) {
                      final fullDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      dateTimeCtrl.text = DateFormat('dd/MM/yyyy HH:mm').format(fullDateTime);
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'id': record['id'],
                'insulinType': insulinType,
                'dose': doseCtrl.text,
                'date_time': dateTimeCtrl.text,
              });
            },
            child: Text(localizations?.save ?? 'Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      final success = await _apiService.updateInsulinRecord(result);
      if (success) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.recordUpdated ?? 'Record updated successfully')),
        );
                          } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.recordUpdateError ?? 'Error updating record')),
        );
      }
    }
  }

  Future<void> _editFoodRecord(Map<String, dynamic> record) async {
    final localizations = AppLocalizations.of(context);
    final TextEditingController carbsCtrl = TextEditingController(text: record['carbs'].toString());
    final DateTime initialDateTime = DateTime.tryParse(record['date_time'] ?? '') ?? DateTime.now();
    final TextEditingController dateTimeCtrl = TextEditingController(text: DateFormat('dd/MM/yyyy HH:mm').format(initialDateTime));
    String? foodType = record['food_type'];
    String? quantity = record['quantity'];

    // Mapeo robusto para foodType
    final Map<String, String> foodTypeMap = {
      'Desayuno': localizations?.breakfast ?? 'Breakfast',
      'Breakfast': localizations?.breakfast ?? 'Breakfast',
      (localizations?.breakfast ?? 'Breakfast'): localizations?.breakfast ?? 'Breakfast',
      'Almuerzo': localizations?.lunch ?? 'Lunch',
      'Lunch': localizations?.lunch ?? 'Lunch',
      (localizations?.lunch ?? 'Lunch'): localizations?.lunch ?? 'Lunch',
      'Cena': localizations?.dinner ?? 'Dinner',
      'Dinner': localizations?.dinner ?? 'Dinner',
      (localizations?.dinner ?? 'Dinner'): localizations?.dinner ?? 'Dinner',
      'Snack': localizations?.snack ?? 'Snack',
      (localizations?.snack ?? 'Snack'): localizations?.snack ?? 'Snack',
      'Hipoglucemia': localizations?.hypoglycemia ?? 'Hypoglycemia',
      'Hypoglycemia': localizations?.hypoglycemia ?? 'Hypoglycemia',
      (localizations?.hypoglycemia ?? 'Hypoglycemia'): localizations?.hypoglycemia ?? 'Hypoglycemia',
    };
    foodType = foodTypeMap[foodType ?? ''] ?? foodType;

    // Mapeo robusto para quantity
    final Map<String, String> quantityMap = {
      'Menos de lo habitual': localizations?.lessThanUsual ?? 'Less than usual',
      'Less than usual': localizations?.lessThanUsual ?? 'Less than usual',
      (localizations?.lessThanUsual ?? 'Less than usual'): localizations?.lessThanUsual ?? 'Less than usual',
      'Lo mismo que habitualmente': localizations?.sameAsUsual ?? 'Same as usual',
      'Same as usual': localizations?.sameAsUsual ?? 'Same as usual',
      (localizations?.sameAsUsual ?? 'Same as usual'): localizations?.sameAsUsual ?? 'Same as usual',
      'Más de lo habitual': localizations?.moreThanUsual ?? 'More than usual',
      'More than usual': localizations?.moreThanUsual ?? 'More than usual',
      (localizations?.moreThanUsual ?? 'More than usual'): localizations?.moreThanUsual ?? 'More than usual',
    };
    quantity = quantityMap[quantity ?? ''] ?? quantity;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.editFoodRecord ?? 'Edit Food Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: foodType,
                items: [
                  DropdownMenuItem(value: localizations?.breakfast ?? 'Breakfast', child: Text(localizations?.breakfast ?? 'Breakfast')),
                  DropdownMenuItem(value: localizations?.lunch ?? 'Lunch', child: Text(localizations?.lunch ?? 'Lunch')),
                  DropdownMenuItem(value: localizations?.dinner ?? 'Dinner', child: Text(localizations?.dinner ?? 'Dinner')),
                  DropdownMenuItem(value: localizations?.snack ?? 'Snack', child: Text(localizations?.snack ?? 'Snack')),
                  DropdownMenuItem(value: localizations?.hypoglycemia ?? 'Hypoglycemia', child: Text(localizations?.hypoglycemia ?? 'Hypoglycemia')),
                ],
                onChanged: (String? newValue) {
                  foodType = newValue;
                },
                decoration: InputDecoration(
                  labelText: localizations?.foodTypeLabel ?? 'Food Type',
                ),
              ),
              DropdownButtonFormField<String>(
                value: quantity,
                items: [
                  DropdownMenuItem(value: localizations?.lessThanUsual ?? 'Less than usual', child: Text(localizations?.lessThanUsual ?? 'Less than usual')),
                  DropdownMenuItem(value: localizations?.sameAsUsual ?? 'Same as usual', child: Text(localizations?.sameAsUsual ?? 'Same as usual')),
                  DropdownMenuItem(value: localizations?.moreThanUsual ?? 'More than usual', child: Text(localizations?.moreThanUsual ?? 'More than usual')),
                ],
                onChanged: (String? newValue) {
                  quantity = newValue;
                },
                decoration: InputDecoration(
                  labelText: localizations?.foodAmountLabel ?? 'Amount',
                ),
              ),
              TextField(
                controller: carbsCtrl,
                decoration: InputDecoration(
                  labelText: localizations?.carbsLabel ?? 'Carbohydrates (g)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateTimeCtrl,
                decoration: InputDecoration(
                  labelText: localizations?.dateTime ?? 'Date and Time',
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime initialDateTime = DateTime.tryParse(record['date_time'] ?? '') ?? DateTime.now();
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDateTime,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es'),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(initialDateTime),
                    );
                    if (pickedTime != null) {
                      final fullDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      dateTimeCtrl.text = DateFormat('dd/MM/yyyy HH:mm').format(fullDateTime);
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'id': record['id'],
                'foodType': foodType,
                'quantity': quantity,
                'carbs': carbsCtrl.text,
                'date_time': dateTimeCtrl.text,
              });
            },
            child: Text(localizations?.save ?? 'Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      final success = await _apiService.updateFoodRecord(result);
      if (success) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.recordUpdated ?? 'Record updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.recordUpdateError ?? 'Error updating record')));
      }
    }
  }

  Future<void> _editExerciseRecord(Map<String, dynamic> record) async {
    final localizations = AppLocalizations.of(context);
    final TextEditingController descriptionCtrl = TextEditingController(text: record['exercise_description']);
    String? exerciseType = record['exercise_type'];
    double intensity = double.tryParse(record['intensity']?.toString() ?? '5') ?? 5;

    // Mapear valores antiguos a nuevos valores traducidos
    if (exerciseType == 'Aerobico' || exerciseType == 'Aeróbico') {
      exerciseType = localizations?.aerobic ?? 'Aerobic';
    } else if (exerciseType == 'Fuerza') {
      exerciseType = localizations?.strength ?? 'Strength';
    } else if (exerciseType == 'HIT') {
      exerciseType = localizations?.hit ?? 'HIT';
    }

    DateTime safeParseDateTime(String? value, {DateTime? fallbackDate}) {
      if (value == null || value.isEmpty) return fallbackDate ?? DateTime.now();
      try {
        if (RegExp(r'^\d{2}:\d{2}(:\d{2})?$').hasMatch(value)) {
          final base = fallbackDate ?? DateTime.now();
          final parts = value.split(":");
          return DateTime(base.year, base.month, base.day, int.parse(parts[0]), int.parse(parts[1]), parts.length > 2 ? int.parse(parts[2]) : 0);
        }
        return DateTime.parse(value);
      } catch (_) {
        return fallbackDate ?? DateTime.now();
      }
    }

    DateTime baseDate = safeParseDateTime(record['date_time']);
    DateTime? startTime = safeParseDateTime(record['exercise_start_time'], fallbackDate: baseDate);
    DateTime? endTime = safeParseDateTime(record['exercise_end_time'], fallbackDate: baseDate);
    DateTime? dateTime = baseDate;

    final TextEditingController dateTimeCtrl = TextEditingController(text: DateFormat('dd/MM/yyyy HH:mm').format(baseDate));

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(localizations?.editExerciseRecord ?? 'Edit Exercise Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: exerciseType,
                  items: [
                    DropdownMenuItem(value: localizations?.aerobic ?? 'Aerobic', child: Text(localizations?.aerobic ?? 'Aerobic')),
                    DropdownMenuItem(value: localizations?.strength ?? 'Strength', child: Text(localizations?.strength ?? 'Strength')),
                    DropdownMenuItem(value: localizations?.hit ?? 'HIT', child: Text(localizations?.hit ?? 'HIT')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      exerciseType = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: localizations?.exerciseTypeLabel ?? 'Exercise Type',
                  ),
                ),
                Slider(
                  value: intensity,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: intensity.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      intensity = value;
                    });
                  },
                ),
                Text('${localizations?.intensity ?? 'Intensity'}: ${intensity.round()}'),
                ListTile(
                  title: Text(localizations?.startTime ?? 'Start Time'),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(startTime ?? DateTime.now())),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(startTime ?? DateTime.now()),
                    );
                    if (time != null) {
                      setState(() {
                        startTime = DateTime(
                          startTime!.year,
                          startTime!.month,
                          startTime!.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text(localizations?.endTime ?? 'End Time'),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(endTime ?? DateTime.now())),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(endTime ?? DateTime.now()),
                    );
                    if (time != null) {
                      setState(() {
                        endTime = DateTime(
                          endTime!.year,
                          endTime!.month,
                          endTime!.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                TextFormField(
                  controller: descriptionCtrl,
                  decoration: InputDecoration(
                    labelText: localizations?.description ?? 'Description',
                  ),
                  maxLines: 3,
                ),
                TextField(
                  controller: dateTimeCtrl,
                  decoration: InputDecoration(
                    labelText: localizations?.dateTime ?? 'Date and Time',
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: baseDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('es'),
                    );
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(baseDate),
                      );
                      if (pickedTime != null) {
                        final fullDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        dateTimeCtrl.text = DateFormat('dd/MM/yyyy HH:mm').format(fullDateTime);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'id': record['id'],
                  'exerciseType': exerciseType,
                  'intensity': intensity,
                  'exerciseStartTime': startTime.toString(),
                  'exerciseEndTime': endTime.toString(),
                  'exerciseDescription': descriptionCtrl.text,
                  'date_time': dateTimeCtrl.text,
                });
              },
              child: Text(localizations?.save ?? 'Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final success = await _apiService.updateExerciseRecord(result);
      if (success) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.recordUpdated ?? 'Record updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.recordUpdateError ?? 'Error updating record')));
      }
    }
  }

  Future<void> _editPeriodRecord(Map<String, dynamic> record) async {
    final localizations = AppLocalizations.of(context);
    DateTime? startDate = record['startDate'] != null ? DateTime.tryParse(record['startDate']) : null;
    int? duracion;
    if (record['startDate'] != null && record['endDate'] != null) {
      try {
        final start = DateTime.parse(record['startDate']);
        final end = DateTime.parse(record['endDate']);
        duracion = end.difference(start).inDays;
      } catch (_) {}
    }
    String? intensidad = record['intensity'];
    // Mapear intensidad antigua a traducción
    if (intensidad == 'Ligera' || intensidad == 'Light') {
      intensidad = localizations?.lightIntensity ?? 'Light';
    } else if (intensidad == 'Normal') {
      intensidad = localizations?.normalIntensity ?? 'Normal';
    } else if (intensidad == 'Fuerte' || intensidad == 'Heavy') {
      intensidad = localizations?.heavyIntensity ?? 'Heavy';
    }
    // Manejo robusto de síntomas
    List<String> sintomas = [];
    if (record['symptoms'] is List) {
      sintomas = List<String>.from(record['symptoms']);
    } else if (record['symptoms'] is String) {
      sintomas = (record['symptoms'] as String).split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    // Mapear síntomas antiguos a traducción
    sintomas = sintomas.map((s) {
      if (s == 'Dolor' || s == 'Pain') return localizations?.pain ?? 'Pain';
      if (s == 'Fatiga' || s == 'Fatigue') return localizations?.fatigue ?? 'Fatigue';
      if (s == 'Cambios de humor' || s == 'Mood changes') return localizations?.moodChanges ?? 'Mood changes';
      if (s == 'Hinchazón' || s == 'Swelling') return localizations?.swelling ?? 'Swelling';
      if (s == 'Dolor de cabeza' || s == 'Headache') return localizations?.headache ?? 'Headache';
      if (s == 'Antojos de comida' || s == 'Food cravings') return localizations?.foodCravings ?? 'Food cravings';
      return s;
    }).toList();
    TextEditingController notasCtrl = TextEditingController(text: record['notes'] ?? '');

    await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(localizations?.editPeriodRecord ?? 'Edit Period Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations?.menstrualTrackingInfo ?? '💡 Menstrual Tracking\nThe menstrual cycle can affect glucose levels. This record helps identify important patterns for your diabetes management.'),
                const SizedBox(height: 16),
                Text(localizations?.startDateRequired ?? '📅 Start date of period *'),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('es'),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                  child: Text(startDate != null ? '${startDate!.day}/${startDate!.month}/${startDate!.year}' : (localizations?.selectStartDate ?? 'Select the start date')),
                ),
                const SizedBox(height: 16),
                Text(localizations?.durationOptional ?? '⏱️ Duration in days (optional)'),
                DropdownButton<int>(
                  value: duracion,
                  items: List.generate(15, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text('$d'))).toList(),
                  onChanged: (v) => setState(() => duracion = v),
                  hint: Text(localizations?.selectDuration ?? 'Select duration'),
                ),
                const SizedBox(height: 16),
                Text(localizations?.intensityRequired ?? '🩸 Intensity'),
                DropdownButton<String>(
                  value: intensidad,
                  items: [
                    DropdownMenuItem(value: localizations?.lightIntensity ?? 'Light', child: Text(localizations?.lightIntensity ?? '🩸 Light')),
                    DropdownMenuItem(value: localizations?.normalIntensity ?? 'Normal', child: Text(localizations?.normalIntensity ?? '🩸🩸 Normal')),
                    DropdownMenuItem(value: localizations?.heavyIntensity ?? 'Heavy', child: Text(localizations?.heavyIntensity ?? '🩸🩸🩸 Heavy')),
                  ],
                  onChanged: (v) => setState(() => intensidad = v),
                  hint: Text(localizations?.selectIntensity ?? 'Select intensity'),
                ),
                const SizedBox(height: 16),
                Text(localizations?.symptomsSelect ?? '🤒 Symptoms (select those that apply)'),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(label: Text(localizations?.pain ?? '😣 Pain'), selected: sintomas.contains(localizations?.pain ?? 'Pain'), onSelected: (v) { setState(() { if (v) sintomas.add(localizations?.pain ?? 'Pain'); else sintomas.remove(localizations?.pain ?? 'Pain'); }); }),
                    FilterChip(label: Text(localizations?.fatigue ?? '😴 Fatigue'), selected: sintomas.contains(localizations?.fatigue ?? 'Fatigue'), onSelected: (v) { setState(() { if (v) sintomas.add(localizations?.fatigue ?? 'Fatigue'); else sintomas.remove(localizations?.fatigue ?? 'Fatigue'); }); }),
                    FilterChip(label: Text(localizations?.moodChanges ?? '😭 Mood changes'), selected: sintomas.contains(localizations?.moodChanges ?? 'Mood changes'), onSelected: (v) { setState(() { if (v) sintomas.add(localizations?.moodChanges ?? 'Mood changes'); else sintomas.remove(localizations?.moodChanges ?? 'Mood changes'); }); }),
                    FilterChip(label: Text(localizations?.swelling ?? '🤱 Swelling'), selected: sintomas.contains(localizations?.swelling ?? 'Swelling'), onSelected: (v) { setState(() { if (v) sintomas.add(localizations?.swelling ?? 'Swelling'); else sintomas.remove(localizations?.swelling ?? 'Swelling'); }); }),
                    FilterChip(label: Text(localizations?.headache ?? '🤕 Headache'), selected: sintomas.contains(localizations?.headache ?? 'Headache'), onSelected: (v) { setState(() { if (v) sintomas.add(localizations?.headache ?? 'Headache'); else sintomas.remove(localizations?.headache ?? 'Headache'); }); }),
                    FilterChip(label: Text(localizations?.foodCravings ?? '🍫 Food cravings'), selected: sintomas.contains(localizations?.foodCravings ?? 'Food cravings'), onSelected: (v) { setState(() { if (v) sintomas.add(localizations?.foodCravings ?? 'Food cravings'); else sintomas.remove(localizations?.foodCravings ?? 'Food cravings'); }); }),
                  ],
                ),
                const SizedBox(height: 16),
                Text(localizations?.additionalNotesOptional ?? '📝 Additional notes (optional)'),
                TextField(
                  controller: notasCtrl,
                  decoration: InputDecoration(hintText: localizations?.notesExample ?? 'E.g.: More intense pain than usual, changes in appetite...'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final username = prefs.getString('username');
                if (username == null || startDate == null) return;
                final endDate = duracion != null ? startDate!.add(Duration(days: duracion!)) : null;
                final result = {
                  'id': record['id'],
                  'username': username,
                  'startDate': startDate!.toIso8601String(),
                  'endDate': endDate?.toIso8601String(),
                  'intensity': intensidad,
                  'symptoms': sintomas.join(', '),
                  'notes': notasCtrl.text,
                  'date_time': DateTime.now().toIso8601String(),
                };
                final success = await apiService.updatePeriodRecord(result);
                if (success) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.recordUpdated ?? 'Record updated successfully')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.recordUpdateError ?? 'Error updating record')));
                }
              },
              child: Text(localizations?.save ?? 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editMoodRecord(Map<String, dynamic> item) async {
    final localizations = AppLocalizations.of(context);
    double moodValue = (item['mood_value'] is int)
        ? (item['mood_value'] as int).toDouble()
        : (item['mood_value'] is double)
            ? item['mood_value']
            : 5.0;
    bool outOfRoutine = item['out_of_routine'] == true;
    final TextEditingController routineCtrl = TextEditingController(text: item['routine_description'] ?? '');
    final TextEditingController otherEmotionCtrl = TextEditingController(text: item['other_emotion'] ?? '');
    List<String> emotions = List<String>.from(item['emotions'] ?? []);
    final List<_Emotion> emotionOptions = [
      _Emotion(localizations?.anger ?? 'Rabia/Ira', Icons.sentiment_very_dissatisfied, Colors.red),
      _Emotion(localizations?.anxiety ?? 'Ansiedad/estrés', Icons.sentiment_dissatisfied, Colors.orange),
      _Emotion(localizations?.fear ?? 'Miedo', Icons.sentiment_very_satisfied, Colors.blue),
      _Emotion(localizations?.joy ?? 'Alegría', Icons.sentiment_satisfied, Colors.orangeAccent),
      _Emotion(localizations?.surprise ?? 'Sorpresa', Icons.sentiment_neutral, Colors.purple),
      _Emotion(localizations?.sadness ?? 'Tristeza', Icons.sentiment_dissatisfied, Colors.amber[800]!),
    ];
    void toggleEmotion(String emotion) {
      if (emotions.contains(emotion)) {
        emotions.remove(emotion);
      } else {
        emotions.add(emotion);
      }
    }
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations?.editMoodStatus ?? 'Editar estado de ánimo'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  localizations?.moodScreenQuestion ?? '¿Qué tal ha sido tu día?',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red, size: 32),
                    Expanded(
                      child: Slider(
                        value: moodValue,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: moodValue.round().toString(),
                        onChanged: (value) {
                          (context as Element).markNeedsBuild();
                          moodValue = value;
                        },
                      ),
                    ),
                    const Icon(Icons.sentiment_very_satisfied, color: Color.fromARGB(255, 255, 177, 59), size: 32),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: outOfRoutine,
                      onChanged: (v) {
                        outOfRoutine = v!;
                        (context as Element).markNeedsBuild();
                      },
                    ),
                    Expanded(
                      child: Text(
                        localizations?.outOfRoutineQuestion ?? '¿Ha ocurrido algo que te haya sacado de tu rutina?',
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                if (outOfRoutine)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 10),
                    child: TextField(
                      controller: routineCtrl,
                      decoration: InputDecoration(
                        labelText: localizations?.routineDescriptionLabel ?? 'Describe brevemente qué ha pasado',
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  localizations?.selectEmotions ?? 'Si has sentido alguna de estas emociones, márcala/s',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: emotionOptions.map((e) {
                      final selected = emotions.contains(e.name);
                      return GestureDetector(
                        onTap: () {
                          toggleEmotion(e.name);
                          (context as Element).markNeedsBuild();
                        },
                        child: Card(
                          color: selected ? e.color.withOpacity(0.7) : Colors.white,
                          elevation: selected ? 6 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: selected ? e.color : Colors.grey.shade300, width: 2),
                          ),
                          child: SizedBox(
                            width: 130,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(e.icon, color: e.color, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  e.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(localizations?.otherEmotionLabel ?? 'Si has sentido alguna otra emoción escríbela'),
                const SizedBox(height: 8),
                TextField(
                  controller: otherEmotionCtrl,
                  decoration: InputDecoration(
                    hintText: localizations?.otherEmotionHint ?? 'Escribe aquí...',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(localizations?.save ?? 'Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0039AE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final data = {
                        'id': item['id'],
                        'mood_value': moodValue.round(),
                        'out_of_routine': outOfRoutine,
                        'routine_description': outOfRoutine ? routineCtrl.text : null,
                        'emotions': emotions,
                        'other_emotion': otherEmotionCtrl.text,
                        'date_time': item['date_time'],
                      };
                      final success = await _apiService.updateMoodRecord(data);
                      if (success) {
                        Navigator.pop(context);
                        await _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.recordUpdated ?? 'Registro actualizado')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.recordUpdateError ?? 'Error al actualizar')));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Añade esta clase si no existe ya en este archivo
class _Emotion {
  final String name;
  final IconData icon;
  final Color color;
  _Emotion(this.name, this.icon, this.color);
}

// ===================== LOGIN =====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoggedIn = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Comprobar si el usuario ya ha iniciado sesión
  _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInUser = prefs.getString('username');
    if (loggedInUser != null) {
      // Verificar si el token sigue siendo válido
      final isTokenValid = await AuthService.verifyTokenValidity(context);
      if (isTokenValid) {
        setState(() {
          _isLoggedIn = true;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // El token ha expirado, limpiar la sesión
        await AuthService.logout(context);
      }
    }
  }

  Future<void> _handleLogin(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    // Asegura que el UUID existe antes de intentar login
    String uuid = prefs.getString('device_id') ?? await getOrCreateDeviceId();

    final loginData = {
      'username': username,
      'password': password,
      'UUID': uuid,
    };

    try {
      final response = await http.post(
        Uri.parse('${apiService.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['token'] != null) {
          await prefs.setString('auth_token', responseData['token']);
        }
        await prefs.setString('username', username);
        
        // Llama aquí a _checkUserProfile antes de mostrar la HomeScreen
        await _checkUserProfile(context);

        // Verificar si es el primer inicio de sesión
        bool hasConsented = prefs.getBool('has_consented') ?? false;
        bool isFirstLogin = prefs.getBool('is_first_login') ?? true;
        
        if (!hasConsented) {
          // Mostrar pantalla de consentimiento
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GDPRConsentScreen(
                username: username,
                onConsentGiven: (bool consented) async {
                  if (consented) {
                    await prefs.setBool('has_consented', true);
                    // Solo pedir cambio de contraseña si es el primer inicio de sesión
                    if (isFirstLogin) {
                      await prefs.setBool('is_first_login', false);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        } else {
          setState(() {
            _isLoggedIn = true;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.loginErrorDevice ?? 'Incorrect username or password or unauthorized device'),
          ),
        );
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations?.loginErrorGeneric ?? 'Login error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.loginTitle ?? 'Login'),
        backgroundColor: const Color(0xFF0039AE),
        foregroundColor: Colors.white,
        actions: [
          // Botón de cambio de idioma en la AppBar
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => const LanguageDialog(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                  const SizedBox(height: 32),
              TextFormField(
                controller: usernameController,
                style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: localizations?.usernameLabel ?? 'Username',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                        return localizations?.usernameRequired ?? 'Please enter your username';
                  }
                  return null;
                },
              ),
                  const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                      labelText: localizations?.passwordLabel ?? 'Password',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                  suffixIcon: IconButton(
                    icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                        return localizations?.passwordRequired ?? 'Please enter your password';
                  }
                  return null;
                },
              ),
                  const SizedBox(height: 32),
              ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _handleLogin(
                          usernameController.text,
                          passwordController.text,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0039AE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      localizations?.loginButton ?? 'LOGIN',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== FUNCIONES ADICIONALES =====================
Future<String?> _recuperarUsername() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username'); // Obtiene el username guardado
}

Future<String> getOrCreateDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');

  if (deviceId == null) {
    var uuid = Uuid();
    deviceId = uuid.v4();
    await prefs.setString('device_id', deviceId);
    print("Nuevo ID generado: $deviceId");
  } else {
    print("ID existente: $deviceId");
  }

  return deviceId;
}

// ===================== CONSENTIMIENTO GDPR =====================
class GDPRConsentScreen extends StatefulWidget {
  final String username;
  final Function(bool) onConsentGiven;

  const GDPRConsentScreen({
    super.key,
    required this.username,
    required this.onConsentGiven,
  });

  @override
  _GDPRConsentScreenState createState() => _GDPRConsentScreenState();
}

class _GDPRConsentScreenState extends State<GDPRConsentScreen> {
  bool _hasConsented = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.informedConsent ?? 'Informed Consent'),
        backgroundColor: const Color(0xFF0039AE),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations?.medicalResearchDiabetes ?? '🔬 Consentimiento Informado\nInvestigación en Diabetes • GDPR Cumplimiento',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0039AE),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                localizations?.medicalResearchParticipation ?? '🏥 Participación en Investigación Médica\nTu participación es voluntaria y contribuye al avance de la investigación en diabetes',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                localizations?.whatInfoWeCollect ?? '📊 ¿Qué información recopilamos?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoItem(localizations?.anonymousMedicalDataDesc ?? '✅ Datos médicos anónimos: Registros de glucosa, insulina, ejercicio y alimentación'),
              _buildInfoItem(localizations?.healthContextDesc ?? '✅ Contexto de salud: Calidad del sueño, niveles de estrés, actividades diarias'),
              _buildInfoItem(localizations?.basicMedicalInfoDesc ?? '✅ Información médica básica: Tipo de terapia (BICI/MDI) y sexo biológico para cálculos específicos'),
              const SizedBox(height: 20),
              Text(
                localizations?.whatInfoUsedFor ?? '🎯 ¿Para qué se utiliza esta información?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoItem(localizations?.medicalResearchDesc ?? '🔬 Investigación médica: Mejorar tratamientos y comprensión de la diabetes'),
              _buildInfoItem(localizations?.statisticalAnalysisDesc ?? '📈 Análisis estadísticos: Identificar patrones y tendencias para beneficio general'),
              _buildInfoItem(localizations?.treatmentImprovementDesc ?? '⚡ Mejora del tratamiento: Desarrollar recomendaciones personalizadas'),
              const SizedBox(height: 20),
              Text(
                localizations?.privacyAndRightsTitle ?? '🛡️ Tu privacidad y derechos',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoItem(localizations?.anonymousDataDesc ?? '🔒 Datos completamente anónimos: No se guarda información que te identifique personalmente'),
              _buildInfoItem(localizations?.revocableConsentDesc ?? '📝 Consentimiento revocable: Puedes retirar tu consentimiento en cualquier momento desde ajustes'),
              _buildInfoItem(localizations?.gdprComplianceDesc ?? '🌍 Cumplimiento GDPR: Todos los datos se manejan según normativas europeas de protección'),
              const SizedBox(height: 20),
              Text(
                localizations?.dataQuestionsDesc ?? '📧 ¿Preguntas sobre tus datos?\nPara cualquier consulta sobre el manejo de datos o para solicitar su eliminación, contacta con el equipo de investigación a través de los canales oficiales del proyecto.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              CheckboxListTile(
                title: Text(
                  localizations?.acceptResearchParticipation ?? 'Acepto participar en la investigación',
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  localizations?.acceptResearchSubtitle ?? 'Al hacer clic en "Acepto", confirmas que has leído y comprendido la información sobre el uso de tus datos para investigación médica en diabetes.',
                  style: const TextStyle(fontSize: 14),
                ),
                value: _hasConsented,
                onChanged: (bool? value) {
                  setState(() {
                    _hasConsented = value ?? false;
                  });
                },
                activeColor: const Color(0xFF0039AE),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasConsented
                      ? () async {
                          final apiService = getApiService(context);
                          final success = await apiService.sendFormData('updateGDPRConsent', {
                            'username': widget.username,
                            'hasConsented': true,
                          });
                          if (success) {
                            widget.onConsentGiven(true);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePasswordScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(localizations?.consentSaveError ?? 'Error saving consent')));
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0039AE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    localizations?.acceptAndContinue ?? 'Accept and Continue',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => mostrarPoliticaPrivacidad(context),
                child: Text(localizations?.privacyPolicy ?? 'Ver política de privacidad'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== CAMBIO DE CONTRASEÑA =====================
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.changePasswordTitle ?? 'Change Password'),
        backgroundColor: const Color(0xFF0039AE),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.pleaseSetNewPassword ?? 'Por favor, establece una nueva contraseña para tu cuenta:',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: localizations?.newPasswordLabel ?? 'New password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.pleaseEnterPassword ?? 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return localizations?.passwordRequirements ?? 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: localizations?.confirmPasswordLabel ?? 'Confirm password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.pleaseConfirmPassword ?? 'Please confirm your password';
                    }
                    if (value != _newPasswordController.text) {
                      return localizations?.passwordsDoNotMatch ?? 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final prefs = await SharedPreferences.getInstance();
                      final username = prefs.getString('username');
                      
                      if (username != null) {
                        final changePasswordData = {
                      'username': username,
                          'newPassword': _newPasswordController.text,
                    };

                    try {
                      bool success = await apiService.sendFormData(
                            'changePassword',
                            changePasswordData,
                          );

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations?.passwordChangeSuccess ?? 'Password changed successfully'),
                              ),
                            );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                                content: Text(localizations?.passwordChangeError ?? 'Error changing password'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                              content: Text(localizations?.passwordChangeError ?? 'Error changing password'),
                        ),
                      );
                        }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0039AE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    localizations?.changePasswordButton ?? 'Change Password',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}

// 1. Al iniciar sesión por primera vez, pedir sexo y uso de bomba de insulina
Future<void> _checkUserProfile(BuildContext context) async {
  final localizations = AppLocalizations.of(context);
  final prefs = await SharedPreferences.getInstance();
  final sexo = prefs.getString('sexo');
  final bomba = prefs.getBool('bomba_insulina');
  if (sexo == null || bomba == null) {
    String? selectedSexo;
    bool bombaInsulina = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations?.completeProfile ?? 'Complete your profile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizations?.whatIsYourSex ?? '¿Cuál es tu sexo?'),
                  DropdownButton<String>(
                    value: selectedSexo,
                    items: [
                      DropdownMenuItem(value: 'male', child: Text(localizations?.male ?? 'Male')),
                      DropdownMenuItem(value: 'female', child: Text(localizations?.female ?? 'Female')),
                    ],
                    onChanged: (v) => setState(() => selectedSexo = v),
                    hint: Text(localizations?.selectSex ?? 'Select your sex'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: bombaInsulina,
                        onChanged: (v) => setState(() => bombaInsulina = v ?? false),
                      ),
                      Text(localizations?.useInsulinPump ?? 'I use insulin pump'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (selectedSexo != null) {
                      await prefs.setString('sexo', selectedSexo!);
                      await prefs.setBool('bomba_insulina', bombaInsulina);
                      // Llama al backend para guardar en la base de datos
                      final username = prefs.getString('username');
                      if (username != null) {
                        await apiService.sendFormData('updateUserProfile', {
                          'username': username,
                          'sexo': selectedSexo,
                          'bomba_insulina': bombaInsulina,
                        });
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(localizations?.saveProfile ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Llama a _checkUserProfile(context) tras el login exitoso y antes de mostrar la home
// ...
// 2. Ocultar insulina si usa bomba
Future<bool> _usaBombaInsulina() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('bomba_insulina') ?? false;
}
// ...
// 3. Mostrar botón de período si es mujer
Future<bool> _esMujer() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('sexo') == 'female';
}
// ...
// 4. Formulario de período
Future<void> _mostrarDialogoPeriodo(BuildContext context) async {
  final localizations = AppLocalizations.of(context);
  DateTime? fechaInicio;
  int? duracion;
  String? intensidad;
  List<String> sintomas = [];
  TextEditingController notasCtrl = TextEditingController();
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('🩸 ${localizations?.registerPeriod ?? 'Register Period'}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations?.menstrualTrackingInfo ?? '💡 Seguimiento Menstrual\nEl ciclo menstrual puede afectar los niveles de glucosa. Este registro ayuda a identificar patrones importantes para tu manejo de diabetes.'),
            const SizedBox(height: 16),
            Text(localizations?.startDateRequired ?? '📅 Fecha de inicio del período *'),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: const Locale('es'),
                );
                if (picked != null) fechaInicio = picked;
              },
              child: Text(fechaInicio != null ? '${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}' : (localizations?.selectDate ?? 'Select date')),
            ),
            const SizedBox(height: 16),
            Text(localizations?.durationOptional ?? '⏱️ Duración en días (opcional)'),
            DropdownButton<int>(
              value: duracion,
              items: List.generate(15, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text('$d'))).toList(),
              onChanged: (v) => duracion = v,
              hint: Text(localizations?.selectDuration ?? 'Select duration'),
            ),
            const SizedBox(height: 16),
            Text(localizations?.intensityRequired ?? '🩸 Intensidad'),
            DropdownButton<String>(
              value: intensidad,
              items: [
                DropdownMenuItem(value: localizations?.lightIntensity ?? '🩸 Ligera', child: Text(localizations?.lightIntensity ?? '🩸 Ligera')),
                DropdownMenuItem(value: localizations?.normalIntensity ?? '🩸🩸 Normal', child: Text(localizations?.normalIntensity ?? '🩸🩸 Normal')),
                DropdownMenuItem(value: localizations?.heavyIntensity ?? '🩸🩸🩸 Abundante', child: Text(localizations?.heavyIntensity ?? '🩸🩸🩸 Abundante')),
              ],
              onChanged: (v) => intensidad = v,
              hint: Text(localizations?.selectIntensity ?? 'Select intensity'),
            ),
            const SizedBox(height: 16),
            Text(localizations?.symptomsSelect ?? '🤒 Síntomas (selecciona los que apliquen)'),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: Text(localizations?.pain ?? '😣 Dolor'), selected: sintomas.contains(localizations?.pain ?? '😣 Dolor'), onSelected: (v) { if (v) sintomas.add(localizations?.pain ?? '😣 Dolor'); else sintomas.remove(localizations?.pain ?? '😣 Dolor'); }),
                FilterChip(label: Text(localizations?.fatigue ?? '😴 Fatiga'), selected: sintomas.contains(localizations?.fatigue ?? '😴 Fatiga'), onSelected: (v) { if (v) sintomas.add(localizations?.fatigue ?? '😴 Fatiga'); else sintomas.remove(localizations?.fatigue ?? '😴 Fatiga'); }),
                FilterChip(label: Text(localizations?.moodChanges ?? '😭 Cambios de humor'), selected: sintomas.contains(localizations?.moodChanges ?? '😭 Cambios de humor'), onSelected: (v) { if (v) sintomas.add(localizations?.moodChanges ?? '😭 Cambios de humor'); else sintomas.remove(localizations?.moodChanges ?? '😭 Cambios de humor'); }),
                FilterChip(label: Text(localizations?.swelling ?? '🤱 Hinchazón'), selected: sintomas.contains(localizations?.swelling ?? '🤱 Hinchazón'), onSelected: (v) { if (v) sintomas.add(localizations?.swelling ?? '🤱 Hinchazón'); else sintomas.remove(localizations?.swelling ?? '🤱 Hinchazón'); }),
                FilterChip(label: Text(localizations?.headache ?? '🤕 Dolor de cabeza'), selected: sintomas.contains(localizations?.headache ?? '�� Dolor de cabeza'), onSelected: (v) { if (v) sintomas.add(localizations?.headache ?? '🤕 Dolor de cabeza'); else sintomas.remove(localizations?.headache ?? '🤕 Dolor de cabeza'); }),
                FilterChip(label: Text(localizations?.foodCravings ?? '🍫 Antojos de comida'), selected: sintomas.contains(localizations?.foodCravings ?? '🍫 Antojos de comida'), onSelected: (v) { if (v) sintomas.add(localizations?.foodCravings ?? '🍫 Antojos de comida'); else sintomas.remove(localizations?.foodCravings ?? '🍫 Antojos de comida'); }),
              ],
            ),
            const SizedBox(height: 16),
            Text(localizations?.additionalNotesOptional ?? '📝 Notas adicionales (opcional)'),
            TextField(
              controller: notasCtrl,
              decoration: InputDecoration(hintText: localizations?.notesExample ?? 'Ej: Dolor más intenso de lo normal, cambios en apetito...'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Aquí deberías guardar el registro en la base de datos o backend
            Navigator.pop(context);
          },
          child: Text(localizations?.save ?? 'Save'),
        ),
      ],
    ),
  );
}
// ...
// En la pantalla principal y en consultar registros, usa _usaBombaInsulina() y _esMujer() para mostrar/ocultar los widgets correspondientes.
// ...

Future<void> borrarSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final deviceId = prefs.getString('device_id');
  await prefs.clear();
  if (deviceId != null) {
    await prefs.setString('device_id', deviceId);
  }
}

// Nueva pantalla para registrar período
class PeriodFormScreen extends StatefulWidget {
  const PeriodFormScreen({super.key});

  @override
  State<PeriodFormScreen> createState() => _PeriodFormScreenState();
}

class _PeriodFormScreenState extends State<PeriodFormScreen> {
  DateTime? fechaInicio;
  int? duracion;
  String? intensidad;
  List<String> sintomas = [];
  TextEditingController notasCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.registerPeriodTitle ?? 'Register Period'),
        backgroundColor: const Color(0xFF0039AE),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations?.menstrualTrackingInfo ?? '💡 Seguimiento Menstrual\nEl ciclo menstrual puede afectar los niveles de glucosa. Este registro ayuda a identificar patrones importantes para tu manejo de diabetes.'),
              const SizedBox(height: 16),
              Text(localizations?.startDateRequired ?? '📅 Fecha de inicio del período *'),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es'),
                  );
                  if (picked != null) setState(() => fechaInicio = picked);
                },
                child: Text(fechaInicio != null ? '${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}' : (localizations?.selectDate ?? 'Select date')),
              ),
              const SizedBox(height: 16),
              Text(localizations?.durationOptional ?? '⏱️ Duración en días (opcional)'),
              DropdownButton<int>(
                value: duracion,
                items: List.generate(15, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text('$d'))).toList(),
                onChanged: (v) => setState(() => duracion = v),
                hint: Text(localizations?.selectDuration ?? 'Select duration'),
              ),
              const SizedBox(height: 16),
              Text(localizations?.intensityRequired ?? '🩸 Intensidad'),
              DropdownButton<String>(
                value: intensidad,
                items: [
                  DropdownMenuItem(value: localizations?.lightIntensity ?? '🩸 Ligera', child: Text(localizations?.lightIntensity ?? '🩸 Ligera')),
                  DropdownMenuItem(value: localizations?.normalIntensity ?? '🩸🩸 Normal', child: Text(localizations?.normalIntensity ?? '🩸🩸 Normal')),
                  DropdownMenuItem(value: localizations?.heavyIntensity ?? '🩸🩸🩸 Abundante', child: Text(localizations?.heavyIntensity ?? '🩸🩸🩸 Abundante')),
                ],
                onChanged: (v) => intensidad = v,
                hint: Text(localizations?.selectIntensity ?? 'Select intensity'),
              ),
              const SizedBox(height: 16),
              Text(localizations?.symptomsSelect ?? '🤒 Síntomas (selecciona los que apliquen)'),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(label: Text(localizations?.pain ?? '😣 Dolor'), selected: sintomas.contains(localizations?.pain ?? '😣 Dolor'), onSelected: (v) => setState(() => v ? sintomas.add(localizations?.pain ?? '😣 Dolor') : sintomas.remove(localizations?.pain ?? '😣 Dolor'))),
                  FilterChip(label: Text(localizations?.fatigue ?? '😴 Fatiga'), selected: sintomas.contains(localizations?.fatigue ?? '😴 Fatiga'), onSelected: (v) => setState(() => v ? sintomas.add(localizations?.fatigue ?? '😴 Fatiga') : sintomas.remove(localizations?.fatigue ?? '😴 Fatiga'))),
                  FilterChip(label: Text(localizations?.moodChanges ?? '😭 Cambios de humor'), selected: sintomas.contains(localizations?.moodChanges ?? '😭 Cambios de humor'), onSelected: (v) => setState(() => v ? sintomas.add(localizations?.moodChanges ?? '😭 Cambios de humor') : sintomas.remove(localizations?.moodChanges ?? '😭 Cambios de humor'))),
                  FilterChip(label: Text(localizations?.swelling ?? '🤱 Hinchazón'), selected: sintomas.contains(localizations?.swelling ?? '🤱 Hinchazón'), onSelected: (v) => setState(() => v ? sintomas.add(localizations?.swelling ?? '🤱 Hinchazón') : sintomas.remove(localizations?.swelling ?? '🤱 Hinchazón'))),
                  FilterChip(label: Text(localizations?.headache ?? '🤕 Dolor de cabeza'), selected: sintomas.contains(localizations?.headache ?? '🤕 Dolor de cabeza'), onSelected: (v) => setState(() => v ? sintomas.add(localizations?.headache ?? '🤕 Dolor de cabeza') : sintomas.remove(localizations?.headache ?? '🤕 Dolor de cabeza'))),
                  FilterChip(label: Text(localizations?.foodCravings ?? '🍫 Antojos de comida'), selected: sintomas.contains(localizations?.foodCravings ?? '🍫 Antojos de comida'), onSelected: (v) => setState(() => v ? sintomas.add(localizations?.foodCravings ?? '🍫 Antojos de comida') : sintomas.remove(localizations?.foodCravings ?? '🍫 Antojos de comida'))),
                ],
              ),
              const SizedBox(height: 16),
              Text(localizations?.additionalNotesOptional ?? '📝 Notas adicionales (opcional)'),
              TextField(
                controller: notasCtrl,
                decoration: InputDecoration(hintText: localizations?.notesExample ?? 'Ej: Dolor más intenso de lo normal, cambios en apetito...'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (fechaInicio == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.selectStartDateSnack ?? 'Select the start date')));
                      return;
                    }
  final prefs = await SharedPreferences.getInstance();
                    final username = prefs.getString('username');
                    if (username == null) return;
                    await apiService.sendFormData('addPeriodRecord', {
                      'username': username,
                      'startDate': fechaInicio!.toIso8601String(),
                      'endDate': duracion != null ? fechaInicio!.add(Duration(days: duracion!)).toIso8601String() : null,
                      'intensity': intensidad,
                      'symptoms': sintomas.join(', '),
                      'notes': notasCtrl.text,
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations?.periodSaved ?? 'Period registered successfully')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0039AE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(localizations?.save ?? 'Save', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. Banner de cookies reutilizando el consentimiento GDPR
class CookieBanner extends StatefulWidget {
  final void Function()? onAccept;
  final void Function()? onReject;
  const CookieBanner({super.key, this.onAccept, this.onReject});
  @override
  State<CookieBanner> createState() => _CookieBannerState();
}
class _CookieBannerState extends State<CookieBanner> {
  bool _accepted = false;
  bool _rejected = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCookiePref();
  }

  Future<void> _loadCookiePref() async {
  final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accepted = prefs.getBool('cookies_accepted') ?? false;
      _rejected = prefs.getBool('cookies_rejected') ?? false;
      _loading = false;
    });
  }

  Future<void> _setCookiePref(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cookies_accepted', accepted);
    await prefs.setBool('cookies_rejected', !accepted);
    setState(() {
      _accepted = accepted;
      _rejected = !accepted;
    });
    if (accepted) {
      widget.onAccept?.call();
  } else {
      widget.onReject?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (_loading || _accepted || _rejected) return const SizedBox.shrink();
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          color: Colors.black.withOpacity(0.85),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations?.cookiesBanner ?? 'Esta app utiliza solo cookies técnicas y de sesión para el funcionamiento básico y la autenticación. No usamos cookies de rastreo ni de terceros. Puedes cambiar tu preferencia en Ajustes.',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _setCookiePref(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0039AE),
                    ),
                    child: Text(localizations?.acceptCookies ?? 'Accept'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _setCookiePref(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                    ),
                    child: Text(localizations?.rejectCookies ?? 'Reject'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para mostrar la política de privacidad
void mostrarPoliticaPrivacidad(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(localizations?.privacyPolicyTitle ?? 'Política de Privacidad'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations?.privacyPolicyResponsible ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Text(localizations?.privacyPolicyDataCollected ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(localizations?.privacyPolicyPurpose ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(localizations?.privacyPolicyLegalBasis ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(localizations?.privacyPolicyAccess ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(localizations?.privacyPolicyStorage ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(localizations?.privacyPolicySecurity ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(localizations?.privacyPolicyRetention ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(localizations?.privacyPolicyRights ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(localizations?.privacyPolicyConsent ?? '', style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations?.close ?? 'Cerrar'),
        ),
      ],
    ),
  );
}
