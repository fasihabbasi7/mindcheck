/// User-facing text. Keeping it here makes wording easy to review
/// and makes translation possible later.
///
/// Text wrapped in **double asterisks** is shown in bold by AccentHeadline.
class AppStrings {
  AppStrings._();

  static const String appName = 'MindCheck';
  static const String tagline = 'Understand yourself. Explore your personality.';

  // ---------- Onboarding ----------
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get started';

  static const String onboarding1Title =
      'Understand **yourself**, one question at a time';
  static const String onboarding1Body =
      'MindCheck guides you through calm, structured questionnaires that help '
      'you reflect on your personality, habits and emotions.';

  static const String onboarding2Title =
      'Eleven **assessments**, one quiet space';
  static const String onboarding2Body =
      'From the Big Five to self-compassion, burnout and mood, each '
      'assessment ends with a clear, personal report you can revisit anytime.';

  static const String onboarding3Title = 'Private by **design**';
  static const String onboarding3Body =
      'Before you begin, here is how MindCheck treats your answers.';
  static const String privacyPointDevice =
      'Your answers and results stay on this device.';
  static const String privacyPointAccount =
      'No account, no sign-up and no internet connection needed.';
  static const String privacyPointDiagnosis =
      'MindCheck is for self-reflection and education. It cannot diagnose any '
      'condition, including autism, ADHD, anxiety or personality disorders.';
  static const String privacyPointProfessional =
      'If something worries you, a qualified professional is the right person '
      'to talk to.';
  static const String disclaimerAgree =
      'I understand that MindCheck is not a medical or diagnostic tool.';

  // ---------- Home ----------
  static const String homeQuestion = 'How are you **feeling today**?';
  static const String statAssessmentsTitle = 'Assessments';
  static const String statAssessmentsCaption = 'Ready to explore';
  static const String statCompletedTitle = 'Completed';
  static const String statCompletedCaption = 'Saved on device';
  static const String todaysReflection = "Today's reflection";
  static const String writeReflection = 'Write a private answer';
  static const String editReflection = 'Answered today · tap to edit';
  static const String unfinishedLabel = 'Unfinished assessment';
  static const String journalHint = 'Write whatever comes to mind…';
  static const String journalPrivate =
      'Private. Saved only on this device and never shared.';
  static const String deleteEntry = 'Delete entry';
  static const String searchHint = 'Search assessments or traits';
  static const String exploreSection = 'Explore assessments';
  static const String seeAll = 'See all';
  static const String recentResults = 'Recent results';
  static const String noRecentTitle = 'No results yet';
  static const String noRecentBody =
      'Completed assessments will appear here, saved only on this device.';

  // ---------- Name ----------
  static const String nameQuestion = 'What should we call you?';
  static const String nameHint = 'First name (optional)';
  static const String nameHelper = 'Used only for your greeting. Stays on this device.';

  // ---------- Explore ----------
  static const String exploreTitle = 'Explore';
  static const String exploreSubtitle = 'assessments to help you reflect';
  static const String filterAll = 'All';
  static const String filterSaved = 'Saved';
  static const String noSavedTitle = 'No saved assessments yet';
  static const String noSavedBody =
      'Tap the bookmark on any assessment to save it here.';
  static const String bookmark = 'Save assessment';
  static const String removeBookmark = 'Remove from saved';
  static const String noMatchesTitle = 'No matching assessments';
  static const String noMatchesBody =
      'Try a different word, or clear the search and filters.';
  static const String clearFilters = 'Clear search';
  static const String exploreFootnote =
      'MindCheck is for self-reflection and education. '
      'It does not diagnose any condition.';

