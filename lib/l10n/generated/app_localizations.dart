import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Diabetes Tracker'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @insulinRecord.
  ///
  /// In en, this message translates to:
  /// **'Insulin Record'**
  String get insulinRecord;

  /// No description provided for @foodRecord.
  ///
  /// In en, this message translates to:
  /// **'Food Record'**
  String get foodRecord;

  /// No description provided for @exerciseRecord.
  ///
  /// In en, this message translates to:
  /// **'Exercise Record'**
  String get exerciseRecord;

  /// No description provided for @periodRecord.
  ///
  /// In en, this message translates to:
  /// **'Period Record'**
  String get periodRecord;

  /// No description provided for @viewRecords.
  ///
  /// In en, this message translates to:
  /// **'View Records'**
  String get viewRecords;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecord;

  /// No description provided for @deleteRecordConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record of'**
  String get deleteRecordConfirmation;

  /// No description provided for @deleteRecordWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteRecordWarning;

  /// No description provided for @deleteRecordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record deleted successfully'**
  String get deleteRecordSuccess;

  /// No description provided for @deleteRecordError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting record'**
  String get deleteRecordError;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get confirmDelete;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordRequirements;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get tryAgain;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get usernameRequired;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password'**
  String get loginError;

  /// No description provided for @gdprConsent.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Data Consent'**
  String get gdprConsent;

  /// No description provided for @gdprMessage.
  ///
  /// In en, this message translates to:
  /// **'This app collects and processes your health data to provide diabetes tracking services. By continuing, you consent to the collection and processing of your data as described in our Privacy Policy.'**
  String get gdprMessage;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @revokeConsent.
  ///
  /// In en, this message translates to:
  /// **'Revoke Consent'**
  String get revokeConsent;

  /// No description provided for @revokeConsentDesc.
  ///
  /// In en, this message translates to:
  /// **'You can revoke your consent to participate in the research at any time. This will log you out and you will not be able to access the app until you give your consent again.'**
  String get revokeConsentDesc;

  /// No description provided for @revokeConsentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get revokeConsentDialogTitle;

  /// No description provided for @revokeConsentDialogContent.
  ///
  /// In en, this message translates to:
  /// **'By revoking your consent, you will be logged out and will not be able to access the app until you give your consent again. Your data will remain in the system.'**
  String get revokeConsentDialogContent;

  /// No description provided for @revokeConsentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Consent successfully revoked'**
  String get revokeConsentSuccess;

  /// No description provided for @revokeConsentError.
  ///
  /// In en, this message translates to:
  /// **'Error revoking consent'**
  String get revokeConsentError;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataDesc.
  ///
  /// In en, this message translates to:
  /// **'This action will delete all your insulin, food and exercise records. This action cannot be undone.'**
  String get deleteAllDataDesc;

  /// No description provided for @deleteAllDataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllDataDialogTitle;

  /// No description provided for @deleteAllDataDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all your data? This action cannot be undone.'**
  String get deleteAllDataDialogContent;

  /// No description provided for @deleteAllDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data deleted successfully'**
  String get deleteAllDataSuccess;

  /// No description provided for @deleteAllDataError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting data'**
  String get deleteAllDataError;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select duration'**
  String get selectDuration;

  /// No description provided for @selectIntensity.
  ///
  /// In en, this message translates to:
  /// **'Select intensity'**
  String get selectIntensity;

  /// No description provided for @selectSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Select symptoms'**
  String get selectSymptoms;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional notes (optional)'**
  String get additionalNotes;

  /// No description provided for @registerPeriod.
  ///
  /// In en, this message translates to:
  /// **'Register Period'**
  String get registerPeriod;

  /// No description provided for @menstrualTracking.
  ///
  /// In en, this message translates to:
  /// **'Menstrual Tracking\nThe menstrual cycle can affect glucose levels. This record helps identify important patterns for your diabetes management.'**
  String get menstrualTracking;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date of period *'**
  String get startDateLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration in days (optional)'**
  String get durationLabel;

  /// No description provided for @intensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensityLabel;

  /// No description provided for @symptomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptomsLabel;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: More intense pain than usual, changes in appetite...'**
  String get notesHint;

  /// No description provided for @periodRegistered.
  ///
  /// In en, this message translates to:
  /// **'Period registered successfully'**
  String get periodRegistered;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select the start date'**
  String get selectStartDate;

  /// No description provided for @noUserFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get noUserFound;

  /// No description provided for @loadDataError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data:'**
  String get loadDataError;

  /// No description provided for @noRecordsOfType.
  ///
  /// In en, this message translates to:
  /// **'No {type} records'**
  String noRecordsOfType(Object type);

  /// No description provided for @insulinType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get insulinType;

  /// No description provided for @insulinDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get insulinDose;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date and Time'**
  String get dateTime;

  /// No description provided for @foodType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get foodType;

  /// No description provided for @foodAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get foodAmount;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbs;

  /// No description provided for @exerciseType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exerciseType;

  /// No description provided for @exerciseIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get exerciseIntensity;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @periodStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get periodStart;

  /// No description provided for @periodDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get periodDuration;

  /// No description provided for @periodIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get periodIntensity;

  /// No description provided for @periodSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get periodSymptoms;

  /// No description provided for @periodNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get periodNotes;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @menstruation.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get menstruation;

  /// No description provided for @cramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get cramps;

  /// No description provided for @headache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get headache;

  /// No description provided for @fatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get fatigue;

  /// No description provided for @moodChanges.
  ///
  /// In en, this message translates to:
  /// **'Mood changes'**
  String get moodChanges;

  /// No description provided for @foodCravings.
  ///
  /// In en, this message translates to:
  /// **'Food cravings'**
  String get foodCravings;

  /// No description provided for @periodInfo.
  ///
  /// In en, this message translates to:
  /// **'Menstrual cycle can affect glucose levels. This record helps identify important patterns.'**
  String get periodInfo;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @insulin.
  ///
  /// In en, this message translates to:
  /// **'Insulin'**
  String get insulin;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get noRecords;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language / Idioma'**
  String get selectLanguageTitle;

  /// No description provided for @medicalResearchConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Informed Consent'**
  String get medicalResearchConsentTitle;

  /// No description provided for @medicalResearchConsentDesc.
  ///
  /// In en, this message translates to:
  /// **'Your participation is voluntary and contributes to the advancement of diabetes research.'**
  String get medicalResearchConsentDesc;

  /// No description provided for @whatInfoCollected.
  ///
  /// In en, this message translates to:
  /// **'What information do we collect?'**
  String get whatInfoCollected;

  /// No description provided for @anonymousMedicalData.
  ///
  /// In en, this message translates to:
  /// **'Anonymous medical data: Glucose, insulin, exercise and food records'**
  String get anonymousMedicalData;

  /// No description provided for @healthContext.
  ///
  /// In en, this message translates to:
  /// **'Health context: Sleep quality, stress levels, daily activities'**
  String get healthContext;

  /// No description provided for @basicMedicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic medical info: Therapy type (BICI/MDI) and biological sex for specific calculations'**
  String get basicMedicalInfo;

  /// No description provided for @infoUsage.
  ///
  /// In en, this message translates to:
  /// **'What is this information used for?'**
  String get infoUsage;

  /// No description provided for @medicalResearch.
  ///
  /// In en, this message translates to:
  /// **'Medical research: Improve treatments and understanding of diabetes'**
  String get medicalResearch;

  /// No description provided for @statisticalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Statistical analysis: Identify patterns and trends for general benefit'**
  String get statisticalAnalysis;

  /// No description provided for @treatmentImprovement.
  ///
  /// In en, this message translates to:
  /// **'Treatment improvement: Develop personalized recommendations'**
  String get treatmentImprovement;

  /// No description provided for @privacyAndRights.
  ///
  /// In en, this message translates to:
  /// **'Your privacy and rights'**
  String get privacyAndRights;

  /// No description provided for @anonymousData.
  ///
  /// In en, this message translates to:
  /// **'Completely anonymous data: No personally identifying information is stored'**
  String get anonymousData;

  /// No description provided for @revocableConsent.
  ///
  /// In en, this message translates to:
  /// **'Revocable consent: You can withdraw your consent at any time from settings'**
  String get revocableConsent;

  /// No description provided for @gdprCompliance.
  ///
  /// In en, this message translates to:
  /// **'GDPR compliance: All data is handled according to European regulations'**
  String get gdprCompliance;

  /// No description provided for @dataQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions about your data? For any questions about data handling or to request deletion, contact the research team through the project\'s official channels.'**
  String get dataQuestions;

  /// No description provided for @acceptResearch.
  ///
  /// In en, this message translates to:
  /// **'I agree to participate in the research'**
  String get acceptResearch;

  /// No description provided for @acceptResearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'By clicking \'I agree\', you confirm that you have read and understood the information about the use of your data for medical research in diabetes.'**
  String get acceptResearchSubtitle;

  /// No description provided for @selectStartDateSnack.
  ///
  /// In en, this message translates to:
  /// **'Select the start date'**
  String get selectStartDateSnack;

  /// No description provided for @periodRegisteredSnack.
  ///
  /// In en, this message translates to:
  /// **'Period registered successfully'**
  String get periodRegisteredSnack;

  /// No description provided for @insulinRegisteredSnack.
  ///
  /// In en, this message translates to:
  /// **'Insulin registered successfully'**
  String get insulinRegisteredSnack;

  /// No description provided for @selectDateTimeSnack.
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get selectDateTimeSnack;

  /// No description provided for @foodRegisteredSnack.
  ///
  /// In en, this message translates to:
  /// **'Food registered successfully'**
  String get foodRegisteredSnack;

  /// No description provided for @exerciseRegisteredSnack.
  ///
  /// In en, this message translates to:
  /// **'Exercise registered successfully'**
  String get exerciseRegisteredSnack;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @insulinFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Insulin Record'**
  String get insulinFormTitle;

  /// No description provided for @insulinTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Insulin Type'**
  String get insulinTypeLabel;

  /// No description provided for @insulinDoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Dose (IU)'**
  String get insulinDoseLabel;

  /// No description provided for @insulinDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date and Time of Application'**
  String get insulinDateTimeLabel;

  /// No description provided for @insulinRegistered.
  ///
  /// In en, this message translates to:
  /// **'Insulin registered successfully'**
  String get insulinRegistered;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get selectDateTime;

  /// No description provided for @foodFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Record'**
  String get foodFormTitle;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @hypoglycemia.
  ///
  /// In en, this message translates to:
  /// **'Hypoglycemia'**
  String get hypoglycemia;

  /// No description provided for @foodTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Food Type'**
  String get foodTypeLabel;

  /// No description provided for @lessThanUsual.
  ///
  /// In en, this message translates to:
  /// **'Less than usual'**
  String get lessThanUsual;

  /// No description provided for @sameAsUsual.
  ///
  /// In en, this message translates to:
  /// **'Same as usual'**
  String get sameAsUsual;

  /// No description provided for @moreThanUsual.
  ///
  /// In en, this message translates to:
  /// **'More than usual'**
  String get moreThanUsual;

  /// No description provided for @foodAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get foodAmountLabel;

  /// No description provided for @carbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates (g)'**
  String get carbsLabel;

  /// No description provided for @foodDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date and Time of the meal'**
  String get foodDateTimeLabel;

  /// No description provided for @foodRegistered.
  ///
  /// In en, this message translates to:
  /// **'Food registered successfully'**
  String get foodRegistered;

  /// No description provided for @selectDateTimeFood.
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get selectDateTimeFood;

  /// No description provided for @exerciseFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Record'**
  String get exerciseFormTitle;

  /// No description provided for @aerobic.
  ///
  /// In en, this message translates to:
  /// **'Aerobic'**
  String get aerobic;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @hit.
  ///
  /// In en, this message translates to:
  /// **'HIT'**
  String get hit;

  /// No description provided for @exerciseTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise Type'**
  String get exerciseTypeLabel;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// No description provided for @exerciseRegistered.
  ///
  /// In en, this message translates to:
  /// **'Exercise registered successfully'**
  String get exerciseRegistered;

  /// No description provided for @selectStartEndTime.
  ///
  /// In en, this message translates to:
  /// **'Select start and end time'**
  String get selectStartEndTime;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String errorWithDetails(Object details);

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @insulinSection.
  ///
  /// In en, this message translates to:
  /// **'Insulin'**
  String get insulinSection;

  /// No description provided for @foodSection.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get foodSection;

  /// No description provided for @exerciseSection.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseSection;

  /// No description provided for @periodSection.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodSection;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydrates;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @editInsulinRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Insulin Record'**
  String get editInsulinRecord;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @recordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Record updated successfully'**
  String get recordUpdated;

  /// No description provided for @recordUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating record'**
  String get recordUpdateError;

  /// No description provided for @editFoodRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Food Record'**
  String get editFoodRecord;

  /// No description provided for @editExerciseRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise Record'**
  String get editExerciseRecord;

  /// No description provided for @startHour.
  ///
  /// In en, this message translates to:
  /// **'Start Hour'**
  String get startHour;

  /// No description provided for @endHour.
  ///
  /// In en, this message translates to:
  /// **'End Hour'**
  String get endHour;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Data'**
  String get privacySettings;

  /// No description provided for @fastInsulin.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fastInsulin;

  /// No description provided for @slowInsulin.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slowInsulin;

  /// No description provided for @selectInsulinType.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get selectInsulinType;

  /// No description provided for @enterDose.
  ///
  /// In en, this message translates to:
  /// **'Enter dose'**
  String get enterDose;

  /// No description provided for @insulinTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get insulinTypeRequired;

  /// No description provided for @doseRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter dose'**
  String get doseRequired;

  /// No description provided for @dateTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get dateTimeRequired;

  /// No description provided for @insulinSaved.
  ///
  /// In en, this message translates to:
  /// **'Insulin registered successfully'**
  String get insulinSaved;

  /// No description provided for @foodSaved.
  ///
  /// In en, this message translates to:
  /// **'Food registered successfully'**
  String get foodSaved;

  /// No description provided for @exerciseSaved.
  ///
  /// In en, this message translates to:
  /// **'Exercise registered successfully'**
  String get exerciseSaved;

  /// No description provided for @periodSaved.
  ///
  /// In en, this message translates to:
  /// **'Period registered successfully'**
  String get periodSaved;

  /// No description provided for @loginErrorDevice.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password or unauthorized device'**
  String get loginErrorDevice;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginErrorGeneric;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeProfile;

  /// No description provided for @whatIsYourSex.
  ///
  /// In en, this message translates to:
  /// **'What is your sex?'**
  String get whatIsYourSex;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @selectSex.
  ///
  /// In en, this message translates to:
  /// **'Select your sex'**
  String get selectSex;

  /// No description provided for @useInsulinPump.
  ///
  /// In en, this message translates to:
  /// **'I use insulin pump'**
  String get useInsulinPump;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveProfile;

  /// No description provided for @pleaseSetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please set a new password for your account:'**
  String get pleaseSetNewPassword;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordButton;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangeSuccess;

  /// No description provided for @passwordChangeError.
  ///
  /// In en, this message translates to:
  /// **'Error changing password'**
  String get passwordChangeError;

  /// No description provided for @informedConsent.
  ///
  /// In en, this message translates to:
  /// **'Informed Consent'**
  String get informedConsent;

  /// No description provided for @medicalResearchDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes Research • GDPR Compliance'**
  String get medicalResearchDiabetes;

  /// No description provided for @medicalResearchParticipation.
  ///
  /// In en, this message translates to:
  /// **'Your participation is voluntary and contributes to the advancement of diabetes research'**
  String get medicalResearchParticipation;

  /// No description provided for @whatInfoWeCollect.
  ///
  /// In en, this message translates to:
  /// **'What information do we collect?'**
  String get whatInfoWeCollect;

  /// No description provided for @anonymousMedicalDataDesc.
  ///
  /// In en, this message translates to:
  /// **'✅ Anonymous medical data: Glucose, insulin, exercise and food records'**
  String get anonymousMedicalDataDesc;

  /// No description provided for @healthContextDesc.
  ///
  /// In en, this message translates to:
  /// **'✅ Health context: Sleep quality, stress levels, daily activities'**
  String get healthContextDesc;

  /// No description provided for @basicMedicalInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'✅ Basic medical info: Therapy type (BICI/MDI) and biological sex for specific calculations'**
  String get basicMedicalInfoDesc;

  /// No description provided for @whatInfoUsedFor.
  ///
  /// In en, this message translates to:
  /// **'What is this information used for?'**
  String get whatInfoUsedFor;

  /// No description provided for @medicalResearchDesc.
  ///
  /// In en, this message translates to:
  /// **'🔬 Medical research: Improve treatments and understanding of diabetes'**
  String get medicalResearchDesc;

  /// No description provided for @statisticalAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'📈 Statistical analysis: Identify patterns and trends for general benefit'**
  String get statisticalAnalysisDesc;

  /// No description provided for @treatmentImprovementDesc.
  ///
  /// In en, this message translates to:
  /// **'⚡ Treatment improvement: Develop personalized recommendations'**
  String get treatmentImprovementDesc;

  /// No description provided for @privacyAndRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your privacy and rights'**
  String get privacyAndRightsTitle;

  /// No description provided for @anonymousDataDesc.
  ///
  /// In en, this message translates to:
  /// **'🔒 Completely anonymous data: No personally identifying information is stored'**
  String get anonymousDataDesc;

  /// No description provided for @revocableConsentDesc.
  ///
  /// In en, this message translates to:
  /// **'📝 Revocable consent: You can withdraw your consent at any time from settings'**
  String get revocableConsentDesc;

  /// No description provided for @gdprComplianceDesc.
  ///
  /// In en, this message translates to:
  /// **'🌍 GDPR compliance: All data is handled according to European regulations'**
  String get gdprComplianceDesc;

  /// No description provided for @dataQuestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'📧 Questions about your data? For any questions about data handling or to request deletion, contact the research team through the project\'s official channels.'**
  String get dataQuestionsDesc;

  /// No description provided for @acceptResearchParticipation.
  ///
  /// In en, this message translates to:
  /// **'I agree to participate in the research'**
  String get acceptResearchParticipation;

  /// No description provided for @acceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept and Continue'**
  String get acceptAndContinue;

  /// No description provided for @consentSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving consent'**
  String get consentSaveError;

  /// No description provided for @viewRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'View Records'**
  String get viewRecordsTitle;

  /// No description provided for @controlDiabetesLikeBoss.
  ///
  /// In en, this message translates to:
  /// **'Control your diabetes like a boss! 💪\nEvery record is a step towards a healthier life.'**
  String get controlDiabetesLikeBoss;

  /// No description provided for @noDataToShow.
  ///
  /// In en, this message translates to:
  /// **'No data to show'**
  String get noDataToShow;

  /// No description provided for @dataAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Data Analysis'**
  String get dataAnalysis;

  /// No description provided for @dailyInsulinDose.
  ///
  /// In en, this message translates to:
  /// **'Daily Insulin Dose'**
  String get dailyInsulinDose;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// No description provided for @averageCarbsByType.
  ///
  /// In en, this message translates to:
  /// **'Average Carbohydrates by Type'**
  String get averageCarbsByType;

  /// No description provided for @noRecordsOfInsulin.
  ///
  /// In en, this message translates to:
  /// **'No insulin records'**
  String get noRecordsOfInsulin;

  /// No description provided for @noRecordsOfFood.
  ///
  /// In en, this message translates to:
  /// **'No food records'**
  String get noRecordsOfFood;

  /// No description provided for @noRecordsOfExercise.
  ///
  /// In en, this message translates to:
  /// **'No exercise records'**
  String get noRecordsOfExercise;

  /// No description provided for @noRecordsOfPeriod.
  ///
  /// In en, this message translates to:
  /// **'No period records'**
  String get noRecordsOfPeriod;

  /// No description provided for @insulinTypeColon.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get insulinTypeColon;

  /// No description provided for @doseColon.
  ///
  /// In en, this message translates to:
  /// **'Dose:'**
  String get doseColon;

  /// No description provided for @dateTimeColon.
  ///
  /// In en, this message translates to:
  /// **'Date and time:'**
  String get dateTimeColon;

  /// No description provided for @foodTypeColon.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get foodTypeColon;

  /// No description provided for @quantityColon.
  ///
  /// In en, this message translates to:
  /// **'Quantity:'**
  String get quantityColon;

  /// No description provided for @carbsColon.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates:'**
  String get carbsColon;

  /// No description provided for @exerciseTypeColon.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get exerciseTypeColon;

  /// No description provided for @intensityColon.
  ///
  /// In en, this message translates to:
  /// **'Intensity:'**
  String get intensityColon;

  /// No description provided for @descriptionColon.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get descriptionColon;

  /// No description provided for @startTimeColon.
  ///
  /// In en, this message translates to:
  /// **'Start time:'**
  String get startTimeColon;

  /// No description provided for @endTimeColon.
  ///
  /// In en, this message translates to:
  /// **'End time:'**
  String get endTimeColon;

  /// No description provided for @dateColon.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get dateColon;

  /// No description provided for @startColon.
  ///
  /// In en, this message translates to:
  /// **'Start:'**
  String get startColon;

  /// No description provided for @endColon.
  ///
  /// In en, this message translates to:
  /// **'End:'**
  String get endColon;

  /// No description provided for @symptomsColon.
  ///
  /// In en, this message translates to:
  /// **'Symptoms:'**
  String get symptomsColon;

  /// No description provided for @notesColon.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notesColon;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get grams;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @withoutDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get withoutDescription;

  /// No description provided for @editPeriodRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Period Record'**
  String get editPeriodRecord;

  /// No description provided for @menstrualTrackingInfo.
  ///
  /// In en, this message translates to:
  /// **'💡 Menstrual Tracking\nThe menstrual cycle can affect glucose levels. This record helps identify important patterns for your diabetes management.'**
  String get menstrualTrackingInfo;

  /// No description provided for @startDateRequired.
  ///
  /// In en, this message translates to:
  /// **'📅 Start date of period *'**
  String get startDateRequired;

  /// No description provided for @durationOptional.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Duration in days (optional)'**
  String get durationOptional;

  /// No description provided for @intensityRequired.
  ///
  /// In en, this message translates to:
  /// **'🩸 Intensity'**
  String get intensityRequired;

  /// No description provided for @symptomsSelect.
  ///
  /// In en, this message translates to:
  /// **'🤒 Symptoms (select those that apply)'**
  String get symptomsSelect;

  /// No description provided for @pain.
  ///
  /// In en, this message translates to:
  /// **'😣 Pain'**
  String get pain;

  /// No description provided for @swelling.
  ///
  /// In en, this message translates to:
  /// **'🤱 Swelling'**
  String get swelling;

  /// No description provided for @additionalNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'📝 Additional notes (optional)'**
  String get additionalNotesOptional;

  /// No description provided for @notesExample.
  ///
  /// In en, this message translates to:
  /// **'E.g.: More intense pain than usual, changes in appetite...'**
  String get notesExample;

  /// No description provided for @lightIntensity.
  ///
  /// In en, this message translates to:
  /// **'🩸 Light'**
  String get lightIntensity;

  /// No description provided for @normalIntensity.
  ///
  /// In en, this message translates to:
  /// **'🩸🩸 Normal'**
  String get normalIntensity;

  /// No description provided for @heavyIntensity.
  ///
  /// In en, this message translates to:
  /// **'🩸🩸🩸 Heavy'**
  String get heavyIntensity;

  /// No description provided for @registerPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Period'**
  String get registerPeriodTitle;

  /// No description provided for @cookiesBanner.
  ///
  /// In en, this message translates to:
  /// **'This app uses only technical and session cookies necessary for basic functionality and authentication. We do not collect or share data for advertising or tracking purposes. We do not use tracking cookies, nor do we use third party cookies. You can change your cookie preferences in your device settings.'**
  String get cookiesBanner;

  /// No description provided for @acceptCookies.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptCookies;

  /// No description provided for @rejectCookies.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectCookies;

  /// No description provided for @requiredFieldMessage.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredFieldMessage;

  /// No description provided for @selectStartTime.
  ///
  /// In en, this message translates to:
  /// **'Select start time'**
  String get selectStartTime;

  /// No description provided for @selectEndTime.
  ///
  /// In en, this message translates to:
  /// **'Select end time'**
  String get selectEndTime;

  /// No description provided for @exerciseRecordedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Exercise recorded successfully'**
  String get exerciseRecordedSuccessfully;

  /// No description provided for @selectStartAndEndTime.
  ///
  /// In en, this message translates to:
  /// **'Select start and end time'**
  String get selectStartAndEndTime;

  /// No description provided for @moodScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your day?'**
  String get moodScreenTitle;

  /// No description provided for @moodScreenQuestion.
  ///
  /// In en, this message translates to:
  /// **'How was your day?'**
  String get moodScreenQuestion;

  /// No description provided for @differentDate.
  ///
  /// In en, this message translates to:
  /// **'Different date'**
  String get differentDate;

  /// No description provided for @outOfRoutineQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did something take you out of your routine?'**
  String get outOfRoutineQuestion;

  /// No description provided for @routineDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe what happened'**
  String get routineDescriptionLabel;

  /// No description provided for @selectEmotions.
  ///
  /// In en, this message translates to:
  /// **'If you felt any of these emotions, mark them'**
  String get selectEmotions;

  /// No description provided for @otherEmotionLabel.
  ///
  /// In en, this message translates to:
  /// **'If you felt another emotion, write it down'**
  String get otherEmotionLabel;

  /// No description provided for @otherEmotionHint.
  ///
  /// In en, this message translates to:
  /// **'Write here...'**
  String get otherEmotionHint;

  /// No description provided for @anger.
  ///
  /// In en, this message translates to:
  /// **'Anger'**
  String get anger;

  /// No description provided for @anxiety.
  ///
  /// In en, this message translates to:
  /// **'Anxiety/Stress'**
  String get anxiety;

  /// No description provided for @fear.
  ///
  /// In en, this message translates to:
  /// **'Fear'**
  String get fear;

  /// No description provided for @joy.
  ///
  /// In en, this message translates to:
  /// **'Joy'**
  String get joy;

  /// No description provided for @surprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise'**
  String get surprise;

  /// No description provided for @sadness.
  ///
  /// In en, this message translates to:
  /// **'Sadness'**
  String get sadness;

  /// No description provided for @moodSaved.
  ///
  /// In en, this message translates to:
  /// **'Mood saved successfully!'**
  String get moodSaved;

  /// No description provided for @moodSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving mood.'**
  String get moodSaveError;

  /// No description provided for @moodValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Day value (0-10)'**
  String get moodValueLabel;

  /// No description provided for @emotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions (comma separated)'**
  String get emotions;

  /// No description provided for @otherEmotion.
  ///
  /// In en, this message translates to:
  /// **'Other emotion'**
  String get otherEmotion;

  /// No description provided for @editMoodStatus.
  ///
  /// In en, this message translates to:
  /// **'Edit mood'**
  String get editMoodStatus;

  /// No description provided for @readingBLE.
  ///
  /// In en, this message translates to:
  /// **'BLE Reading'**
  String get readingBLE;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyResponsible.
  ///
  /// In en, this message translates to:
  /// **'Data Controller: University of Las Palmas de Gran Canaria (ULPGC) and Canary Islands Health Research Institute Foundation (FIISC)'**
  String get privacyPolicyResponsible;

  /// No description provided for @privacyPolicyDataCollected.
  ///
  /// In en, this message translates to:
  /// **'What data do we collect and why?\n- Health data: records of insulin, food, exercise, mood, menstrual cycle, BLE device data (heart rate, etc.).\n- Usage data: device identifier, access logs, consent.\n- Profile data: sex, use of insulin pump.'**
  String get privacyPolicyDataCollected;

  /// No description provided for @privacyPolicyPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose:\n- Medical research and statistical analysis.\n- Development of personalized recommendations.\n- Improvement of user experience and security.'**
  String get privacyPolicyPurpose;

  /// No description provided for @privacyPolicyLegalBasis.
  ///
  /// In en, this message translates to:
  /// **'Legal basis for processing:\n- Explicit user consent, collected digitally in the app.\n- Public interest in scientific research (with institutional support).'**
  String get privacyPolicyLegalBasis;

  /// No description provided for @privacyPolicyAccess.
  ///
  /// In en, this message translates to:
  /// **'Who has access to your data?\n- Only the authorized research team of ULPGC and FIISC.\n- Technology providers (Vercel, Supabase) under DPA agreements and with servers in the EU or with equivalent guarantees.'**
  String get privacyPolicyAccess;

  /// No description provided for @privacyPolicyStorage.
  ///
  /// In en, this message translates to:
  /// **'Where is the data stored?\n- On Supabase and Vercel servers, with encryption in transit and at rest.\n- Data residency in the European Union is prioritized.'**
  String get privacyPolicyStorage;

  /// No description provided for @privacyPolicySecurity.
  ///
  /// In en, this message translates to:
  /// **'What security measures do we apply?\n- Encryption of data in transit and at rest.\n- Restricted access control.\n- Data minimization.\n- Access logging.'**
  String get privacyPolicySecurity;

  /// No description provided for @privacyPolicyRetention.
  ///
  /// In en, this message translates to:
  /// **'How long do we keep your data?\n- As long as the research lasts or until the user requests its deletion.'**
  String get privacyPolicyRetention;

  /// No description provided for @privacyPolicyRights.
  ///
  /// In en, this message translates to:
  /// **'How can you exercise your rights?\nYou can request at any time:\n- Access, rectification, or deletion of your data.\n- Withdraw your consent and delete all your data.\n- More information or complaints via the emails: gabriel.gil@ulpgc.es, javier.alayon@ulpgc.es or jpenate@fciisc.es\n- If you believe your rights have not been respected by our entity, you can file a complaint with the Spanish Data Protection Agency through one of the following means:\n   + Electronic headquarters: www.agpd.es\n   + Postal address: Spanish Data Protection Agency. C/ Jorge Juan, 6, 28001-Madrid\n   + By phone: 901 100 099 – 91 266 35 17\n   + Filing a complaint with the Spanish Data Protection Agency is free and does not require a lawyer or solicitor.'**
  String get privacyPolicyRights;

  /// No description provided for @privacyPolicyConsent.
  ///
  /// In en, this message translates to:
  /// **'How is consent managed?\n- Consent is collected digitally and the date and method of acceptance are stored.\n- You can revoke your consent from the app at any time.'**
  String get privacyPolicyConsent;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Close your current session and return to the login screen.'**
  String get logoutDescription;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
