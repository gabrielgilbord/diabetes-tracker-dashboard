// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Diabetes Tracker';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'LOGIN';

  @override
  String get register => 'Register';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get insulinRecord => 'Insulin Record';

  @override
  String get foodRecord => 'Food Record';

  @override
  String get exerciseRecord => 'Exercise Record';

  @override
  String get periodRecord => 'Period Record';

  @override
  String get viewRecords => 'View Records';

  @override
  String get logout => 'Logout';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String get deleteRecordConfirmation => 'Are you sure you want to delete this record of';

  @override
  String get deleteRecordWarning => 'This action cannot be undone.';

  @override
  String get deleteRecordSuccess => 'Record deleted successfully';

  @override
  String get deleteRecordError => 'Error deleting record';

  @override
  String get changePassword => 'Change Password';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get version => 'Version';

  @override
  String get time => 'Time';

  @override
  String get date => 'Date';

  @override
  String get notes => 'Notes';

  @override
  String get submit => 'Submit';

  @override
  String get confirmDelete => 'Are you sure you want to delete this record?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get close => 'Close';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordRequirements => 'Password must be at least 6 characters long';

  @override
  String get tryAgain => 'Please try again';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get loginTitle => 'Login';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameRequired => 'Please enter your username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get loginError => 'Incorrect username or password';

  @override
  String get gdprConsent => 'Privacy and Data Consent';

  @override
  String get gdprMessage => 'This app collects and processes your health data to provide diabetes tracking services. By continuing, you consent to the collection and processing of your data as described in our Privacy Policy.';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get revokeConsent => 'Revoke Consent';

  @override
  String get revokeConsentDesc => 'You can revoke your consent to participate in the research at any time. This will log you out and you will not be able to access the app until you give your consent again.';

  @override
  String get revokeConsentDialogTitle => 'Are you sure?';

  @override
  String get revokeConsentDialogContent => 'By revoking your consent, you will be logged out and will not be able to access the app until you give your consent again. Your data will remain in the system.';

  @override
  String get revokeConsentSuccess => 'Consent successfully revoked';

  @override
  String get revokeConsentError => 'Error revoking consent';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get deleteAllDataDesc => 'This action will delete all your insulin, food and exercise records. This action cannot be undone.';

  @override
  String get deleteAllDataDialogTitle => 'Delete all data';

  @override
  String get deleteAllDataDialogContent => 'Are you sure you want to delete all your data? This action cannot be undone.';

  @override
  String get deleteAllDataSuccess => 'All data deleted successfully';

  @override
  String get deleteAllDataError => 'Error deleting data';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectDuration => 'Select duration';

  @override
  String get selectIntensity => 'Select intensity';

  @override
  String get selectSymptoms => 'Select symptoms';

  @override
  String get additionalNotes => 'Additional notes (optional)';

  @override
  String get registerPeriod => 'Register Period';

  @override
  String get menstrualTracking => 'Menstrual Tracking\nThe menstrual cycle can affect glucose levels. This record helps identify important patterns for your diabetes management.';

  @override
  String get startDateLabel => 'Start date of period *';

  @override
  String get durationLabel => 'Duration in days (optional)';

  @override
  String get intensityLabel => 'Intensity';

  @override
  String get symptomsLabel => 'Symptoms';

  @override
  String get notesHint => 'E.g.: More intense pain than usual, changes in appetite...';

  @override
  String get periodRegistered => 'Period registered successfully';

  @override
  String get selectStartDate => 'Select the start date';

  @override
  String get noUserFound => 'User not found';

  @override
  String get loadDataError => 'Error loading data:';

  @override
  String noRecordsOfType(Object type) {
    return 'No $type records';
  }

  @override
  String get insulinType => 'Type';

  @override
  String get insulinDose => 'Dose';

  @override
  String get dateTime => 'Date and Time';

  @override
  String get foodType => 'Type';

  @override
  String get foodAmount => 'Amount';

  @override
  String get carbs => 'Carbohydrates';

  @override
  String get exerciseType => 'Type';

  @override
  String get exerciseIntensity => 'Intensity';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get description => 'Description';

  @override
  String get actions => 'Actions';

  @override
  String get periodStart => 'Start';

  @override
  String get periodDuration => 'Duration';

  @override
  String get periodIntensity => 'Intensity';

  @override
  String get periodSymptoms => 'Symptoms';

  @override
  String get periodNotes => 'Notes';

  @override
  String get select => 'Select';

  @override
  String get menstruation => 'Menstruation';

  @override
  String get cramps => 'Cramps';

  @override
  String get headache => 'Headache';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get moodChanges => 'Mood changes';

  @override
  String get foodCravings => 'Food cravings';

  @override
  String get periodInfo => 'Menstrual cycle can affect glucose levels. This record helps identify important patterns.';

  @override
  String get period => 'Period';

  @override
  String get mood => 'Mood';

  @override
  String get insulin => 'Insulin';

  @override
  String get food => 'Food';

  @override
  String get exercise => 'Exercise';

  @override
  String get noRecords => 'No records';

  @override
  String get selectLanguageTitle => 'Language / Idioma';

  @override
  String get medicalResearchConsentTitle => 'Informed Consent';

  @override
  String get medicalResearchConsentDesc => 'Your participation is voluntary and contributes to the advancement of diabetes research.';

  @override
  String get whatInfoCollected => 'What information do we collect?';

  @override
  String get anonymousMedicalData => 'Anonymous medical data: Glucose, insulin, exercise and food records';

  @override
  String get healthContext => 'Health context: Sleep quality, stress levels, daily activities';

  @override
  String get basicMedicalInfo => 'Basic medical info: Therapy type (BICI/MDI) and biological sex for specific calculations';

  @override
  String get infoUsage => 'What is this information used for?';

  @override
  String get medicalResearch => 'Medical research: Improve treatments and understanding of diabetes';

  @override
  String get statisticalAnalysis => 'Statistical analysis: Identify patterns and trends for general benefit';

  @override
  String get treatmentImprovement => 'Treatment improvement: Develop personalized recommendations';

  @override
  String get privacyAndRights => 'Your privacy and rights';

  @override
  String get anonymousData => 'Completely anonymous data: No personally identifying information is stored';

  @override
  String get revocableConsent => 'Revocable consent: You can withdraw your consent at any time from settings';

  @override
  String get gdprCompliance => 'GDPR compliance: All data is handled according to European regulations';

  @override
  String get dataQuestions => 'Questions about your data? For any questions about data handling or to request deletion, contact the research team through the project\'s official channels.';

  @override
  String get acceptResearch => 'I agree to participate in the research';

  @override
  String get acceptResearchSubtitle => 'By clicking \'I agree\', you confirm that you have read and understood the information about the use of your data for medical research in diabetes.';

  @override
  String get selectStartDateSnack => 'Select the start date';

  @override
  String get periodRegisteredSnack => 'Period registered successfully';

  @override
  String get insulinRegisteredSnack => 'Insulin registered successfully';

  @override
  String get selectDateTimeSnack => 'Select date and time';

  @override
  String get foodRegisteredSnack => 'Food registered successfully';

  @override
  String get exerciseRegisteredSnack => 'Exercise registered successfully';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get insulinFormTitle => 'Insulin Record';

  @override
  String get insulinTypeLabel => 'Insulin Type';

  @override
  String get insulinDoseLabel => 'Dose (IU)';

  @override
  String get insulinDateTimeLabel => 'Date and Time of Application';

  @override
  String get insulinRegistered => 'Insulin registered successfully';

  @override
  String get selectDateTime => 'Select date and time';

  @override
  String get foodFormTitle => 'Food Record';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get hypoglycemia => 'Hypoglycemia';

  @override
  String get foodTypeLabel => 'Food Type';

  @override
  String get lessThanUsual => 'Less than usual';

  @override
  String get sameAsUsual => 'Same as usual';

  @override
  String get moreThanUsual => 'More than usual';

  @override
  String get foodAmountLabel => 'Amount';

  @override
  String get carbsLabel => 'Carbohydrates (g)';

  @override
  String get foodDateTimeLabel => 'Date and Time of the meal';

  @override
  String get foodRegistered => 'Food registered successfully';

  @override
  String get selectDateTimeFood => 'Select date and time';

  @override
  String get exerciseFormTitle => 'Exercise Record';

  @override
  String get aerobic => 'Aerobic';

  @override
  String get strength => 'Strength';

  @override
  String get hit => 'HIT';

  @override
  String get exerciseTypeLabel => 'Exercise Type';

  @override
  String get intensity => 'Intensity';

  @override
  String get exerciseRegistered => 'Exercise registered successfully';

  @override
  String get selectStartEndTime => 'Select start and end time';

  @override
  String errorWithDetails(Object details) {
    return 'Error: $details';
  }

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get insulinSection => 'Insulin';

  @override
  String get foodSection => 'Food';

  @override
  String get exerciseSection => 'Exercise';

  @override
  String get periodSection => 'Period';

  @override
  String get type => 'Type';

  @override
  String get dose => 'Dose';

  @override
  String get amount => 'Amount';

  @override
  String get carbohydrates => 'Carbohydrates';

  @override
  String get start => 'Start';

  @override
  String get duration => 'Duration';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get editInsulinRecord => 'Edit Insulin Record';

  @override
  String get update => 'Update';

  @override
  String get recordUpdated => 'Record updated successfully';

  @override
  String get recordUpdateError => 'Error updating record';

  @override
  String get editFoodRecord => 'Edit Food Record';

  @override
  String get editExerciseRecord => 'Edit Exercise Record';

  @override
  String get startHour => 'Start Hour';

  @override
  String get endHour => 'End Hour';

  @override
  String get privacySettings => 'Privacy and Data';

  @override
  String get fastInsulin => 'Fast';

  @override
  String get slowInsulin => 'Slow';

  @override
  String get selectInsulinType => 'Select a type';

  @override
  String get enterDose => 'Enter dose';

  @override
  String get insulinTypeRequired => 'Select a type';

  @override
  String get doseRequired => 'Enter dose';

  @override
  String get dateTimeRequired => 'Select date and time';

  @override
  String get insulinSaved => 'Insulin registered successfully';

  @override
  String get foodSaved => 'Food registered successfully';

  @override
  String get exerciseSaved => 'Exercise registered successfully';

  @override
  String get periodSaved => 'Period registered successfully';

  @override
  String get loginErrorDevice => 'Incorrect username or password or unauthorized device';

  @override
  String get loginErrorGeneric => 'Login error';

  @override
  String get completeProfile => 'Complete your profile';

  @override
  String get whatIsYourSex => 'What is your sex?';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get selectSex => 'Select your sex';

  @override
  String get useInsulinPump => 'I use insulin pump';

  @override
  String get saveProfile => 'Save';

  @override
  String get pleaseSetNewPassword => 'Please set a new password for your account:';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get pleaseEnterPassword => 'Please enter a password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get changePasswordButton => 'Change Password';

  @override
  String get passwordChangeSuccess => 'Password changed successfully';

  @override
  String get passwordChangeError => 'Error changing password';

  @override
  String get informedConsent => 'Informed Consent';

  @override
  String get medicalResearchDiabetes => 'Diabetes Research • GDPR Compliance';

  @override
  String get medicalResearchParticipation => 'Your participation is voluntary and contributes to the advancement of diabetes research';

  @override
  String get whatInfoWeCollect => 'What information do we collect?';

  @override
  String get anonymousMedicalDataDesc => '✅ Anonymous medical data: Glucose, insulin, exercise and food records';

  @override
  String get healthContextDesc => '✅ Health context: Sleep quality, stress levels, daily activities';

  @override
  String get basicMedicalInfoDesc => '✅ Basic medical info: Therapy type (BICI/MDI) and biological sex for specific calculations';

  @override
  String get whatInfoUsedFor => 'What is this information used for?';

  @override
  String get medicalResearchDesc => '🔬 Medical research: Improve treatments and understanding of diabetes';

  @override
  String get statisticalAnalysisDesc => '📈 Statistical analysis: Identify patterns and trends for general benefit';

  @override
  String get treatmentImprovementDesc => '⚡ Treatment improvement: Develop personalized recommendations';

  @override
  String get privacyAndRightsTitle => 'Your privacy and rights';

  @override
  String get anonymousDataDesc => '🔒 Completely anonymous data: No personally identifying information is stored';

  @override
  String get revocableConsentDesc => '📝 Revocable consent: You can withdraw your consent at any time from settings';

  @override
  String get gdprComplianceDesc => '🌍 GDPR compliance: All data is handled according to European regulations';

  @override
  String get dataQuestionsDesc => '📧 Questions about your data? For any questions about data handling or to request deletion, contact the research team through the project\'s official channels.';

  @override
  String get acceptResearchParticipation => 'I agree to participate in the research';

  @override
  String get acceptAndContinue => 'Accept and Continue';

  @override
  String get consentSaveError => 'Error saving consent';

  @override
  String get viewRecordsTitle => 'View Records';

  @override
  String get controlDiabetesLikeBoss => 'Control your diabetes like a boss! 💪\nEvery record is a step towards a healthier life.';

  @override
  String get noDataToShow => 'No data to show';

  @override
  String get dataAnalysis => 'Data Analysis';

  @override
  String get dailyInsulinDose => 'Daily Insulin Dose';

  @override
  String get average => 'Average';

  @override
  String get units => 'units';

  @override
  String get averageCarbsByType => 'Average Carbohydrates by Type';

  @override
  String get noRecordsOfInsulin => 'No insulin records';

  @override
  String get noRecordsOfFood => 'No food records';

  @override
  String get noRecordsOfExercise => 'No exercise records';

  @override
  String get noRecordsOfPeriod => 'No period records';

  @override
  String get insulinTypeColon => 'Type:';

  @override
  String get doseColon => 'Dose:';

  @override
  String get dateTimeColon => 'Date and time:';

  @override
  String get foodTypeColon => 'Type:';

  @override
  String get quantityColon => 'Quantity:';

  @override
  String get carbsColon => 'Carbohydrates:';

  @override
  String get exerciseTypeColon => 'Type:';

  @override
  String get intensityColon => 'Intensity:';

  @override
  String get descriptionColon => 'Description:';

  @override
  String get startTimeColon => 'Start time:';

  @override
  String get endTimeColon => 'End time:';

  @override
  String get dateColon => 'Date:';

  @override
  String get startColon => 'Start:';

  @override
  String get endColon => 'End:';

  @override
  String get symptomsColon => 'Symptoms:';

  @override
  String get notesColon => 'Notes:';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get grams => 'g';

  @override
  String get days => 'Days';

  @override
  String get withoutDescription => 'No description';

  @override
  String get editPeriodRecord => 'Edit Period Record';

  @override
  String get menstrualTrackingInfo => '💡 Menstrual Tracking\nThe menstrual cycle can affect glucose levels. This record helps identify important patterns for your diabetes management.';

  @override
  String get startDateRequired => '📅 Start date of period *';

  @override
  String get durationOptional => '⏱️ Duration in days (optional)';

  @override
  String get intensityRequired => '🩸 Intensity';

  @override
  String get symptomsSelect => '🤒 Symptoms (select those that apply)';

  @override
  String get pain => '😣 Pain';

  @override
  String get swelling => '🤱 Swelling';

  @override
  String get additionalNotesOptional => '📝 Additional notes (optional)';

  @override
  String get notesExample => 'E.g.: More intense pain than usual, changes in appetite...';

  @override
  String get lightIntensity => '🩸 Light';

  @override
  String get normalIntensity => '🩸🩸 Normal';

  @override
  String get heavyIntensity => '🩸🩸🩸 Heavy';

  @override
  String get registerPeriodTitle => 'Register Period';

  @override
  String get cookiesBanner => 'This app uses only technical and session cookies necessary for basic functionality and authentication. We do not collect or share data for advertising or tracking purposes. We do not use tracking cookies, nor do we use third party cookies. You can change your cookie preferences in your device settings.';

  @override
  String get acceptCookies => 'Accept';

  @override
  String get rejectCookies => 'Reject';

  @override
  String get requiredFieldMessage => 'Required field';

  @override
  String get selectStartTime => 'Select start time';

  @override
  String get selectEndTime => 'Select end time';

  @override
  String get exerciseRecordedSuccessfully => 'Exercise recorded successfully';

  @override
  String get selectStartAndEndTime => 'Select start and end time';

  @override
  String get moodScreenTitle => 'How was your day?';

  @override
  String get moodScreenQuestion => 'How was your day?';

  @override
  String get differentDate => 'Different date';

  @override
  String get outOfRoutineQuestion => 'Did something take you out of your routine?';

  @override
  String get routineDescriptionLabel => 'Briefly describe what happened';

  @override
  String get selectEmotions => 'If you felt any of these emotions, mark them';

  @override
  String get otherEmotionLabel => 'If you felt another emotion, write it down';

  @override
  String get otherEmotionHint => 'Write here...';

  @override
  String get anger => 'Anger';

  @override
  String get anxiety => 'Anxiety/Stress';

  @override
  String get fear => 'Fear';

  @override
  String get joy => 'Joy';

  @override
  String get surprise => 'Surprise';

  @override
  String get sadness => 'Sadness';

  @override
  String get moodSaved => 'Mood saved successfully!';

  @override
  String get moodSaveError => 'Error saving mood.';

  @override
  String get moodValueLabel => 'Day value (0-10)';

  @override
  String get emotions => 'Emotions (comma separated)';

  @override
  String get otherEmotion => 'Other emotion';

  @override
  String get editMoodStatus => 'Edit mood';

  @override
  String get readingBLE => 'BLE Reading';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyResponsible => 'Data Controller: University of Las Palmas de Gran Canaria (ULPGC) and Canary Islands Health Research Institute Foundation (FIISC)';

  @override
  String get privacyPolicyDataCollected => 'What data do we collect and why?\n- Health data: records of insulin, food, exercise, mood, menstrual cycle, BLE device data (heart rate, etc.).\n- Usage data: device identifier, access logs, consent.\n- Profile data: sex, use of insulin pump.';

  @override
  String get privacyPolicyPurpose => 'Purpose:\n- Medical research and statistical analysis.\n- Development of personalized recommendations.\n- Improvement of user experience and security.';

  @override
  String get privacyPolicyLegalBasis => 'Legal basis for processing:\n- Explicit user consent, collected digitally in the app.\n- Public interest in scientific research (with institutional support).';

  @override
  String get privacyPolicyAccess => 'Who has access to your data?\n- Only the authorized research team of ULPGC and FIISC.\n- Technology providers (Vercel, Supabase) under DPA agreements and with servers in the EU or with equivalent guarantees.';

  @override
  String get privacyPolicyStorage => 'Where is the data stored?\n- On Supabase and Vercel servers, with encryption in transit and at rest.\n- Data residency in the European Union is prioritized.';

  @override
  String get privacyPolicySecurity => 'What security measures do we apply?\n- Encryption of data in transit and at rest.\n- Restricted access control.\n- Data minimization.\n- Access logging.';

  @override
  String get privacyPolicyRetention => 'How long do we keep your data?\n- As long as the research lasts or until the user requests its deletion.';

  @override
  String get privacyPolicyRights => 'How can you exercise your rights?\nYou can request at any time:\n- Access, rectification, or deletion of your data.\n- Withdraw your consent and delete all your data.\n- More information or complaints via the emails: gabriel.gil@ulpgc.es, javier.alayon@ulpgc.es or jpenate@fciisc.es\n- If you believe your rights have not been respected by our entity, you can file a complaint with the Spanish Data Protection Agency through one of the following means:\n   + Electronic headquarters: www.agpd.es\n   + Postal address: Spanish Data Protection Agency. C/ Jorge Juan, 6, 28001-Madrid\n   + By phone: 901 100 099 – 91 266 35 17\n   + Filing a complaint with the Spanish Data Protection Agency is free and does not require a lawyer or solicitor.';

  @override
  String get privacyPolicyConsent => 'How is consent managed?\n- Consent is collected digitally and the date and method of acceptance are stored.\n- You can revoke your consent from the app at any time.';

  @override
  String get logoutDescription => 'Close your current session and return to the login screen.';
}