  // ---------- Assessment details ----------
  static const String back = 'Back';
  static const String aboutAssessment = 'About this assessment';
  static const String whatItExplores = 'What it explores';
  static const String howItWorks = 'How it works';
  static const String answers = 'Answers';
  static const String timeframe = 'Time period';
  static const String designedFor = 'Designed for';
  static const String youWillReceive = 'You will receive';
  static const String source = 'Source';
  static const String officialPage = 'Official questionnaire page:';
  static const String startAssessment = 'Start assessment';
  static const String detailsDisclaimer =
      'Your result describes your own answers at this moment. It is not a '
      'diagnosis. If any of these experiences are causing you distress, '
      'please consider talking with a qualified professional.';
  // ---------- Instructions ----------
  static const String beforeYouBegin = 'Before you begin';
  static const String begin = 'Begin';
  static const String continueWhereLeft = 'Continue where you left off';
  static const String startOver = 'Start over';
  static const String restartTitle = 'Start over?';
  static const String restartBody =
      'Your saved answers for this assessment will be deleted and you will '
      'begin again from the first question.';
  static const String tipFirstInstinct =
      'Go with your first instinct. There are no right or wrong answers.';
  static const String tipGoBack =
      'You can go back and change any answer before you submit.';
  static const String tipPrivate =
      'Your answers stay on this device and are never uploaded.';
  static const String loadErrorTitle = 'Could not load questions';
  static const String loadErrorBody =
      'Something went wrong while opening this assessment. Please try again.';

  // ---------- Questions ----------
  static const String previous = 'Back';
  static const String review = 'Review';
  static const String leave = 'Leave';
  static const String keepGoing = 'Keep going';
  static const String leaveTitle = 'Leave this assessment?';
  static const String leaveBody =
      'Save your progress to continue later, or discard your answers.';
  static const String saveAndExit = 'Save & exit';
  static const String discardAnswers = 'Discard';
  static const String autoNextShort = 'Auto';
  static const String autoNextLabel = 'Auto-next question';
  static const String autoNextDescription =
      'Move to the next question automatically after choosing an answer. '
      'When off, press Next to continue.';
  static const String autoNextTooltipOn = 'Auto-next is on. Tap to turn off.';
  static const String autoNextTooltipOff =
      'Auto-next is off. Tap to move on automatically after answering.';
  static const String autoNextOn =
      'Auto-next on: you will move on after choosing an answer.';
  static const String autoNextOff =
      'Auto-next off: press Next when you are ready.';
  static const String shadingNote =
      'Shaded answers follow the official ASRS v1.1 form.';
  static const String reviewReady = 'Ready to submit';
  static const String reviewAlmost = 'Almost there';
  static const String reviewUnanswered = 'Still to answer (tap to go there):';
  static const String reviewChangeHint =
      'You can close this and go back to change any answer first.';
  static const String submit = 'Submit answers';
  static const String keepReviewing = 'Keep reviewing';

  // ---------- Completion ----------
  static const String completeTitle = 'Assessment **complete**';
  static const String completeNote =
      'Thank you for taking time to reflect. Remember, your result describes '
      'your answers today, not who you are forever.';
  static const String viewResults = 'View my results';
  static const String backToHome = 'Back to home';
  static const String completeFallback =
      'Thank you for completing this assessment.';
  static const String scoringError =
      'Something went wrong while preparing your report. Please try again.';

  // ---------- Results ----------
  static const String yourReport = 'Your report';
  static const String done = 'Done';
  static const String naturalStrengths = 'Your natural strengths';
  static const String yourProfile = 'Your profile';
  static const String originalScoring = 'Original ASRS scoring';
  static const String thingsToKeepInMind = 'Things to keep in mind';
  static const String seeDetails = 'See detailed breakdown';
  static const String sharePdf = 'Share as PDF';
  static const String createPdf = 'Create PDF';
  static const String shareTitle = 'Share your report?';
  static const String shareBody =
      'The PDF contains your personal results. It is created on this device '
      'and only goes where you choose to send or save it.';
  static const String shareError =
      'The PDF could not be created. Please try again.';
  static const String detailedResults = 'Detailed results';
  static const String howScored = 'How your score was calculated';
  static const String howItShowsUp = 'How it may show up for you';
  static const String reflectOn = 'Reflect on';
  static const String tryThis = 'Try this';
  static const String resultDisclaimer =
      'This report describes your own answers at one moment in time. It is '
      'for self-reflection and education, and it is not a diagnosis. If '
      'anything here worries you, please talk with a qualified professional.';
  static const String resultNotFoundTitle = 'Report not available';
  static const String resultNotFoundBody =
      'This report could not be found. It may have been deleted.';
  static const String notFoundTitle = 'Assessment not found';
  static const String notFoundBody =
      'This assessment may have been removed or renamed.';

  /// One prompt is shown per day on the Home screen.
  static const List<String> reflectionPrompts = <String>[
    'What gave you energy today, and what drained it?',
    'When did you last feel completely like yourself?',
    'What is one thing you handled better than you expected recently?',
    'Which emotion has visited you most this week?',
    'What would you like to say no to more often?',
    'Who do you feel most at ease around, and why?',
    'What small habit would make tomorrow a little easier?',
    'What is something you are quietly proud of?',
    'When do you feel most focused during the day?',
    'What does "rest" truly look like for you?',
    'Which of your strengths do you rarely give yourself credit for?',
    'What worry could you set down, just for today?',
    'How do you usually react when plans suddenly change?',
    'What kind of conversation leaves you feeling understood?',
  ];

  // ---------- History ----------
  static const String historyTitle = 'History';
  static const String historySubtitle = 'Saved only on this device';
  static const String historyResults = 'Results';
  static const String historyJournal = 'Journal';
  static const String noResultsTitle = 'No results yet';
  static const String noResultsBody =
      'When you complete an assessment, your report is saved here on your '
      'device so you can revisit and compare it later.';
  static const String noJournalTitle = 'Your journal is empty';
  static const String noJournalBody =
      'Answer the daily reflection question to start a private journal.';
  static const String delete = 'Delete';
  static const String moreOptions = 'More options';
  static const String viewReport = 'View report';
  static const String deleteResultTitle = 'Delete this result?';
  static const String deleteEntryTitle = 'Delete this reflection?';

  // ---------- Comparison ----------
  static const String compareTitle = 'Compared with your last attempt';
  static const String compareTrend = 'Over time';
  static const String compareNote =
      'Changes show how your answers differ between attempts. They are not a '
      'measure of clinical improvement or decline.';
  static const String overallScore = 'Overall';

  // ---------- Tabs ----------
  static const String tabHome = 'Home';
  static const String tabAssessments = 'Explore';
  static const String tabHistory = 'History';
  static const String tabSettings = 'Settings';

  // ---------- Settings ----------
  static const String profile = 'Profile';
  static const String yourName = 'Your name';
  static const String nameNotSet = 'Not set';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String assessmentsSettings = 'Assessments';
  static const String appearance = 'Appearance';
  static const String themeSystem = 'System';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String replayOnboarding = 'View introduction again';
  static const String about = 'About';
  static const String privacyData = 'Privacy & data';
  static const String privacyTitle = 'Privacy information';
  static const String privacyIntro =
      'MindCheck was built to be private by design. Here is exactly how your '
      'information is handled.';
  static const String aboutTitle = 'About MindCheck & disclaimer';
  static const String aboutIntro =
      'Understand yourself. Explore your personality, gently and privately.';
  static const String deleteHistoryTitle = 'Delete assessment history';
  static const String deleteHistoryBody =
      'All saved results will be permanently deleted from this device. This '
      'cannot be undone.';
  static const String deleteJournalTitle = 'Delete journal';
  static const String deleteJournalBody =
      'All journal entries will be permanently deleted from this device. '
      'This cannot be undone.';
  static const String deleteAllTitle = 'Delete all my data';
  static const String deleteAllBody =
      'This permanently deletes your results, journal, unfinished '
      'assessments, bookmarks and name from this device. Your theme and '
      'app preferences are kept. This cannot be undone.';
  static const String deleteEverything = 'Delete everything';
  static const String historyDeleted = 'Assessment history deleted.';
  static const String journalDeleted = 'Journal deleted.';
  static const String allDeleted = 'All your data has been deleted.';
  static const String version = 'Version';

  // ---------- Safety support (PHQ-9 question 9) ----------
  static const String safetyTitle = "You don't have to face this alone";
  static const String safetyBody =
      'You said you have had thoughts of being better off dead or of hurting '
      'yourself. Please reach out today to someone you trust, a doctor, or a '
      'helpline. Talking can really help.';
  static const String safetyEmergency =
      'If you might act on these thoughts or are in danger right now, call '
      'your local emergency number or go to the nearest emergency '
      'department.';
  static const String safetyHelplinesTitle = 'Free, confidential support';
  static const String safetyHelplinePakistan =
      'Pakistan · Umang helpline (24/7): 0311 7786264';
  static const String safetyHelplineWorld =
      'Anywhere · Find a helpline near you: findahelpline.com';

  // ---------- Results reveal ----------
  static const String revealCelebration = 'Report ready';
}
