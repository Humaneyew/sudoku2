// GENERATED CODE - DO NOT MODIFY BY HAND.
// ignore_for_file: type=lint, unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale);

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ka'),
    Locale('ko'),
    Locale('ru'),
    Locale('uk'),
    Locale('zh'),
  ];

  static const List<String> _supportedLocaleNames = <String>[
    "de",
    "en",
    "es",
    "fr",
    "hi",
    "it",
    "ja",
    "ka",
    "ko",
    "ru",
    "uk",
    "zh",
  ];

  static bool _isSupported(Locale locale) {
    return _supportedLocaleNames.contains(locale.toString()) ||
        _supportedLocaleNames.contains(locale.languageCode);
  }

  String get appTitle;

  String get navHome;

  String get navDaily;

  String get navStats;

  String get dailyStreak;

  String get selectDifficultyTitle;

  String get selectDifficultyDailyChallenge;

  String get playAction;

  String get championshipTitle;

  String championshipScore(int score);

  String toNextPlace(int points);

  String get youAreTop;

  String get championshipRoundDescriptionPlaceholder;

  String get championshipRoundCompletedLabel;

  String totalScore(String score);

  String get meLabel;

  String leaderboardRow(int rank, String name, String points);

  String yourPosition(int rank, String points);

  String get pointsShort;

  String get championshipAutoScroll;

  String get bestLabel;

  String get play;

  String get battleTitle;

  String battleWinRate(int count);

  String get battleYouLabel;

  String get battleVictoryTitle;

  String get battleDefeatTitle;

  String battleDefeatMessage(String name);

  String get battleSimpleDefeatTitle;

  String get battleExitToMainMenu;

  String get playerFlagSettingTitle;

  String get selectPlayerFlag;

  String get confirmFlagSelectionTitle;

  String get confirmFlagSelectionMessage;

  String get confirmFlagSelectionConfirm;

  String get startAction;

  String levelHeading(int level, String difficulty);

  String get rankProgress;

  String rankLabel(int rank);

  String get newGame;

  String get continueGame;

  String get weeklyProgress;

  String get rewardsTitle;

  String get rewardNoMistakesTitle;

  String rewardExtraHearts(num count);

  String get rewardThreeInRowTitle;

  String get rewardUniqueTrophy;

  String get rewardSevenDayTitle;

  String rewardStars(num count);

  String get todayPuzzle;

  String get todayPuzzleDescription;

  String get continueAction;

  String get adMessage;

  String get adPlay;

  String get undo;

  String get erase;

  String get autoNotes;

  String get statusOn;

  String get statusOff;

  String get notes;

  String get hint;

  String get undoAdTitle;

  String get undoAdDescription;

  String undoAdCountdown(int seconds);

  String get hintAdTitle;

  String get hintAdDescription;

  String hintAdCountdown(int seconds);

  String get lifeAdTitle;

  String get lifeAdDescription;

  String lifeAdCountdown(int seconds);

  String get gameScreenTitle;

  String get noActiveGameMessage;

  String get victoryTitle;

  String victoryMessage(String time);

  String get backToHome;

  String get playAnother;

  String get outOfLivesTitle;

  String get outOfLivesDescription;

  String get restoreLifeAction;

  String get rewardAdUnavailable;

  String get cancelAction;

  String get settingsTitle;

  String get themeSectionTitle;

  String get themeWhite;

  String get themeCream;

  String get themeGreen;

  String get themeBlack;

  String get themePurple;

  String get themeFontSize;

  String get fontSizeExtraSmall;

  String get fontSizeSmall;

  String get fontSizeMedium;

  String get fontSizeLarge;

  String get fontSizeExtraLarge;

  String get languageSectionTitle;

  String get audioSectionTitle;

  String get soundsEffectsLabel;

  String get vibrationLabel;

  String get miscSectionTitle;

  String get howToPlayTitle;

  String get howToPlayRowRule;

  String get howToPlayColumnRule;

  String get howToPlayBoxRule;

  String get howToPlayFooter;

  String get howToPlayAction;

  String get championshipLocalSection;

  String get hideCompletedNumbersLabel;

  String get aboutApp;

  String versionLabel(String version);

  String get aboutLegalese;

  String get languageEnglish;

  String get languageRussian;

  String get languageUkrainian;

  String get languageGerman;

  String get languageFrench;

  String get languageChinese;

  String get languageHindi;

  String get languageGeorgian;

  String get languageSpanish;

  String get languageItalian;

  String get languageJapanese;

  String get languageKorean;

  String get export;

  String get import;

  String get resetMyScore;

  String get resetMyScoreConfirmation;

  String get resetAction;

  String get regenerateOpponents;

  String get confirm;

  String get cancel;

  String get done;

  String get privacyPolicyTitle;

  String get privacyPolicyAccept;

  String get privacyPolicyPrompt;

  String get privacyPolicyLearnMore;

  String get privacyPolicyDecline;

  String get privacyPolicyClose;

  String get privacyPolicyLoadError;

  String get failed;

  String rankBadgeChasing(int current, int delta, int target);

  String get statsTitle;

  String get statsGamesSection;

  String get statsGamesStarted;

  String get statsGamesWon;

  String get statsWinRate;

  String get statsFlawless;

  String get statsTimeSection;

  String get statsBestTime;

  String get statsAverageTime;

  String get statsStreakSection;

  String get statsCurrentStreak;

  String get statsBestStreak;

  String get difficultyNovice;

  String get difficultyNoviceShort;

  String get difficultyMedium;

  String get difficultyMediumShort;

  String get difficultyHigh;

  String get difficultyHighShort;

  String get difficultyExpert;

  String get difficultyExpertShort;

  String get difficultyMaster;

  String get difficultyMasterShort;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations._isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  if (!AppLocalizations._isSupported(locale)) {
    throw FlutterError(
        'AppLocalizations.delegate failed to load unsupported locale "' + locale.toString() + '".');
  }
  switch (locale.toString()) {
    case "de":
      return AppLocalizationsDe();
    case "en":
      return AppLocalizationsEn();
    case "es":
      return AppLocalizationsEs();
    case "fr":
      return AppLocalizationsFr();
    case "hi":
      return AppLocalizationsHi();
    case "it":
      return AppLocalizationsIt();
    case "ja":
      return AppLocalizationsJa();
    case "ka":
      return AppLocalizationsKa();
    case "ko":
      return AppLocalizationsKo();
    case "ru":
      return AppLocalizationsRu();
    case "uk":
      return AppLocalizationsUk();
    case "zh":
      return AppLocalizationsZh();
  }
  switch (locale.languageCode) {
    case "de":
      return AppLocalizationsDe();
    case "en":
      return AppLocalizationsEn();
    case "es":
      return AppLocalizationsEs();
    case "fr":
      return AppLocalizationsFr();
    case "hi":
      return AppLocalizationsHi();
    case "it":
      return AppLocalizationsIt();
    case "ja":
      return AppLocalizationsJa();
    case "ka":
      return AppLocalizationsKa();
    case "ko":
      return AppLocalizationsKo();
    case "ru":
      return AppLocalizationsRu();
    case "uk":
      return AppLocalizationsUk();
    case "zh":
      return AppLocalizationsZh();
  }
  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale ' + locale.toString() + ".");
}

class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe() : super("de");

  @override
  String get appTitle => "Sudoku Meister";

  @override
  String get navHome => "Startseite";

  @override
  String get navDaily => "Herausforderung";

  @override
  String get navStats => "Statistiken";

  @override
  String get dailyStreak => "Tagesserie";

  @override
  String get selectDifficultyTitle => "Schwierigkeitsgrad wählen";

  @override
  String get selectDifficultyDailyChallenge => "Tägliche Herausforderung";

  @override
  String get playAction => "Spielen";

  @override
  String get championshipTitle => "Meisterschaft";

  @override
  String championshipScore(int score) {
    return "Punktestand ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "Bis zum nächsten Platz: ${points} Pkt";
  }

  @override
  String get youAreTop => "Du bist Nr. 1";

  @override
  String get championshipRoundDescriptionPlaceholder => "Spiele diese Runde, um deinen Meisterschaftslauf zu stärken.";

  @override
  String get championshipRoundCompletedLabel => "Abgeschlossen";

  @override
  String totalScore(String score) {
    return "Gesamtpunktzahl: ${score}";
  }

  @override
  String get meLabel => "Ich";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "Platz ${rank}. ${name}. ${points} Punkte";
  }

  @override
  String yourPosition(int rank, String points) {
    return "Mein Platz ${rank}. ${points} Punkte";
  }

  @override
  String get pointsShort => "Pkt.";

  @override
  String get championshipAutoScroll => "Automatisch zu meiner Position scrollen";

  @override
  String get bestLabel => "Bestleistung";

  @override
  String get play => "Spielen";

  @override
  String get battleTitle => "Duell";

  @override
  String battleWinRate(int count) {
    return "Siege ${count}%";
  }

  @override
  String get battleYouLabel => "Du";

  @override
  String get battleVictoryTitle => "Du hast gewonnen!";

  @override
  String get battleDefeatTitle => "Der Gegner hat gewonnen";

  @override
  String battleDefeatMessage(String name) {
    return "${name} hat das Rätsel vor dir gelöst.";
  }

  @override
  String get battleSimpleDefeatTitle => "Du hast verloren";

  @override
  String get battleExitToMainMenu => "Zum Hauptmenü";

  @override
  String get playerFlagSettingTitle => "Spielerflagge";

  @override
  String get selectPlayerFlag => "Wähle deine Flagge";

  @override
  String get confirmFlagSelectionTitle => "Bestätige deine Flagge";

  @override
  String get confirmFlagSelectionMessage => "Bist du sicher, dass du diese Flagge auswählen möchtest? Du kannst deine Flagge später in den Spieleinstellungen ändern.";

  @override
  String get confirmFlagSelectionConfirm => "Bestätigen";

  @override
  String get startAction => "Starten";

  @override
  String levelHeading(int level, String difficulty) {
    return "Level ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "Rangfortschritt";

  @override
  String rankLabel(int rank) {
    return "Rang ${rank}";
  }

  @override
  String get newGame => "Neues Spiel";

  @override
  String get continueGame => "Spiel fortsetzen";

  @override
  String get weeklyProgress => "Wochenfortschritt";

  @override
  String get rewardsTitle => "Belohnungen";

  @override
  String get rewardNoMistakesTitle => "Schließe die Herausforderung ohne Fehler ab";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} Herz",
      other: "${count} Herzen",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "Schließe drei Herausforderungen in Folge ab";

  @override
  String get rewardUniqueTrophy => "Einzigartige Trophäe";

  @override
  String get rewardSevenDayTitle => "Halte eine Serie von 7 Tagen";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} Stern",
      other: "${count} Sterne",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "Heutiges Rätsel";

  @override
  String get todayPuzzleDescription => "Löse das Sudoku, um eine zusätzliche Belohnung zu erhalten und deine Serie fortzusetzen.";

  @override
  String get continueAction => "Weiter";

  @override
  String get adMessage => "Anzeige: Finde versteckte Objekte! Jetzt spielen.";

  @override
  String get adPlay => "Spielen";

  @override
  String get undo => "Rückgängig";

  @override
  String get erase => "Löschen";

  @override
  String get autoNotes => "Auto-Notizen";

  @override
  String get statusOn => "AN";

  @override
  String get statusOff => "AUS";

  @override
  String get notes => "Notizen";

  @override
  String get hint => "Tipp";

  @override
  String get undoAdTitle => "Werbung ansehen zum Rückgängig machen";

  @override
  String get undoAdDescription => "Sieh dir diese kurze Werbung an, um deinen letzten Zug rückgängig zu machen.";

  @override
  String undoAdCountdown(int seconds) {
    return "Werbung endet in ${seconds} s";
  }

  @override
  String get hintAdTitle => "Werbung ansehen, um einen Tipp zu erhalten";

  @override
  String get hintAdDescription => "Sieh dir diese kurze Werbung an, um einen Tipp zu erhalten.";

  @override
  String hintAdCountdown(int seconds) {
    return "Werbung endet in ${seconds} s";
  }

  @override
  String get lifeAdTitle => "Werbung ansehen, um ein Herz wiederherzustellen";

  @override
  String get lifeAdDescription => "Sieh dir diese kurze Werbung an, um ein rotes Herz wiederherzustellen und weiterzuspielen.";

  @override
  String lifeAdCountdown(int seconds) {
    return "Werbung endet in ${seconds} s";
  }

  @override
  String get gameScreenTitle => "Sudoku";

  @override
  String get noActiveGameMessage => "Kein aktives Spiel. Kehre zum Startbildschirm zurück.";

  @override
  String get victoryTitle => "Glückwunsch!";

  @override
  String victoryMessage(String time) {
    return "Rätsel gelöst in ${time}.";
  }

  @override
  String get backToHome => "Start";

  @override
  String get playAnother => "Noch eins";

  @override
  String get outOfLivesTitle => "Keine Herzen mehr";

  @override
  String get outOfLivesDescription => "Stelle ein rotes Herz wieder her, um weiterzuspielen.";

  @override
  String get restoreLifeAction => "Erhalte ein weiteres Herz (Werbung ansehen)";

  @override
  String get rewardAdUnavailable => "Anzeige ist derzeit nicht verfügbar.";

  @override
  String get cancelAction => "Abbrechen";

  @override
  String get settingsTitle => "Einstellungen";

  @override
  String get themeSectionTitle => "Design";

  @override
  String get themeWhite => "Klassisch hell";

  @override
  String get themeCream => "Creme";

  @override
  String get themeGreen => "Mint";

  @override
  String get themeBlack => "Dunkel";

  @override
  String get themePurple => "Dunkles Violett";

  @override
  String get themeFontSize => "Schriftgröße";

  @override
  String get fontSizeExtraSmall => "Sehr klein";

  @override
  String get fontSizeSmall => "Klein";

  @override
  String get fontSizeMedium => "Mittel";

  @override
  String get fontSizeLarge => "Groß";

  @override
  String get fontSizeExtraLarge => "Sehr groß";

  @override
  String get languageSectionTitle => "Sprache";

  @override
  String get audioSectionTitle => "Sound & Musik";

  @override
  String get soundsEffectsLabel => "Soundeffekte";

  @override
  String get vibrationLabel => "Vibration";

  @override
  String get miscSectionTitle => "Sonstiges";

  @override
  String get howToPlayTitle => "So spielst du";

  @override
  String get howToPlayRowRule => "In jeder Zeile stehen die Ziffern 1 bis 9 ohne Wiederholung";

  @override
  String get howToPlayColumnRule => "In jeder Spalte stehen die Ziffern 1 bis 9 ohne Wiederholung";

  @override
  String get howToPlayBoxRule => "In jedem 3×3-Block stehen die Ziffern 1 bis 9 ohne Wiederholung";

  @override
  String get howToPlayFooter => "Fülle alle Felder aus – und du gewinnst!";

  @override
  String get howToPlayAction => "Alles klar";

  @override
  String get championshipLocalSection => "Meisterschaft (lokal)";

  @override
  String get hideCompletedNumbersLabel => "Verwendete Ziffern ausblenden";

  @override
  String get aboutApp => "Über";

  @override
  String versionLabel(String version) {
    return "Version ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "Exportieren";

  @override
  String get import => "Importieren";

  @override
  String get resetMyScore => "Meinen Punktestand zurücksetzen";

  @override
  String get resetMyScoreConfirmation => "Sind Sie sicher, dass Sie den Punktestand zurücksetzen möchten? Diese Aktion kann nicht rückgängig gemacht werden.";

  @override
  String get resetAction => "Zurücksetzen";

  @override
  String get regenerateOpponents => "Gegner neu erstellen";

  @override
  String get confirm => "Bestätigen";

  @override
  String get cancel => "Abbrechen";

  @override
  String get done => "Fertig";

  @override
  String get privacyPolicyTitle => "Datenschutzerklärung";

  @override
  String get privacyPolicyAccept => "Ich stimme zu";

  @override
  String get privacyPolicyPrompt => "Akzeptieren Sie die Datenschutzerklärung?";

  @override
  String get privacyPolicyLearnMore => "Mehr erfahren →";

  @override
  String get privacyPolicyDecline => "Ich lehne ab";

  @override
  String get privacyPolicyClose => "Schließen";

  @override
  String get privacyPolicyLoadError => "Datenschutzerklärung konnte nicht geladen werden. Bitte versuche es erneut.";

  @override
  String get failed => "Fehlgeschlagen";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "Rang #${current} • +${delta} bis #${target}";
  }

  @override
  String get statsTitle => "Statistiken";

  @override
  String get statsGamesSection => "Spiele";

  @override
  String get statsGamesStarted => "Gestartete Spiele";

  @override
  String get statsGamesWon => "Gewonnene Spiele";

  @override
  String get statsWinRate => "Siegquote";

  @override
  String get statsFlawless => "Fehlerfreie Abschlüsse";

  @override
  String get statsTimeSection => "Zeit";

  @override
  String get statsBestTime => "Beste Zeit";

  @override
  String get statsAverageTime => "Durchschnittszeit";

  @override
  String get statsStreakSection => "Serie";

  @override
  String get statsCurrentStreak => "Aktuelle Serie";

  @override
  String get statsBestStreak => "Beste Serie";

  @override
  String get difficultyNovice => "Neuling";

  @override
  String get difficultyNoviceShort => "Neu.";

  @override
  String get difficultyMedium => "Mittel";

  @override
  String get difficultyMediumShort => "Mit.";

  @override
  String get difficultyHigh => "Schwer";

  @override
  String get difficultyHighShort => "Schw.";

  @override
  String get difficultyExpert => "Experte";

  @override
  String get difficultyExpertShort => "Exp.";

  @override
  String get difficultyMaster => "Meister";

  @override
  String get difficultyMasterShort => "Meis.";
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super("en");

  @override
  String get appTitle => "Sudoku Master";

  @override
  String get navHome => "Home";

  @override
  String get navDaily => "Challenge";

  @override
  String get navStats => "Statistics";

  @override
  String get dailyStreak => "Daily streak";

  @override
  String get selectDifficultyTitle => "Choose difficulty";

  @override
  String get selectDifficultyDailyChallenge => "Daily challenge";

  @override
  String get playAction => "Play";

  @override
  String get championshipTitle => "Championship";

  @override
  String championshipScore(int score) {
    return "Score ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "To next place: ${points} pts";
  }

  @override
  String get youAreTop => "You are #1";

  @override
  String get championshipRoundDescriptionPlaceholder => "Play this round to boost your championship run.";

  @override
  String get championshipRoundCompletedLabel => "Completed";

  @override
  String totalScore(String score) {
    return "Total score: ${score}";
  }

  @override
  String get meLabel => "Me";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "Place ${rank}. ${name}. ${points} points";
  }

  @override
  String yourPosition(int rank, String points) {
    return "My place ${rank}. ${points} points";
  }

  @override
  String get pointsShort => "pts";

  @override
  String get championshipAutoScroll => "Auto-scroll to my position";

  @override
  String get bestLabel => "Best";

  @override
  String get play => "Play";

  @override
  String get battleTitle => "Battle";

  @override
  String battleWinRate(int count) {
    return "Wins ${count}%";
  }

  @override
  String get battleYouLabel => "You";

  @override
  String get battleVictoryTitle => "You won!";

  @override
  String get battleDefeatTitle => "Opponent finished first";

  @override
  String battleDefeatMessage(String name) {
    return "${name} solved the puzzle before you.";
  }

  @override
  String get battleSimpleDefeatTitle => "You lost";

  @override
  String get battleExitToMainMenu => "Main menu";

  @override
  String get playerFlagSettingTitle => "Player flag";

  @override
  String get selectPlayerFlag => "Choose your flag";

  @override
  String get confirmFlagSelectionTitle => "Confirm your flag";

  @override
  String get confirmFlagSelectionMessage => "Are you sure you want to choose this flag? You can change your flag later in the game settings.";

  @override
  String get confirmFlagSelectionConfirm => "Confirm";

  @override
  String get startAction => "Start";

  @override
  String levelHeading(int level, String difficulty) {
    return "Level ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "Rank progress";

  @override
  String rankLabel(int rank) {
    return "Rank ${rank}";
  }

  @override
  String get newGame => "New game";

  @override
  String get continueGame => "Continue game";

  @override
  String get weeklyProgress => "Weekly progress";

  @override
  String get rewardsTitle => "Rewards";

  @override
  String get rewardNoMistakesTitle => "Finish the challenge without mistakes";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} heart",
      other: "${count} hearts",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "Complete three challenges in a row";

  @override
  String get rewardUniqueTrophy => "Unique trophy";

  @override
  String get rewardSevenDayTitle => "Maintain a 7-day streak";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} star",
      other: "${count} stars",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "Today's puzzle";

  @override
  String get todayPuzzleDescription => "Finish the sudoku to earn an extra reward and keep your streak alive.";

  @override
  String get continueAction => "Continue";

  @override
  String get adMessage => "Ad: Find hidden objects! Play now.";

  @override
  String get adPlay => "Play";

  @override
  String get undo => "Undo";

  @override
  String get erase => "Erase";

  @override
  String get autoNotes => "Auto notes";

  @override
  String get statusOn => "ON";

  @override
  String get statusOff => "OFF";

  @override
  String get notes => "Notes";

  @override
  String get hint => "Hint";

  @override
  String get undoAdTitle => "Watch ad to undo";

  @override
  String get undoAdDescription => "Watch this short ad to undo your last move.";

  @override
  String undoAdCountdown(int seconds) {
    return "Ad ends in ${seconds}s";
  }

  @override
  String get hintAdTitle => "Watch ad to get a hint";

  @override
  String get hintAdDescription => "Watch this short ad to earn a hint.";

  @override
  String hintAdCountdown(int seconds) {
    return "Ad ends in ${seconds}s";
  }

  @override
  String get lifeAdTitle => "Watch ad to restore a heart";

  @override
  String get lifeAdDescription => "Watch this short ad to restore a red heart and keep playing.";

  @override
  String lifeAdCountdown(int seconds) {
    return "Ad ends in ${seconds}s";
  }

  @override
  String get gameScreenTitle => "Sudoku";

  @override
  String get noActiveGameMessage => "No active game. Return to the home screen.";

  @override
  String get victoryTitle => "Congratulations!";

  @override
  String victoryMessage(String time) {
    return "Puzzle solved in ${time}.";
  }

  @override
  String get backToHome => "Home";

  @override
  String get playAnother => "Play again";

  @override
  String get outOfLivesTitle => "You're out of hearts";

  @override
  String get outOfLivesDescription => "Restore one red heart to keep playing.";

  @override
  String get restoreLifeAction => "Get one more heart (watch an ad)";

  @override
  String get rewardAdUnavailable => "Ad is not available right now.";

  @override
  String get cancelAction => "Cancel";

  @override
  String get settingsTitle => "Settings";

  @override
  String get themeSectionTitle => "Theme";

  @override
  String get themeWhite => "Classic Light";

  @override
  String get themeCream => "Cream";

  @override
  String get themeGreen => "Mint";

  @override
  String get themeBlack => "Dark";

  @override
  String get themePurple => "Purple Dark";

  @override
  String get themeFontSize => "Font size";

  @override
  String get fontSizeExtraSmall => "Extra small";

  @override
  String get fontSizeSmall => "Small";

  @override
  String get fontSizeMedium => "Medium";

  @override
  String get fontSizeLarge => "Large";

  @override
  String get fontSizeExtraLarge => "Extra large";

  @override
  String get languageSectionTitle => "Language";

  @override
  String get audioSectionTitle => "Sound & music";

  @override
  String get soundsEffectsLabel => "Sound effects";

  @override
  String get vibrationLabel => "Vibration";

  @override
  String get miscSectionTitle => "Other";

  @override
  String get howToPlayTitle => "How to play";

  @override
  String get howToPlayRowRule => "Each row has the digits 1 to 9 with no repeats";

  @override
  String get howToPlayColumnRule => "Each column has the digits 1 to 9 with no repeats";

  @override
  String get howToPlayBoxRule => "Each 3×3 box has the digits 1 to 9 with no repeats";

  @override
  String get howToPlayFooter => "Fill every cell and you win!";

  @override
  String get howToPlayAction => "Got it";

  @override
  String get championshipLocalSection => "Championship (local)";

  @override
  String get hideCompletedNumbersLabel => "Hide completed digits";

  @override
  String get aboutApp => "About";

  @override
  String versionLabel(String version) {
    return "Version ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "Export";

  @override
  String get import => "Import";

  @override
  String get resetMyScore => "Reset my score";

  @override
  String get resetMyScoreConfirmation => "Are you sure you want to reset the score? This action cannot be undone.";

  @override
  String get resetAction => "Reset";

  @override
  String get regenerateOpponents => "Regenerate opponents";

  @override
  String get confirm => "Confirm";

  @override
  String get cancel => "Cancel";

  @override
  String get done => "Done";

  @override
  String get privacyPolicyTitle => "Privacy Policy";

  @override
  String get privacyPolicyAccept => "I accept";

  @override
  String get privacyPolicyPrompt => "Do you accept the Privacy Policy?";

  @override
  String get privacyPolicyLearnMore => "Learn more →";

  @override
  String get privacyPolicyDecline => "I decline";

  @override
  String get privacyPolicyClose => "Close";

  @override
  String get privacyPolicyLoadError => "Failed to load privacy policy. Please try again.";

  @override
  String get failed => "Failed";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "Rank #${current} • +${delta} to #${target}";
  }

  @override
  String get statsTitle => "Statistics";

  @override
  String get statsGamesSection => "Games";

  @override
  String get statsGamesStarted => "Games started";

  @override
  String get statsGamesWon => "Games won";

  @override
  String get statsWinRate => "Win rate";

  @override
  String get statsFlawless => "Flawless finishes";

  @override
  String get statsTimeSection => "Time";

  @override
  String get statsBestTime => "Best time";

  @override
  String get statsAverageTime => "Average time";

  @override
  String get statsStreakSection => "Streak";

  @override
  String get statsCurrentStreak => "Current streak";

  @override
  String get statsBestStreak => "Best streak";

  @override
  String get difficultyNovice => "Novice";

  @override
  String get difficultyNoviceShort => "Nov.";

  @override
  String get difficultyMedium => "Intermediate";

  @override
  String get difficultyMediumShort => "Int.";

  @override
  String get difficultyHigh => "Advanced";

  @override
  String get difficultyHighShort => "Adv.";

  @override
  String get difficultyExpert => "Expert";

  @override
  String get difficultyExpertShort => "Exp.";

  @override
  String get difficultyMaster => "Master";

  @override
  String get difficultyMasterShort => "Mst.";
}

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs() : super("es");

  @override
  String get appTitle => "Sudoku Maestro";

  @override
  String get navHome => "Inicio";

  @override
  String get navDaily => "Desafío";

  @override
  String get navStats => "Estadísticas";

  @override
  String get dailyStreak => "Racha diaria";

  @override
  String get selectDifficultyTitle => "Elige la dificultad";

  @override
  String get selectDifficultyDailyChallenge => "Desafío diario";

  @override
  String get playAction => "Jugar";

  @override
  String get championshipTitle => "Campeonato";

  @override
  String championshipScore(int score) {
    return "Puntuación ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "Hasta el siguiente puesto: ${points} pts";
  }

  @override
  String get youAreTop => "Eres el nº 1";

  @override
  String get championshipRoundDescriptionPlaceholder => "Juega esta ronda para impulsar tu carrera en el campeonato.";

  @override
  String get championshipRoundCompletedLabel => "Terminado";

  @override
  String totalScore(String score) {
    return "Puntuación total: ${score}";
  }

  @override
  String get meLabel => "Yo";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "Puesto ${rank}. ${name}. ${points} puntos";
  }

  @override
  String yourPosition(int rank, String points) {
    return "Mi puesto ${rank}. ${points} puntos";
  }

  @override
  String get pointsShort => "pts";

  @override
  String get championshipAutoScroll => "Desplazamiento automático a mi posición";

  @override
  String get bestLabel => "Mejor";

  @override
  String get play => "Jugar";

  @override
  String get battleTitle => "Batalla";

  @override
  String battleWinRate(int count) {
    return "Victorias ${count}%";
  }

  @override
  String get battleYouLabel => "Tú";

  @override
  String get battleVictoryTitle => "¡Ganaste!";

  @override
  String get battleDefeatTitle => "El oponente ganó";

  @override
  String battleDefeatMessage(String name) {
    return "${name} completó el sudoku antes que tú.";
  }

  @override
  String get battleSimpleDefeatTitle => "Has perdido";

  @override
  String get battleExitToMainMenu => "Menú principal";

  @override
  String get playerFlagSettingTitle => "Bandera del jugador";

  @override
  String get selectPlayerFlag => "Elige tu bandera";

  @override
  String get confirmFlagSelectionTitle => "Confirma tu bandera";

  @override
  String get confirmFlagSelectionMessage => "¿Estás seguro de que quieres elegir esta bandera? Podrás cambiar tu bandera más adelante en los ajustes del juego.";

  @override
  String get confirmFlagSelectionConfirm => "Confirmar";

  @override
  String get startAction => "Comenzar";

  @override
  String levelHeading(int level, String difficulty) {
    return "Nivel ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "Rango de progreso";

  @override
  String rankLabel(int rank) {
    return "Rango ${rank}";
  }

  @override
  String get newGame => "Nuevo juego";

  @override
  String get continueGame => "Continuar el juego";

  @override
  String get weeklyProgress => "Progreso semanal";

  @override
  String get rewardsTitle => "Recompensas";

  @override
  String get rewardNoMistakesTitle => "Termina el desafío sin errores";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} corazón",
      other: "${count} corazones",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "Completar tres desafíos seguidos";

  @override
  String get rewardUniqueTrophy => "Trofeo único";

  @override
  String get rewardSevenDayTitle => "Mantener una racha de 7 días";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} estrella",
      other: "${count} estrellas",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "Rompecabezas de hoy";

  @override
  String get todayPuzzleDescription => "Termine el sudoku para ganar una recompensa adicional y mantener su racha viva.";

  @override
  String get continueAction => "Continuar";

  @override
  String get adMessage => "AD: ¡Encuentra objetos ocultos! Juega ahora.";

  @override
  String get adPlay => "Jugar";

  @override
  String get undo => "Deshacer";

  @override
  String get erase => "Borrar";

  @override
  String get autoNotes => "Notas automáticas";

  @override
  String get statusOn => "EN";

  @override
  String get statusOff => "APAGADO";

  @override
  String get notes => "Notas";

  @override
  String get hint => "Pista";

  @override
  String get undoAdTitle => "Mira el anuncio para deshacer";

  @override
  String get undoAdDescription => "Mire este breve anuncio para deshacer su último movimiento.";

  @override
  String undoAdCountdown(int seconds) {
    return "El anuncio termina en ${seconds} s";
  }

  @override
  String get hintAdTitle => "Mira el anuncio para obtener una pista";

  @override
  String get hintAdDescription => "Mire este breve anuncio para conseguir una pista.";

  @override
  String hintAdCountdown(int seconds) {
    return "El anuncio termina en ${seconds} s";
  }

  @override
  String get lifeAdTitle => "Mira el anuncio para restaurar un corazón";

  @override
  String get lifeAdDescription => "Mira este breve anuncio para restaurar un corazón rojo y seguir jugando.";

  @override
  String lifeAdCountdown(int seconds) {
    return "El anuncio termina en ${seconds} s";
  }

  @override
  String get gameScreenTitle => "Sudoku";

  @override
  String get noActiveGameMessage => "No hay juego activo. Regrese a la pantalla de inicio.";

  @override
  String get victoryTitle => "¡Felicidades!";

  @override
  String victoryMessage(String time) {
    return "Rompecabezas resuelto en ${time}.";
  }

  @override
  String get backToHome => "Hogar";

  @override
  String get playAnother => "Volver a jugar";

  @override
  String get outOfLivesTitle => "Estás fuera de corazón";

  @override
  String get outOfLivesDescription => "Restaurar un corazón rojo para seguir jugando.";

  @override
  String get restoreLifeAction => "Obtén un corazón más (ver anuncio)";

  @override
  String get rewardAdUnavailable => "El anuncio no está disponible en este momento.";

  @override
  String get cancelAction => "Cancelar";

  @override
  String get settingsTitle => "Ajustes";

  @override
  String get themeSectionTitle => "Tema";

  @override
  String get themeWhite => "Luz clásica";

  @override
  String get themeCream => "Crema";

  @override
  String get themeGreen => "Menta";

  @override
  String get themeBlack => "Oscuro";

  @override
  String get themePurple => "Morado oscuro";

  @override
  String get themeFontSize => "Tamaño de fuente";

  @override
  String get fontSizeExtraSmall => "Extra pequeño";

  @override
  String get fontSizeSmall => "Pequeño";

  @override
  String get fontSizeMedium => "Medio";

  @override
  String get fontSizeLarge => "Grande";

  @override
  String get fontSizeExtraLarge => "Extra grande";

  @override
  String get languageSectionTitle => "Idioma";

  @override
  String get audioSectionTitle => "Sonido y música";

  @override
  String get soundsEffectsLabel => "Efectos sonoros";

  @override
  String get vibrationLabel => "Vibración";

  @override
  String get miscSectionTitle => "Otro";

  @override
  String get howToPlayTitle => "Cómo jugar";

  @override
  String get howToPlayRowRule => "Cada fila tiene los números del 1 al 9 sin repetir";

  @override
  String get howToPlayColumnRule => "Cada columna tiene los números del 1 al 9 sin repetir";

  @override
  String get howToPlayBoxRule => "Cada cuadrado 3×3 tiene los números del 1 al 9 sin repetir";

  @override
  String get howToPlayFooter => "¡Rellena todas las casillas y gana!";

  @override
  String get howToPlayAction => "Entendido";

  @override
  String get championshipLocalSection => "Campeonato (local)";

  @override
  String get hideCompletedNumbersLabel => "Ocultar dígitos completos";

  @override
  String get aboutApp => "Acerca de";

  @override
  String versionLabel(String version) {
    return "Versión ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "Exportar";

  @override
  String get import => "Importar";

  @override
  String get resetMyScore => "Restablecer mi puntaje";

  @override
  String get resetMyScoreConfirmation => "¿Estás seguro de que quieres restablecer el puntaje? Esta acción no se puede deshacer.";

  @override
  String get resetAction => "Reiniciar";

  @override
  String get regenerateOpponents => "Regenerar oponentes";

  @override
  String get confirm => "Confirmar";

  @override
  String get cancel => "Cancelar";

  @override
  String get done => "Hecho";

  @override
  String get privacyPolicyTitle => "Política de privacidad";

  @override
  String get privacyPolicyAccept => "Acepto";

  @override
  String get privacyPolicyPrompt => "¿Aceptas la Política de privacidad?";

  @override
  String get privacyPolicyLearnMore => "Más información →";

  @override
  String get privacyPolicyDecline => "Rechazo";

  @override
  String get privacyPolicyClose => "Cerrar";

  @override
  String get privacyPolicyLoadError => "No se pudo cargar la política de privacidad. Inténtalo de nuevo.";

  @override
  String get failed => "Fallido";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "Rango #${current} • +${delta} hacia #${target}";
  }

  @override
  String get statsTitle => "Estadística";

  @override
  String get statsGamesSection => "Juegos";

  @override
  String get statsGamesStarted => "Comenzaron los juegos";

  @override
  String get statsGamesWon => "Juegos ganados";

  @override
  String get statsWinRate => "Tasa de ganancia";

  @override
  String get statsFlawless => "Acabados impecables";

  @override
  String get statsTimeSection => "Tiempo";

  @override
  String get statsBestTime => "Mejor tiempo";

  @override
  String get statsAverageTime => "Tiempo promedio";

  @override
  String get statsStreakSection => "Racha";

  @override
  String get statsCurrentStreak => "Racha actual";

  @override
  String get statsBestStreak => "Mejor racha";

  @override
  String get difficultyNovice => "Principiante";

  @override
  String get difficultyNoviceShort => "Nov.";

  @override
  String get difficultyMedium => "Intermedio";

  @override
  String get difficultyMediumShort => "Int.";

  @override
  String get difficultyHigh => "Avanzado";

  @override
  String get difficultyHighShort => "Adv.";

  @override
  String get difficultyExpert => "Experto";

  @override
  String get difficultyExpertShort => "Exp.";

  @override
  String get difficultyMaster => "Maestro";

  @override
  String get difficultyMasterShort => "MST.";
}

class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr() : super("fr");

  @override
  String get appTitle => "Sudoku Maître";

  @override
  String get navHome => "Accueil";

  @override
  String get navDaily => "Défi";

  @override
  String get navStats => "Statistiques";

  @override
  String get dailyStreak => "Série quotidienne";

  @override
  String get selectDifficultyTitle => "Choisissez la difficulté";

  @override
  String get selectDifficultyDailyChallenge => "Défi quotidien";

  @override
  String get playAction => "Jouer";

  @override
  String get championshipTitle => "Championnat";

  @override
  String championshipScore(int score) {
    return "Score ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "Jusqu'à la prochaine place : ${points} pts";
  }

  @override
  String get youAreTop => "Vous êtes n°1";

  @override
  String get championshipRoundDescriptionPlaceholder => "Jouez cette manche pour booster votre parcours au championnat.";

  @override
  String get championshipRoundCompletedLabel => "Terminé";

  @override
  String totalScore(String score) {
    return "Score total : ${score}";
  }

  @override
  String get meLabel => "Moi";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "Place ${rank}. ${name}. ${points} points";
  }

  @override
  String yourPosition(int rank, String points) {
    return "Ma place ${rank}. ${points} points";
  }

  @override
  String get pointsShort => "pts";

  @override
  String get championshipAutoScroll => "Défilement auto vers ma position";

  @override
  String get bestLabel => "Meilleur";

  @override
  String get play => "Jouer";

  @override
  String get battleTitle => "Duel";

  @override
  String battleWinRate(int count) {
    return "Victoires ${count}%";
  }

  @override
  String get battleYouLabel => "Toi";

  @override
  String get battleVictoryTitle => "Tu as gagné !";

  @override
  String get battleDefeatTitle => "L'adversaire a gagné";

  @override
  String battleDefeatMessage(String name) {
    return "${name} a résolu la grille avant toi.";
  }

  @override
  String get battleSimpleDefeatTitle => "Vous avez perdu";

  @override
  String get battleExitToMainMenu => "Menu principal";

  @override
  String get playerFlagSettingTitle => "Drapeau du joueur";

  @override
  String get selectPlayerFlag => "Choisis ton drapeau";

  @override
  String get confirmFlagSelectionTitle => "Confirme ton drapeau";

  @override
  String get confirmFlagSelectionMessage => "Es-tu sûr de vouloir choisir ce drapeau ? Tu pourras changer ton drapeau plus tard dans les paramètres du jeu.";

  @override
  String get confirmFlagSelectionConfirm => "Confirmer";

  @override
  String get startAction => "Commencer";

  @override
  String levelHeading(int level, String difficulty) {
    return "Niveau ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "Progression du rang";

  @override
  String rankLabel(int rank) {
    return "Rang ${rank}";
  }

  @override
  String get newGame => "Nouvelle partie";

  @override
  String get continueGame => "Continuer la partie";

  @override
  String get weeklyProgress => "Progression hebdomadaire";

  @override
  String get rewardsTitle => "Récompenses";

  @override
  String get rewardNoMistakesTitle => "Terminez le défi sans erreur";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} cœur",
      other: "${count} cœurs",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "Terminez trois défis d'affilée";

  @override
  String get rewardUniqueTrophy => "Trophée unique";

  @override
  String get rewardSevenDayTitle => "Maintenez une série de 7 jours";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} étoile",
      other: "${count} étoiles",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "Casse-tête du jour";

  @override
  String get todayPuzzleDescription => "Terminez le sudoku pour gagner une récompense supplémentaire et prolonger votre série.";

  @override
  String get continueAction => "Continuer";

  @override
  String get adMessage => "Annonce : Trouvez les objets cachés ! Jouez maintenant.";

  @override
  String get adPlay => "Jouer";

  @override
  String get undo => "Annuler";

  @override
  String get erase => "Effacer";

  @override
  String get autoNotes => "Notes auto";

  @override
  String get statusOn => "ACTIF";

  @override
  String get statusOff => "ARRÊT";

  @override
  String get notes => "Notes";

  @override
  String get hint => "Indice";

  @override
  String get undoAdTitle => "Voir une pub pour annuler";

  @override
  String get undoAdDescription => "Regardez cette courte publicité pour annuler votre dernier coup.";

  @override
  String undoAdCountdown(int seconds) {
    return "La pub se termine dans ${seconds} s";
  }

  @override
  String get hintAdTitle => "Voir une pub pour obtenir un indice";

  @override
  String get hintAdDescription => "Regardez cette courte publicité pour obtenir un indice.";

  @override
  String hintAdCountdown(int seconds) {
    return "La pub se termine dans ${seconds} s";
  }

  @override
  String get lifeAdTitle => "Voir une pub pour restaurer un cœur";

  @override
  String get lifeAdDescription => "Regardez cette courte publicité pour restaurer un cœur rouge et continuer à jouer.";

  @override
  String lifeAdCountdown(int seconds) {
    return "La pub se termine dans ${seconds} s";
  }

  @override
  String get gameScreenTitle => "Sudoku";

  @override
  String get noActiveGameMessage => "Aucune partie en cours. Revenez à l'écran d'accueil.";

  @override
  String get victoryTitle => "Félicitations !";

  @override
  String victoryMessage(String time) {
    return "Énigme résolue en ${time}.";
  }

  @override
  String get backToHome => "Accueil";

  @override
  String get playAnother => "Rejouer";

  @override
  String get outOfLivesTitle => "Plus de cœurs";

  @override
  String get outOfLivesDescription => "Restaurez un cœur rouge pour continuer.";

  @override
  String get restoreLifeAction => "Obtenir un cœur supplémentaire (regarder une pub)";

  @override
  String get rewardAdUnavailable => "La publicité n'est pas disponible pour le moment.";

  @override
  String get cancelAction => "Annuler";

  @override
  String get settingsTitle => "Paramètres";

  @override
  String get themeSectionTitle => "Thème";

  @override
  String get themeWhite => "Classique claire";

  @override
  String get themeCream => "Crème";

  @override
  String get themeGreen => "Menthe";

  @override
  String get themeBlack => "Sombre";

  @override
  String get themePurple => "Violette sombre";

  @override
  String get themeFontSize => "Taille de police";

  @override
  String get fontSizeExtraSmall => "Très petite";

  @override
  String get fontSizeSmall => "Petite";

  @override
  String get fontSizeMedium => "Moyenne";

  @override
  String get fontSizeLarge => "Grande";

  @override
  String get fontSizeExtraLarge => "Très grande";

  @override
  String get languageSectionTitle => "Langue";

  @override
  String get audioSectionTitle => "Son & musique";

  @override
  String get soundsEffectsLabel => "Effets sonores";

  @override
  String get vibrationLabel => "Vibration";

  @override
  String get miscSectionTitle => "Autre";

  @override
  String get howToPlayTitle => "Comment jouer";

  @override
  String get howToPlayRowRule => "Chaque ligne contient les chiffres de 1 à 9 sans doublons";

  @override
  String get howToPlayColumnRule => "Chaque colonne contient les chiffres de 1 à 9 sans doublons";

  @override
  String get howToPlayBoxRule => "Chaque carré 3×3 contient les chiffres de 1 à 9 sans doublons";

  @override
  String get howToPlayFooter => "Remplis toutes les cases et tu gagnes !";

  @override
  String get howToPlayAction => "Compris";

  @override
  String get championshipLocalSection => "Championnat (local)";

  @override
  String get hideCompletedNumbersLabel => "Masquer les chiffres utilisés";

  @override
  String get aboutApp => "À propos";

  @override
  String versionLabel(String version) {
    return "Version ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "Exporter";

  @override
  String get import => "Importer";

  @override
  String get resetMyScore => "Réinitialiser mon score";

  @override
  String get resetMyScoreConfirmation => "Voulez-vous vraiment réinitialiser le score ? Cette action est irréversible.";

  @override
  String get resetAction => "Réinitialiser";

  @override
  String get regenerateOpponents => "Régénérer les adversaires";

  @override
  String get confirm => "Confirmer";

  @override
  String get cancel => "Annuler";

  @override
  String get done => "Terminé";

  @override
  String get privacyPolicyTitle => "Politique de confidentialité";

  @override
  String get privacyPolicyAccept => "J'accepte";

  @override
  String get privacyPolicyPrompt => "Acceptez-vous la politique de confidentialité ?";

  @override
  String get privacyPolicyLearnMore => "En savoir plus →";

  @override
  String get privacyPolicyDecline => "Je refuse";

  @override
  String get privacyPolicyClose => "Fermer";

  @override
  String get privacyPolicyLoadError => "Impossible de charger la politique de confidentialité. Veuillez réessayer.";

  @override
  String get failed => "Échec";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "Rang #${current} • +${delta} vers #${target}";
  }

  @override
  String get statsTitle => "Statistiques";

  @override
  String get statsGamesSection => "Parties";

  @override
  String get statsGamesStarted => "Parties lancées";

  @override
  String get statsGamesWon => "Parties gagnées";

  @override
  String get statsWinRate => "Taux de victoire";

  @override
  String get statsFlawless => "Fin sans erreur";

  @override
  String get statsTimeSection => "Temps";

  @override
  String get statsBestTime => "Meilleur temps";

  @override
  String get statsAverageTime => "Temps moyen";

  @override
  String get statsStreakSection => "Série";

  @override
  String get statsCurrentStreak => "Série actuelle";

  @override
  String get statsBestStreak => "Meilleure série";

  @override
  String get difficultyNovice => "Novice";

  @override
  String get difficultyNoviceShort => "Nov.";

  @override
  String get difficultyMedium => "Intermédiaire";

  @override
  String get difficultyMediumShort => "Inter.";

  @override
  String get difficultyHigh => "Difficile";

  @override
  String get difficultyHighShort => "Diff.";

  @override
  String get difficultyExpert => "Expert";

  @override
  String get difficultyExpertShort => "Exp.";

  @override
  String get difficultyMaster => "Maître";

  @override
  String get difficultyMasterShort => "Maît.";
}

class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi() : super("hi");

  @override
  String get appTitle => "सुडोकू मास्टर";

  @override
  String get navHome => "होम";

  @override
  String get navDaily => "चुनौती";

  @override
  String get navStats => "आँकड़े";

  @override
  String get dailyStreak => "दैनिक श्रृंखला";

  @override
  String get selectDifficultyTitle => "कठिनाई चुनें";

  @override
  String get selectDifficultyDailyChallenge => "दैनिक चुनौती";

  @override
  String get playAction => "खेलें";

  @override
  String get championshipTitle => "चैम्पियनशिप";

  @override
  String championshipScore(int score) {
    return "स्कोर ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "अगले स्थान तक: ${points} अंक";
  }

  @override
  String get youAreTop => "आप नं. 1 हैं";

  @override
  String get championshipRoundDescriptionPlaceholder => "इस राउंड को खेलें और अपने चैम्पियनशिप सफर को आगे बढ़ाएँ।";

  @override
  String get championshipRoundCompletedLabel => "पूरा हुआ";

  @override
  String totalScore(String score) {
    return "कुल स्कोर: ${score}";
  }

  @override
  String get meLabel => "मैं";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "स्थान ${rank}. ${name}. ${points} अंक";
  }

  @override
  String yourPosition(int rank, String points) {
    return "मेरा स्थान ${rank}. ${points} अंक";
  }

  @override
  String get pointsShort => "अंक";

  @override
  String get championshipAutoScroll => "मेरी स्थिति तक स्वतः स्क्रॉल करें";

  @override
  String get bestLabel => "श्रेष्ठ";

  @override
  String get play => "खेलें";

  @override
  String get battleTitle => "बैटल";

  @override
  String battleWinRate(int count) {
    return "जीतें ${count}%";
  }

  @override
  String get battleYouLabel => "आप";

  @override
  String get battleVictoryTitle => "आप जीत गए!";

  @override
  String get battleDefeatTitle => "प्रतिद्वंदी जीत गया";

  @override
  String battleDefeatMessage(String name) {
    return "${name} ने आपसे पहले पहेली हल कर ली।";
  }

  @override
  String get battleSimpleDefeatTitle => "आप हार गए";

  @override
  String get battleExitToMainMenu => "मुख्य मेनू पर जाएं";

  @override
  String get playerFlagSettingTitle => "खिलाड़ी का झंडा";

  @override
  String get selectPlayerFlag => "अपना झंडा चुनें";

  @override
  String get confirmFlagSelectionTitle => "अपने झंडे की पुष्टि करें";

  @override
  String get confirmFlagSelectionMessage => "क्या आप सुनिश्चित हैं कि आप इस झंडे को चुनना चाहते हैं? आप बाद में खेल की सेटिंग्स में अपना झंडा बदल सकते हैं।";

  @override
  String get confirmFlagSelectionConfirm => "पुष्टि करें";

  @override
  String get startAction => "शुरू करें";

  @override
  String levelHeading(int level, String difficulty) {
    return "स्तर ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "रैंक प्रगति";

  @override
  String rankLabel(int rank) {
    return "रैंक ${rank}";
  }

  @override
  String get newGame => "नया खेल";

  @override
  String get continueGame => "खेल जारी रखें";

  @override
  String get weeklyProgress => "साप्ताहिक प्रगति";

  @override
  String get rewardsTitle => "इनाम";

  @override
  String get rewardNoMistakesTitle => "बिना गलती के चुनौती पूरी करें";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} दिल",
      other: "${count} दिल",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "लगातार तीन चुनौतियाँ पूरी करें";

  @override
  String get rewardUniqueTrophy => "विशेष ट्रॉफी";

  @override
  String get rewardSevenDayTitle => "7-दिन की श्रृंखला बनाए रखें";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} तारा",
      other: "${count} तारे",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "आज की पहेली";

  @override
  String get todayPuzzleDescription => "अतिरिक्त इनाम पाने और श्रृंखला बनाए रखने के लिए सुडोकू पूरा करें।";

  @override
  String get continueAction => "जारी रखें";

  @override
  String get adMessage => "विज्ञापन: छिपी वस्तुएँ खोजें! अभी खेलें।";

  @override
  String get adPlay => "खेलें";

  @override
  String get undo => "पूर्ववत् करें";

  @override
  String get erase => "मिटाएँ";

  @override
  String get autoNotes => "स्वचालित नोट्स";

  @override
  String get statusOn => "चालू";

  @override
  String get statusOff => "बंद";

  @override
  String get notes => "नोट्स";

  @override
  String get hint => "संकेत";

  @override
  String get undoAdTitle => "पूर्ववत करने के लिए विज्ञापन देखें";

  @override
  String get undoAdDescription => "अपनी पिछली चाल पूर्ववत करने के लिए यह छोटा विज्ञापन देखें।";

  @override
  String undoAdCountdown(int seconds) {
    return "विज्ञापन ${seconds} सेकंड में समाप्त होगा";
  }

  @override
  String get hintAdTitle => "संकेत पाने के लिए विज्ञापन देखें";

  @override
  String get hintAdDescription => "एक संकेत पाने के लिए यह छोटा विज्ञापन देखें।";

  @override
  String hintAdCountdown(int seconds) {
    return "विज्ञापन ${seconds} सेकंड में समाप्त होगा";
  }

  @override
  String get lifeAdTitle => "दिल बहाल करने के लिए विज्ञापन देखें";

  @override
  String get lifeAdDescription => "यह छोटा विज्ञापन देखें ताकि लाल दिल बहाल हो और खेल जारी रखें।";

  @override
  String lifeAdCountdown(int seconds) {
    return "विज्ञापन ${seconds} सेकंड में समाप्त होगा";
  }

  @override
  String get gameScreenTitle => "सुडोकू";

  @override
  String get noActiveGameMessage => "कोई सक्रिय खेल नहीं। होम स्क्रीन पर लौटें।";

  @override
  String get victoryTitle => "बधाई!";

  @override
  String victoryMessage(String time) {
    return "${time} में पहेली हल हुई।";
  }

  @override
  String get backToHome => "होम";

  @override
  String get playAnother => "फिर से खेलें";

  @override
  String get outOfLivesTitle => "दिल समाप्त";

  @override
  String get outOfLivesDescription => "खेल जारी रखने के लिए एक लाल दिल पुनर्स्थापित करें।";

  @override
  String get restoreLifeAction => "एक और दिल पाएं (विज्ञापन देखें)";

  @override
  String get rewardAdUnavailable => "विज्ञापन अभी उपलब्ध नहीं है।";

  @override
  String get cancelAction => "रद्द करें";

  @override
  String get settingsTitle => "सेटिंग्स";

  @override
  String get themeSectionTitle => "थीम";

  @override
  String get themeWhite => "क्लासिक हल्की";

  @override
  String get themeCream => "क्रीमी";

  @override
  String get themeGreen => "मिंट";

  @override
  String get themeBlack => "डार्क";

  @override
  String get themePurple => "गहरा बैंगनी";

  @override
  String get themeFontSize => "फ़ॉन्ट आकार";

  @override
  String get fontSizeExtraSmall => "अतिरिक्त छोटा";

  @override
  String get fontSizeSmall => "छोटा";

  @override
  String get fontSizeMedium => "मध्यम";

  @override
  String get fontSizeLarge => "बड़ा";

  @override
  String get fontSizeExtraLarge => "अतिरिक्त बड़ा";

  @override
  String get languageSectionTitle => "भाषा";

  @override
  String get audioSectionTitle => "ध्वनि और संगीत";

  @override
  String get soundsEffectsLabel => "ध्वनि प्रभाव";

  @override
  String get vibrationLabel => "कंपन";

  @override
  String get miscSectionTitle => "अन्य";

  @override
  String get howToPlayTitle => "कैसे खेलें";

  @override
  String get howToPlayRowRule => "हर पंक्ति में 1 से 9 तक अंक बिना दोहराव के होने चाहिए";

  @override
  String get howToPlayColumnRule => "हर स्तंभ में 1 से 9 तक अंक बिना दोहराव के होने चाहिए";

  @override
  String get howToPlayBoxRule => "हर 3×3 बॉक्स में 1 से 9 तक अंक बिना दोहराव के होने चाहिए";

  @override
  String get howToPlayFooter => "सभी खाने भरें और जीत जाएँ!";

  @override
  String get howToPlayAction => "ठीक है";

  @override
  String get championshipLocalSection => "चैम्पियनशिप (स्थानीय)";

  @override
  String get hideCompletedNumbersLabel => "प्रयुक्त अंकों को छुपाएँ";

  @override
  String get aboutApp => "ऐप के बारे में";

  @override
  String versionLabel(String version) {
    return "संस्करण ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "निर्यात";

  @override
  String get import => "आयात";

  @override
  String get resetMyScore => "मेरा स्कोर रीसेट करें";

  @override
  String get resetMyScoreConfirmation => "क्या आप वाकई स्कोर रीसेट करना चाहते हैं? यह कार्रवाई अपरिवर्तनीय है।";

  @override
  String get resetAction => "रीसेट करें";

  @override
  String get regenerateOpponents => "प्रतिद्वंद्वी पुनः उत्पन्न करें";

  @override
  String get confirm => "पुष्टि करें";

  @override
  String get cancel => "रद्द करें";

  @override
  String get done => "पूर्ण";

  @override
  String get privacyPolicyTitle => "गोपनीयता नीति";

  @override
  String get privacyPolicyAccept => "मैं सहमत हूँ";

  @override
  String get privacyPolicyPrompt => "क्या आप गोपनीयता नीति को स्वीकार करते हैं?";

  @override
  String get privacyPolicyLearnMore => "अधिक जानें →";

  @override
  String get privacyPolicyDecline => "मैं अस्वीकार करता हूँ";

  @override
  String get privacyPolicyClose => "बंद करें";

  @override
  String get privacyPolicyLoadError => "गोपनीयता नीति लोड नहीं हो सकी। कृपया दोबारा प्रयास करें।";

  @override
  String get failed => "असफल";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "रैंक #${current} • +${delta} से #${target}";
  }

  @override
  String get statsTitle => "आँकड़े";

  @override
  String get statsGamesSection => "खेल";

  @override
  String get statsGamesStarted => "शुरू किए गए खेल";

  @override
  String get statsGamesWon => "जीते गए खेल";

  @override
  String get statsWinRate => "जीत दर";

  @override
  String get statsFlawless => "बिना गलती की जीतें";

  @override
  String get statsTimeSection => "समय";

  @override
  String get statsBestTime => "सर्वश्रेष्ठ समय";

  @override
  String get statsAverageTime => "औसत समय";

  @override
  String get statsStreakSection => "श्रृंखला";

  @override
  String get statsCurrentStreak => "वर्तमान श्रृंखला";

  @override
  String get statsBestStreak => "सर्वश्रेष्ठ श्रृंखला";

  @override
  String get difficultyNovice => "नवागंतुक";

  @override
  String get difficultyNoviceShort => "नवा.";

  @override
  String get difficultyMedium => "मध्यम";

  @override
  String get difficultyMediumShort => "मध्.";

  @override
  String get difficultyHigh => "कठिन";

  @override
  String get difficultyHighShort => "कठि.";

  @override
  String get difficultyExpert => "विशेषज्ञ";

  @override
  String get difficultyExpertShort => "विशे.";

  @override
  String get difficultyMaster => "मास्टर";

  @override
  String get difficultyMasterShort => "मास्.";
}

class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt() : super("it");

  @override
  String get appTitle => "Maestro di Sudoku";

  @override
  String get navHome => "Home";

  @override
  String get navDaily => "Sfida";

  @override
  String get navStats => "Statistiche";

  @override
  String get dailyStreak => "Serie giornaliera";

  @override
  String get selectDifficultyTitle => "Scegli la difficoltà";

  @override
  String get selectDifficultyDailyChallenge => "Sfida quotidiana";

  @override
  String get playAction => "Gioca";

  @override
  String get championshipTitle => "Campionato";

  @override
  String championshipScore(int score) {
    return "Punteggio ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "Fino al prossimo posto: ${points} punti";
  }

  @override
  String get youAreTop => "Sei il nº 1";

  @override
  String get championshipRoundDescriptionPlaceholder => "Gioca questo round per dare slancio alla tua corsa nel campionato.";

  @override
  String get championshipRoundCompletedLabel => "Completato";

  @override
  String totalScore(String score) {
    return "Punteggio totale: ${score}";
  }

  @override
  String get meLabel => "Io";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "Posizione ${rank}. ${name}. ${points} punti";
  }

  @override
  String yourPosition(int rank, String points) {
    return "La mia posizione ${rank}. ${points} punti";
  }

  @override
  String get pointsShort => "PT";

  @override
  String get championshipAutoScroll => "Scrollare automatico alla mia posizione";

  @override
  String get bestLabel => "Migliore";

  @override
  String get play => "Giocare";

  @override
  String get battleTitle => "Battaglia";

  @override
  String battleWinRate(int count) {
    return "Vittorie ${count}%";
  }

  @override
  String get battleYouLabel => "Tu";

  @override
  String get battleVictoryTitle => "Hai vinto!";

  @override
  String get battleDefeatTitle => "L'avversario ha vinto";

  @override
  String battleDefeatMessage(String name) {
    return "${name} ha risolto il sudoku prima di te.";
  }

  @override
  String get battleSimpleDefeatTitle => "Hai perso";

  @override
  String get battleExitToMainMenu => "Menu principale";

  @override
  String get playerFlagSettingTitle => "Bandiera del giocatore";

  @override
  String get selectPlayerFlag => "Scegli la tua bandiera";

  @override
  String get confirmFlagSelectionTitle => "Conferma la tua bandiera";

  @override
  String get confirmFlagSelectionMessage => "Sei sicuro di voler scegliere questa bandiera? Potrai cambiare la tua bandiera più tardi nelle impostazioni del gioco.";

  @override
  String get confirmFlagSelectionConfirm => "Conferma";

  @override
  String get startAction => "Inizio";

  @override
  String levelHeading(int level, String difficulty) {
    return "Livello ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "Progresso di rango";

  @override
  String rankLabel(int rank) {
    return "Classifica ${rank}";
  }

  @override
  String get newGame => "Nuovo gioco";

  @override
  String get continueGame => "Continua il gioco";

  @override
  String get weeklyProgress => "Progressi settimanali";

  @override
  String get rewardsTitle => "Premi";

  @override
  String get rewardNoMistakesTitle => "Finire la sfida senza errori";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} cuore",
      other: "${count} cuori",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "Completa tre sfide di seguito";

  @override
  String get rewardUniqueTrophy => "Trofeo unico";

  @override
  String get rewardSevenDayTitle => "Mantenere una serie di 7 giorni";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} stella",
      other: "${count} stelle",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "Il puzzle di oggi";

  @override
  String get todayPuzzleDescription => "Termina il Sudoku per guadagnare una ricompensa extra e mantenere viva la tua serie.";

  @override
  String get continueAction => "Continuare";

  @override
  String get adMessage => "AD: Trova oggetti nascosti! Gioca adesso.";

  @override
  String get adPlay => "Giocare";

  @override
  String get undo => "Disfare";

  @override
  String get erase => "Cancellare";

  @override
  String get autoNotes => "Note automatiche";

  @override
  String get statusOn => "SU";

  @override
  String get statusOff => "SPENTO";

  @override
  String get notes => "Note";

  @override
  String get hint => "Suggerimento";

  @override
  String get undoAdTitle => "Guarda l'annuncio per annullare";

  @override
  String get undoAdDescription => "Guarda questo breve annuncio per annullare la tua ultima mossa.";

  @override
  String undoAdCountdown(int seconds) {
    return "L'annuncio termina tra ${seconds} s";
  }

  @override
  String get hintAdTitle => "Guarda l'annuncio per ottenere un suggerimento";

  @override
  String get hintAdDescription => "Guarda questo breve annuncio per ottenere un suggerimento.";

  @override
  String hintAdCountdown(int seconds) {
    return "L'annuncio termina tra ${seconds} s";
  }

  @override
  String get lifeAdTitle => "Guarda l'annuncio per ripristinare un cuore";

  @override
  String get lifeAdDescription => "Guarda questo breve annuncio per ripristinare un cuore rosso e continuare a giocare.";

  @override
  String lifeAdCountdown(int seconds) {
    return "L'annuncio termina tra ${seconds} s";
  }

  @override
  String get gameScreenTitle => "Sudoku";

  @override
  String get noActiveGameMessage => "Nessun gioco attivo. Torna alla schermata principale.";

  @override
  String get victoryTitle => "Congratulazioni!";

  @override
  String victoryMessage(String time) {
    return "Schema risolto in ${time}.";
  }

  @override
  String get backToHome => "Casa";

  @override
  String get playAnother => "Gioca di nuovo";

  @override
  String get outOfLivesTitle => "Sei fuori dal cuore";

  @override
  String get outOfLivesDescription => "Ripristina un cuore rosso per continuare a giocare.";

  @override
  String get restoreLifeAction => "Ottieni un altro cuore (guarda un annuncio)";

  @override
  String get rewardAdUnavailable => "L'annuncio non è al momento disponibile.";

  @override
  String get cancelAction => "Cancellare";

  @override
  String get settingsTitle => "Impostazioni";

  @override
  String get themeSectionTitle => "Tema";

  @override
  String get themeWhite => "Luce classica";

  @override
  String get themeCream => "Crema";

  @override
  String get themeGreen => "Menta";

  @override
  String get themeBlack => "Buio";

  @override
  String get themePurple => "Viola scuro";

  @override
  String get themeFontSize => "Dimensione del carattere";

  @override
  String get fontSizeExtraSmall => "Extra piccolo";

  @override
  String get fontSizeSmall => "Piccolo";

  @override
  String get fontSizeMedium => "Medio";

  @override
  String get fontSizeLarge => "Grande";

  @override
  String get fontSizeExtraLarge => "Extra grande";

  @override
  String get languageSectionTitle => "Lingua";

  @override
  String get audioSectionTitle => "Suono e musica";

  @override
  String get soundsEffectsLabel => "Effetti sonori";

  @override
  String get vibrationLabel => "Vibrazione";

  @override
  String get miscSectionTitle => "Altro";

  @override
  String get howToPlayTitle => "Come si gioca";

  @override
  String get howToPlayRowRule => "Ogni riga contiene i numeri da 1 a 9 senza ripetizioni";

  @override
  String get howToPlayColumnRule => "Ogni colonna contiene i numeri da 1 a 9 senza ripetizioni";

  @override
  String get howToPlayBoxRule => "Ogni riquadro 3×3 contiene i numeri da 1 a 9 senza ripetizioni";

  @override
  String get howToPlayFooter => "Riempi tutte le caselle e vinci!";

  @override
  String get howToPlayAction => "Ho capito";

  @override
  String get championshipLocalSection => "Campionato (locale)";

  @override
  String get hideCompletedNumbersLabel => "Nascondere le cifre completate";

  @override
  String get aboutApp => "Di";

  @override
  String versionLabel(String version) {
    return "Versione ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "Esportare";

  @override
  String get import => "Importare";

  @override
  String get resetMyScore => "Ripristina il mio punteggio";

  @override
  String get resetMyScoreConfirmation => "Sei sicuro di voler ripristinare il punteggio? Questa azione non può essere annullata.";

  @override
  String get resetAction => "Reset";

  @override
  String get regenerateOpponents => "Rigenerare gli avversari";

  @override
  String get confirm => "Confermare";

  @override
  String get cancel => "Cancellare";

  @override
  String get done => "Fatto";

  @override
  String get privacyPolicyTitle => "Informativa sulla privacy";

  @override
  String get privacyPolicyAccept => "Accetto";

  @override
  String get privacyPolicyPrompt => "Accetti l'informativa sulla privacy?";

  @override
  String get privacyPolicyLearnMore => "Ulteriori informazioni →";

  @override
  String get privacyPolicyDecline => "Rifiuto";

  @override
  String get privacyPolicyClose => "Chiudi";

  @override
  String get privacyPolicyLoadError => "Impossibile caricare l'informativa sulla privacy. Riprova.";

  @override
  String get failed => "Fallito";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "Classifica #${current} • +${delta} fino a #${target}";
  }

  @override
  String get statsTitle => "Statistiche";

  @override
  String get statsGamesSection => "Giochi";

  @override
  String get statsGamesStarted => "I giochi sono iniziati";

  @override
  String get statsGamesWon => "Giochi vinti";

  @override
  String get statsWinRate => "Tasso di vittoria";

  @override
  String get statsFlawless => "Finiture impeccabili";

  @override
  String get statsTimeSection => "Tempo";

  @override
  String get statsBestTime => "MIGLIORE MIGLIORE";

  @override
  String get statsAverageTime => "Tempo medio";

  @override
  String get statsStreakSection => "Strisciante";

  @override
  String get statsCurrentStreak => "Striscia attuale";

  @override
  String get statsBestStreak => "Migliore striscia";

  @override
  String get difficultyNovice => "Novizio";

  @override
  String get difficultyNoviceShort => "Novembre";

  @override
  String get difficultyMedium => "Intermedio";

  @override
  String get difficultyMediumShort => "Int.";

  @override
  String get difficultyHigh => "Avanzato";

  @override
  String get difficultyHighShort => "Adv.";

  @override
  String get difficultyExpert => "Esperto";

  @override
  String get difficultyExpertShort => "Exp.";

  @override
  String get difficultyMaster => "Maestro";

  @override
  String get difficultyMasterShort => "MST.";
}

class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa() : super("ja");

  @override
  String get appTitle => "数独マスター";

  @override
  String get navHome => "ホーム";

  @override
  String get navDaily => "チャレンジ";

  @override
  String get navStats => "統計";

  @override
  String get dailyStreak => "連続日数";

  @override
  String get selectDifficultyTitle => "難易度を選択";

  @override
  String get selectDifficultyDailyChallenge => "デイリーチャレンジ";

  @override
  String get playAction => "プレイ";

  @override
  String get championshipTitle => "チャンピオンシップ";

  @override
  String championshipScore(int score) {
    return "スコア ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "次の順位まで: ${points} pts";
  }

  @override
  String get youAreTop => "あなたは第1位です";

  @override
  String get championshipRoundDescriptionPlaceholder => "このラウンドをプレイしてチャンピオンシップの戦いを加速させましょう。";

  @override
  String get championshipRoundCompletedLabel => "完了しました";

  @override
  String totalScore(String score) {
    return "合計スコア: ${score}";
  }

  @override
  String get meLabel => "自分";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "順位 ${rank}。${name}。${points} ポイント";
  }

  @override
  String yourPosition(int rank, String points) {
    return "自分の順位 ${rank}。${points} ポイント";
  }

  @override
  String get pointsShort => "PTS";

  @override
  String get championshipAutoScroll => "私の立場に自動スクロールします";

  @override
  String get bestLabel => "最高";

  @override
  String get play => "遊ぶ";

  @override
  String get battleTitle => "戦い";

  @override
  String battleWinRate(int count) {
    return "勝利 ${count}%";
  }

  @override
  String get battleYouLabel => "あなた";

  @override
  String get battleVictoryTitle => "あなたの勝ち！";

  @override
  String get battleDefeatTitle => "相手が先にクリア";

  @override
  String battleDefeatMessage(String name) {
    return "${name} があなたより先に数独を解きました。";
  }

  @override
  String get battleSimpleDefeatTitle => "あなたは負けました";

  @override
  String get battleExitToMainMenu => "メインメニューに戻る";

  @override
  String get playerFlagSettingTitle => "プレイヤーの旗";

  @override
  String get selectPlayerFlag => "自分の旗を選択";

  @override
  String get confirmFlagSelectionTitle => "フラグを確認";

  @override
  String get confirmFlagSelectionMessage => "この旗を選択してもよろしいですか？後でゲーム設定で旗を変更できます。";

  @override
  String get confirmFlagSelectionConfirm => "確認する";

  @override
  String get startAction => "始める";

  @override
  String levelHeading(int level, String difficulty) {
    return "レベル ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "ランクの進捗";

  @override
  String rankLabel(int rank) {
    return "ランク ${rank}";
  }

  @override
  String get newGame => "新しいゲーム";

  @override
  String get continueGame => "ゲームを続けます";

  @override
  String get weeklyProgress => "毎週の進歩";

  @override
  String get rewardsTitle => "報酬";

  @override
  String get rewardNoMistakesTitle => "間違いなくチャレンジを終了します";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} ハート",
      other: "${count} ハート",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "連続して3つの課題を完了します";

  @override
  String get rewardUniqueTrophy => "ユニークなトロフィー";

  @override
  String get rewardSevenDayTitle => "7日間の連勝を維持します";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} スター",
      other: "${count} スター",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "今日のパズル";

  @override
  String get todayPuzzleDescription => "数独を終えて、余分な報酬を獲得し、連勝を生かし続けます。";

  @override
  String get continueAction => "続く";

  @override
  String get adMessage => "AD：隠されたオブジェクトを見つけてください！今すぐ遊んでください。";

  @override
  String get adPlay => "遊ぶ";

  @override
  String get undo => "元に戻します";

  @override
  String get erase => "消去します";

  @override
  String get autoNotes => "オートノート";

  @override
  String get statusOn => "の上";

  @override
  String get statusOff => "オフ";

  @override
  String get notes => "メモ";

  @override
  String get hint => "ヒント";

  @override
  String get undoAdTitle => "元に戻すために広告を見てください";

  @override
  String get undoAdDescription => "この短い広告を見て、最後の動きを元に戻してください。";

  @override
  String undoAdCountdown(int seconds) {
    return "広告は ${seconds} 秒後に終了";
  }

  @override
  String get hintAdTitle => "ヒントを得るために広告を見てください";

  @override
  String get hintAdDescription => "この短い広告を見てヒントを獲得してください。";

  @override
  String hintAdCountdown(int seconds) {
    return "広告は ${seconds} 秒後に終了";
  }

  @override
  String get lifeAdTitle => "ハートを復元するために広告を見てください";

  @override
  String get lifeAdDescription => "赤いハートを復元してプレイを続けるために、この短い広告を視聴してください。";

  @override
  String lifeAdCountdown(int seconds) {
    return "広告は ${seconds} 秒後に終了";
  }

  @override
  String get gameScreenTitle => "数独";

  @override
  String get noActiveGameMessage => "アクティブなゲームはありません。ホーム画面に戻ります。";

  @override
  String get victoryTitle => "おめでとう！";

  @override
  String victoryMessage(String time) {
    return "パズルを ${time} で解きました。";
  }

  @override
  String get backToHome => "家";

  @override
  String get playAnother => "もう一度遊ぶ";

  @override
  String get outOfLivesTitle => "あなたは心がありません";

  @override
  String get outOfLivesDescription => "1つの赤い心を回復してプレイし続けます。";

  @override
  String get restoreLifeAction => "ハートをもう1つ獲得（広告を見る）";

  @override
  String get rewardAdUnavailable => "現在、広告を利用できません。";

  @override
  String get cancelAction => "キャンセル";

  @override
  String get settingsTitle => "設定";

  @override
  String get themeSectionTitle => "テーマ";

  @override
  String get themeWhite => "古典的な光";

  @override
  String get themeCream => "クリーム";

  @override
  String get themeGreen => "ミント";

  @override
  String get themeBlack => "暗い";

  @override
  String get themePurple => "紫色の暗い";

  @override
  String get themeFontSize => "フォントサイズ";

  @override
  String get fontSizeExtraSmall => "余分な小";

  @override
  String get fontSizeSmall => "小さい";

  @override
  String get fontSizeMedium => "中くらい";

  @override
  String get fontSizeLarge => "大きい";

  @override
  String get fontSizeExtraLarge => "特大";

  @override
  String get languageSectionTitle => "言語";

  @override
  String get audioSectionTitle => "サウンドと音楽";

  @override
  String get soundsEffectsLabel => "効果音";

  @override
  String get vibrationLabel => "振動";

  @override
  String get miscSectionTitle => "他の";

  @override
  String get howToPlayTitle => "遊び方";

  @override
  String get howToPlayRowRule => "各行には1〜9の数字を重複なく入れます";

  @override
  String get howToPlayColumnRule => "各列には1〜9の数字を重複なく入れます";

  @override
  String get howToPlayBoxRule => "各3×3ブロックには1〜9の数字を重複なく入れます";

  @override
  String get howToPlayFooter => "すべてのマスを埋めたらクリア！";

  @override
  String get howToPlayAction => "わかった";

  @override
  String get championshipLocalSection => "チャンピオンシップ（ローカル）";

  @override
  String get hideCompletedNumbersLabel => "完成した数字を非表示にします";

  @override
  String get aboutApp => "について";

  @override
  String versionLabel(String version) {
    return "バージョン ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "輸出";

  @override
  String get import => "輸入";

  @override
  String get resetMyScore => "スコアをリセットします";

  @override
  String get resetMyScoreConfirmation => "スコアをリセットしたいですか？このアクションを元に戻すことはできません。";

  @override
  String get resetAction => "リセット";

  @override
  String get regenerateOpponents => "敵を再生します";

  @override
  String get confirm => "確認する";

  @override
  String get cancel => "キャンセル";

  @override
  String get done => "終わり";

  @override
  String get privacyPolicyTitle => "プライバシーポリシー";

  @override
  String get privacyPolicyAccept => "同意します";

  @override
  String get privacyPolicyPrompt => "プライバシーポリシーに同意しますか？";

  @override
  String get privacyPolicyLearnMore => "詳しく見る →";

  @override
  String get privacyPolicyDecline => "同意しません";

  @override
  String get privacyPolicyClose => "閉じる";

  @override
  String get privacyPolicyLoadError => "プライバシーポリシーを読み込めませんでした。もう一度お試しください。";

  @override
  String get failed => "失敗した";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "ランク #${current} • +${delta} で #${target}へ";
  }

  @override
  String get statsTitle => "統計";

  @override
  String get statsGamesSection => "ゲーム";

  @override
  String get statsGamesStarted => "ゲームが始まりました";

  @override
  String get statsGamesWon => "ゲームが勝った";

  @override
  String get statsWinRate => "勝利率";

  @override
  String get statsFlawless => "完璧な仕上げ";

  @override
  String get statsTimeSection => "時間";

  @override
  String get statsBestTime => "最高の時間";

  @override
  String get statsAverageTime => "平均時間";

  @override
  String get statsStreakSection => "ストリーク";

  @override
  String get statsCurrentStreak => "現在のストリーク";

  @override
  String get statsBestStreak => "ベストストリーク";

  @override
  String get difficultyNovice => "初心者";

  @override
  String get difficultyNoviceShort => "11月";

  @override
  String get difficultyMedium => "中級";

  @override
  String get difficultyMediumShort => "int。";

  @override
  String get difficultyHigh => "高度な";

  @override
  String get difficultyHighShort => "Adv。";

  @override
  String get difficultyExpert => "専門家";

  @override
  String get difficultyExpertShort => "exp。";

  @override
  String get difficultyMaster => "マスター";

  @override
  String get difficultyMasterShort => "MST。";
}

class AppLocalizationsKa extends AppLocalizations {
  AppLocalizationsKa() : super("ka");

  @override
  String get appTitle => "სუდოკუ ოსტატი";

  @override
  String get navHome => "მთავარი";

  @override
  String get navDaily => "გამოწვევა";

  @override
  String get navStats => "სტატისტიკა";

  @override
  String get dailyStreak => "დღიური სერია";

  @override
  String get selectDifficultyTitle => "აირჩიეთ სირთულე";

  @override
  String get selectDifficultyDailyChallenge => "ყოველდღიური გამოწვევა";

  @override
  String get playAction => "თამაში";

  @override
  String get championshipTitle => "ჩემპიონატი";

  @override
  String championshipScore(int score) {
    return "ქულები ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "შემდეგ ადგილზე გადასასვლელად: ${points} ქულა";
  }

  @override
  String get youAreTop => "თქვენ ხართ #1";

  @override
  String get championshipRoundDescriptionPlaceholder => "ითამაშეთ ეს რაუნდი, რომ გააძლიეროთ თქვენი ჩემპიონატის სერია.";

  @override
  String get championshipRoundCompletedLabel => "დასრულებულია";

  @override
  String totalScore(String score) {
    return "საერთო ქულები: ${score}";
  }

  @override
  String get meLabel => "მე";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "ადგილი ${rank}. ${name}. ${points} ქულა";
  }

  @override
  String yourPosition(int rank, String points) {
    return "ჩემი ადგილი ${rank}. ${points} ქულა";
  }

  @override
  String get pointsShort => "ქულ.";

  @override
  String get championshipAutoScroll => "ავტომატურად გადახვევა ჩემს პოზიციაზე";

  @override
  String get bestLabel => "საუკეთესო";

  @override
  String get play => "თამაში";

  @override
  String get battleTitle => "ბრძოლა";

  @override
  String battleWinRate(int count) {
    return "მოგებები ${count}%";
  }

  @override
  String get battleYouLabel => "შენ";

  @override
  String get battleVictoryTitle => "შენ გაიმარჯვე!";

  @override
  String get battleDefeatTitle => "მეტოქემ გაიმარჯვა";

  @override
  String battleDefeatMessage(String name) {
    return "${name}-მა შენზე ადრე ამოხსნა თავსატეხი.";
  }

  @override
  String get battleSimpleDefeatTitle => "თქვენ დამარცხდით";

  @override
  String get battleExitToMainMenu => "მთავარ მენიუში დაბრუნება";

  @override
  String get playerFlagSettingTitle => "მოთამაშის დროშა";

  @override
  String get selectPlayerFlag => "აირჩიე შენი დროშა";

  @override
  String get confirmFlagSelectionTitle => "დაადასტურე შენი დროშა";

  @override
  String get confirmFlagSelectionMessage => "დარწმუნებული ხარ, რომ ამ დროშას ირჩევ? შეგიძლია მოგვიანებით შეცვალო დროშა თამაშის პარამეტრებში.";

  @override
  String get confirmFlagSelectionConfirm => "დადასტურება";

  @override
  String get startAction => "დაწყება";

  @override
  String levelHeading(int level, String difficulty) {
    return "დონე ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "რეიტინგის პროგრესი";

  @override
  String rankLabel(int rank) {
    return "რეიტინგი ${rank}";
  }

  @override
  String get newGame => "ახალი თამაში";

  @override
  String get continueGame => "გაგრძელება";

  @override
  String get weeklyProgress => "კვირეული პროგრესი";

  @override
  String get rewardsTitle => "ჯილდოები";

  @override
  String get rewardNoMistakesTitle => "დაასრულეთ გამოწვევა შეცდომების გარეშე";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} გული",
      other: "${count} გული",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "დაასრულეთ სამი გამოწვევა ზედიზედ";

  @override
  String get rewardUniqueTrophy => "უნიკალური თასი";

  @override
  String get rewardSevenDayTitle => "შეინარჩუნეთ 7-დღიანი სერია";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} ვარსკვლავი",
      other: "${count} ვარსკვლავი",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "დღევანდელი თავსატეხი";

  @override
  String get todayPuzzleDescription => "დაასრულეთ სუდოკუ, რათა მიიღოთ დამატებითი ჯილდო და შეინარჩუნოთ სერია.";

  @override
  String get continueAction => "გაგრძელება";

  @override
  String get adMessage => "რეკლამა: იპოვეთ დამალული ობიექტები! ითამაშეთ ახლავე.";

  @override
  String get adPlay => "თამაში";

  @override
  String get undo => "გაუქმება";

  @override
  String get erase => "წაშლა";

  @override
  String get autoNotes => "ავტო შენიშვნები";

  @override
  String get statusOn => "ჩართული";

  @override
  String get statusOff => "გამორთული";

  @override
  String get notes => "შენიშვნები";

  @override
  String get hint => "მინიშნება";

  @override
  String get undoAdTitle => "უყურეთ რეკლამას გასაუქმებლად";

  @override
  String get undoAdDescription => "უყურეთ ამ მოკლე რეკლამას, რომ გააუქმოთ ბოლო სვლა.";

  @override
  String undoAdCountdown(int seconds) {
    return "რეკლამა დასრულდება ${seconds} წმ-ში";
  }

  @override
  String get hintAdTitle => "უყურეთ რეკლამას მინიშნების მისაღებად";

  @override
  String get hintAdDescription => "უყურეთ ამ მოკლე რეკლამას, რათა მიიღოთ მინიშნება.";

  @override
  String hintAdCountdown(int seconds) {
    return "რეკლამა დასრულდება ${seconds} წმ-ში";
  }

  @override
  String get lifeAdTitle => "უყურეთ რეკლამას გულის აღსადგენად";

  @override
  String get lifeAdDescription => "უყურეთ ამ მოკლე რეკლამას, რათა აღდგეს წითელი გული და გააგრძელოთ თამაში.";

  @override
  String lifeAdCountdown(int seconds) {
    return "რეკლამა დასრულდება ${seconds} წმ-ში";
  }

  @override
  String get gameScreenTitle => "სუდოკუ";

  @override
  String get noActiveGameMessage => "აქტიური თამაში არ არის. დაბრუნდით მთავარ ეკრანზე.";

  @override
  String get victoryTitle => "გილოცავთ!";

  @override
  String victoryMessage(String time) {
    return "თავსატეხი ამოხსნილია ${time}-ში.";
  }

  @override
  String get backToHome => "მთავარი";

  @override
  String get playAnother => "კიდევ თამაში";

  @override
  String get outOfLivesTitle => "გულები აღარ დარჩა";

  @override
  String get outOfLivesDescription => "თამაშის გასაგრძელებლად აღადგინეთ ერთი წითელი გული.";

  @override
  String get restoreLifeAction => "მიიღე კიდევ ერთი გული (უყურე რეკლამას)";

  @override
  String get rewardAdUnavailable => "რეკლამა ამჟამად ხელმისაწვდომი არ არის.";

  @override
  String get cancelAction => "გაუქმება";

  @override
  String get settingsTitle => "პარამეტრები";

  @override
  String get themeSectionTitle => "თემა";

  @override
  String get themeWhite => "კლასიკური ღია";

  @override
  String get themeCream => "კრემისფერი";

  @override
  String get themeGreen => "მინტი";

  @override
  String get themeBlack => "მუქი";

  @override
  String get themePurple => "იისფერი მუქი";

  @override
  String get themeFontSize => "ფონტის ზომა";

  @override
  String get fontSizeExtraSmall => "ძალიან პატარა";

  @override
  String get fontSizeSmall => "პატარა";

  @override
  String get fontSizeMedium => "საშუალო";

  @override
  String get fontSizeLarge => "დიდი";

  @override
  String get fontSizeExtraLarge => "ძალიან დიდი";

  @override
  String get languageSectionTitle => "ენა";

  @override
  String get audioSectionTitle => "ხმა და მუსიკა";

  @override
  String get soundsEffectsLabel => "ხმის ეფექტები";

  @override
  String get vibrationLabel => "ვიბრაცია";

  @override
  String get miscSectionTitle => "სხვა";

  @override
  String get howToPlayTitle => "როგორ ვითამაშოთ";

  @override
  String get howToPlayRowRule => "ყოველ რიგში უნდა იყოს ციფრები 1-დან 9-მდე გამეორებების გარეშე";

  @override
  String get howToPlayColumnRule => "ყოველ სვეტში უნდა იყოს ციფრები 1-დან 9-მდე გამეორებების გარეშე";

  @override
  String get howToPlayBoxRule => "ყოველ 3×3 კვადრატში უნდა იყოს ციფრები 1-დან 9-მდე გამეორებების გარეშე";

  @override
  String get howToPlayFooter => "შეავსე ყველა უჯრა და გაიმარჯვე!";

  @override
  String get howToPlayAction => "გასაგებია";

  @override
  String get championshipLocalSection => "ჩემპიონატი (ლოკალური)";

  @override
  String get hideCompletedNumbersLabel => "დამალე დასრულებული ციფრები";

  @override
  String get aboutApp => "აპლიკაციის შესახებ";

  @override
  String versionLabel(String version) {
    return "ვერსია ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "ექსპორტი";

  @override
  String get import => "იმპორტი";

  @override
  String get resetMyScore => "ჩემი ქულების განულება";

  @override
  String get resetMyScoreConfirmation => "დარწმუნებული ხართ, რომ გსურთ ქულების განულება? ეს ქმედება შეუქცევადია.";

  @override
  String get resetAction => "განულება";

  @override
  String get regenerateOpponents => "მოწინააღმდეგეების განახლება";

  @override
  String get confirm => "დადასტურება";

  @override
  String get cancel => "გაუქმება";

  @override
  String get done => "დასრულდა";

  @override
  String get privacyPolicyTitle => "კონფიდენციალურობის პოლიტიკა";

  @override
  String get privacyPolicyAccept => "ვეთანხმები";

  @override
  String get privacyPolicyPrompt => "ეთანხმებით კონფიდენციალურობის პოლიტიკას?";

  @override
  String get privacyPolicyLearnMore => "გაიგეთ მეტი →";

  @override
  String get privacyPolicyDecline => "ვუარყოფ";

  @override
  String get privacyPolicyClose => "დახურვა";

  @override
  String get privacyPolicyLoadError => "კონფიდენციალურობის პოლიტიკის ჩატვირთვა ვერ მოხერხდა. გთხოვთ, სცადეთ ხელახლა.";

  @override
  String get failed => "ვერ შესრულდა";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "რეიტინგი #${current} • +${delta} რათა მიაღწიოთ #${target}";
  }

  @override
  String get statsTitle => "სტატისტიკა";

  @override
  String get statsGamesSection => "თამაშები";

  @override
  String get statsGamesStarted => "დაწყებული თამაშები";

  @override
  String get statsGamesWon => "მოგებული თამაშები";

  @override
  String get statsWinRate => "მოგების მაჩვენებელი";

  @override
  String get statsFlawless => "სრულყოფილი დასრულებები";

  @override
  String get statsTimeSection => "დრო";

  @override
  String get statsBestTime => "საუკეთესო დრო";

  @override
  String get statsAverageTime => "საშუალო დრო";

  @override
  String get statsStreakSection => "სერია";

  @override
  String get statsCurrentStreak => "მიმდინარე სერია";

  @override
  String get statsBestStreak => "საუკეთესო სერია";

  @override
  String get difficultyNovice => "დამწყები";

  @override
  String get difficultyNoviceShort => "დამ.";

  @override
  String get difficultyMedium => "საშუალო";

  @override
  String get difficultyMediumShort => "საშ.";

  @override
  String get difficultyHigh => "გამოცდილი";

  @override
  String get difficultyHighShort => "გამოც.";

  @override
  String get difficultyExpert => "ექსპერტი";

  @override
  String get difficultyExpertShort => "ექსპ.";

  @override
  String get difficultyMaster => "ოსტატი";

  @override
  String get difficultyMasterShort => "ოსტ.";
}

class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo() : super("ko");

  @override
  String get appTitle => "스도쿠 마스터";

  @override
  String get navHome => "홈";

  @override
  String get navDaily => "도전";

  @override
  String get navStats => "통계";

  @override
  String get dailyStreak => "일일 연속";

  @override
  String get selectDifficultyTitle => "난이도 선택";

  @override
  String get selectDifficultyDailyChallenge => "일일 도전";

  @override
  String get playAction => "플레이";

  @override
  String get championshipTitle => "챔피언십";

  @override
  String championshipScore(int score) {
    return "점수 ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "다음 순위까지: ${points} pts";
  }

  @override
  String get youAreTop => "당신은 1위입니다";

  @override
  String get championshipRoundDescriptionPlaceholder => "이 라운드를 플레이해 챔피언십 순위를 끌어올리세요.";

  @override
  String get championshipRoundCompletedLabel => "완료";

  @override
  String totalScore(String score) {
    return "총 점수: ${score}";
  }

  @override
  String get meLabel => "나";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "순위 ${rank}. ${name}. ${points} 포인트";
  }

  @override
  String yourPosition(int rank, String points) {
    return "내 순위 ${rank}. ${points} 포인트";
  }

  @override
  String get pointsShort => "pts";

  @override
  String get championshipAutoScroll => "내 위치에 자동 스크롤";

  @override
  String get bestLabel => "최상의";

  @override
  String get play => "놀다";

  @override
  String get battleTitle => "전투";

  @override
  String battleWinRate(int count) {
    return "승리 ${count}%";
  }

  @override
  String get battleYouLabel => "당신";

  @override
  String get battleVictoryTitle => "당신의 승리!";

  @override
  String get battleDefeatTitle => "상대가 승리했어요";

  @override
  String battleDefeatMessage(String name) {
    return "${name}가 당신보다 먼저 스도쿠를 풀었습니다.";
  }

  @override
  String get battleSimpleDefeatTitle => "패배했습니다";

  @override
  String get battleExitToMainMenu => "메인 메뉴로 나가기";

  @override
  String get playerFlagSettingTitle => "플레이어 깃발";

  @override
  String get selectPlayerFlag => "깃발을 선택하세요";

  @override
  String get confirmFlagSelectionTitle => "깃발 확인";

  @override
  String get confirmFlagSelectionMessage => "이 깃발을 선택하시겠습니까? 나중에 게임 설정에서 깃발을 변경할 수 있습니다.";

  @override
  String get confirmFlagSelectionConfirm => "확인";

  @override
  String get startAction => "시작";

  @override
  String levelHeading(int level, String difficulty) {
    return "레벨 ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "순위 진행";

  @override
  String rankLabel(int rank) {
    return "랭크 ${rank}";
  }

  @override
  String get newGame => "새로운 게임";

  @override
  String get continueGame => "계속 게임";

  @override
  String get weeklyProgress => "주간 진행";

  @override
  String get rewardsTitle => "보상";

  @override
  String get rewardNoMistakesTitle => "실수없이 도전을 끝내십시오";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} 하트",
      other: "${count} 하트",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "연속으로 세 가지 도전을 완료하십시오";

  @override
  String get rewardUniqueTrophy => "독특한 트로피";

  @override
  String get rewardSevenDayTitle => "7 일 행진을 유지하십시오";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} 별",
      other: "${count} 별",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "오늘의 퍼즐";

  @override
  String get todayPuzzleDescription => "스도쿠를 마치고 추가 보상을 받고 줄무늬를 유지하십시오.";

  @override
  String get continueAction => "계속하다";

  @override
  String get adMessage => "AD : 숨겨진 물건을 찾으십시오! 지금 플레이하십시오.";

  @override
  String get adPlay => "놀다";

  @override
  String get undo => "끄르다";

  @override
  String get erase => "지우다";

  @override
  String get autoNotes => "자동 노트";

  @override
  String get statusOn => "에";

  @override
  String get statusOff => "끄다";

  @override
  String get notes => "메모";

  @override
  String get hint => "힌트";

  @override
  String get undoAdTitle => "취소 할 광고를 시청하십시오";

  @override
  String get undoAdDescription => "이 짧은 광고를보고 마지막 이동을 취소하십시오.";

  @override
  String undoAdCountdown(int seconds) {
    return "광고가 ${seconds}초 후 종료";
  }

  @override
  String get hintAdTitle => "힌트를 얻으려면 광고를 시청하세요";

  @override
  String get hintAdDescription => "짧은 광고를 시청하고 힌트를 얻으세요.";

  @override
  String hintAdCountdown(int seconds) {
    return "광고가 ${seconds}초 후 종료";
  }

  @override
  String get lifeAdTitle => "하트를 복원하려면 광고를 시청하세요";

  @override
  String get lifeAdDescription => "짧은 광고를 시청하여 빨간 하트를 복원하고 게임을 계속하세요.";

  @override
  String lifeAdCountdown(int seconds) {
    return "광고가 ${seconds}초 후 종료";
  }

  @override
  String get gameScreenTitle => "스도쿠";

  @override
  String get noActiveGameMessage => "능동적 인 게임이 없습니다. 홈 화면으로 돌아갑니다.";

  @override
  String get victoryTitle => "축하해요!";

  @override
  String victoryMessage(String time) {
    return "퍼즐을 ${time}에 해결했습니다.";
  }

  @override
  String get backToHome => "집";

  @override
  String get playAnother => "다시 플레이하십시오";

  @override
  String get outOfLivesTitle => "당신은 마음이 없습니다";

  @override
  String get outOfLivesDescription => "붉은 심장 하나를 회복하여 계속 연주하십시오.";

  @override
  String get restoreLifeAction => "하트를 하나 더 받기 (광고 시청)";

  @override
  String get rewardAdUnavailable => "현재 광고를 이용할 수 없습니다.";

  @override
  String get cancelAction => "취소";

  @override
  String get settingsTitle => "설정";

  @override
  String get themeSectionTitle => "주제";

  @override
  String get themeWhite => "클래식 라이트";

  @override
  String get themeCream => "크림";

  @override
  String get themeGreen => "박하";

  @override
  String get themeBlack => "어두운";

  @override
  String get themePurple => "보라색 어두운";

  @override
  String get themeFontSize => "글꼴 크기";

  @override
  String get fontSizeExtraSmall => "더 작습니다";

  @override
  String get fontSizeSmall => "작은";

  @override
  String get fontSizeMedium => "중간";

  @override
  String get fontSizeLarge => "크기가 큰";

  @override
  String get fontSizeExtraLarge => "특대";

  @override
  String get languageSectionTitle => "언어";

  @override
  String get audioSectionTitle => "소리와 음악";

  @override
  String get soundsEffectsLabel => "음향 효과";

  @override
  String get vibrationLabel => "진동";

  @override
  String get miscSectionTitle => "다른";

  @override
  String get howToPlayTitle => "플레이 방법";

  @override
  String get howToPlayRowRule => "각 가로줄에는 1부터 9까지 숫자가 중복 없이 들어갑니다";

  @override
  String get howToPlayColumnRule => "각 세로줄에는 1부터 9까지 숫자가 중복 없이 들어갑니다";

  @override
  String get howToPlayBoxRule => "각 3×3 칸에는 1부터 9까지 숫자가 중복 없이 들어갑니다";

  @override
  String get howToPlayFooter => "모든 칸을 채우면 승리예요!";

  @override
  String get howToPlayAction => "알겠어요";

  @override
  String get championshipLocalSection => "챔피언십 (지역)";

  @override
  String get hideCompletedNumbersLabel => "완성 된 숫자를 숨기십시오";

  @override
  String get aboutApp => "에 대한";

  @override
  String versionLabel(String version) {
    return "버전 ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "내보내다";

  @override
  String get import => "수입";

  @override
  String get resetMyScore => "내 점수를 재설정하십시오";

  @override
  String get resetMyScoreConfirmation => "점수를 재설정 하시겠습니까? 이 조치는 취소 할 수 없습니다.";

  @override
  String get resetAction => "다시 놓기";

  @override
  String get regenerateOpponents => "상대방을 재생합니다";

  @override
  String get confirm => "확인하다";

  @override
  String get cancel => "취소";

  @override
  String get done => "완료";

  @override
  String get privacyPolicyTitle => "개인정보 처리방침";

  @override
  String get privacyPolicyAccept => "동의합니다";

  @override
  String get privacyPolicyPrompt => "개인정보 처리방침에 동의하시겠습니까?";

  @override
  String get privacyPolicyLearnMore => "자세히 보기 →";

  @override
  String get privacyPolicyDecline => "동의하지 않음";

  @override
  String get privacyPolicyClose => "닫기";

  @override
  String get privacyPolicyLoadError => "개인정보 처리방침을 불러오지 못했습니다. 다시 시도해 주세요.";

  @override
  String get failed => "실패한";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "랭크 #${current} • +${delta} #${target}까지";
  }

  @override
  String get statsTitle => "통계";

  @override
  String get statsGamesSection => "계략";

  @override
  String get statsGamesStarted => "게임이 시작되었습니다";

  @override
  String get statsGamesWon => "게임 우승";

  @override
  String get statsWinRate => "승리";

  @override
  String get statsFlawless => "완벽한 마무리";

  @override
  String get statsTimeSection => "시간";

  @override
  String get statsBestTime => "최고의 시간";

  @override
  String get statsAverageTime => "평균 시간";

  @override
  String get statsStreakSection => "줄";

  @override
  String get statsCurrentStreak => "현재 행진";

  @override
  String get statsBestStreak => "최고의 행진";

  @override
  String get difficultyNovice => "초심자";

  @override
  String get difficultyNoviceShort => "11 월";

  @override
  String get difficultyMedium => "중간";

  @override
  String get difficultyMediumShort => "int.";

  @override
  String get difficultyHigh => "고급의";

  @override
  String get difficultyHighShort => "adv.";

  @override
  String get difficultyExpert => "전문가";

  @override
  String get difficultyExpertShort => "Exp.";

  @override
  String get difficultyMaster => "주인";

  @override
  String get difficultyMasterShort => "MST.";
}

class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu() : super("ru");

  @override
  String get appTitle => "Судоку Мастер";

  @override
  String get navHome => "Главная";

  @override
  String get navDaily => "Испытание";

  @override
  String get navStats => "Статистика";

  @override
  String get dailyStreak => "Серия дней";

  @override
  String get selectDifficultyTitle => "Выберите сложность";

  @override
  String get selectDifficultyDailyChallenge => "Ежедневное испытание";

  @override
  String get playAction => "Играть";

  @override
  String get championshipTitle => "Чемпионат";

  @override
  String championshipScore(int score) {
    return "Счёт ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "До следующего места: ${points} оч.";
  }

  @override
  String get youAreTop => "Вы №1";

  @override
  String get championshipRoundDescriptionPlaceholder => "Сыграйте в этом раунде, чтобы продвинуться в чемпионате.";

  @override
  String get championshipRoundCompletedLabel => "Завершено";

  @override
  String totalScore(String score) {
    return "Общий счёт: ${score}";
  }

  @override
  String get meLabel => "Я";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "Место ${rank}. ${name}. ${points} очков";
  }

  @override
  String yourPosition(int rank, String points) {
    return "Моё место ${rank}. ${points} очков";
  }

  @override
  String get pointsShort => "очк.";

  @override
  String get championshipAutoScroll => "Автопрокрутка к моему месту";

  @override
  String get bestLabel => "Лучший результат";

  @override
  String get play => "Играть";

  @override
  String get battleTitle => "Битва";

  @override
  String battleWinRate(int count) {
    return "Побед ${count}%";
  }

  @override
  String get battleYouLabel => "Ты";

  @override
  String get battleVictoryTitle => "Ты выиграл!";

  @override
  String get battleDefeatTitle => "Соперник победил";

  @override
  String battleDefeatMessage(String name) {
    return "${name} решил головоломку раньше тебя.";
  }

  @override
  String get battleSimpleDefeatTitle => "Вы проиграли";

  @override
  String get battleExitToMainMenu => "Выйти в главное меню";

  @override
  String get playerFlagSettingTitle => "Флаг игрока";

  @override
  String get selectPlayerFlag => "Выбери свой флаг";

  @override
  String get confirmFlagSelectionTitle => "Подтвердите флаг";

  @override
  String get confirmFlagSelectionMessage => "Вы уверены, что хотите выбрать этот флаг? Флаг можно будет изменить в настройках игры.";

  @override
  String get confirmFlagSelectionConfirm => "Подтверждаю";

  @override
  String get startAction => "Начать";

  @override
  String levelHeading(int level, String difficulty) {
    return "Уровень ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "Прогресс ранга";

  @override
  String rankLabel(int rank) {
    return "Ранг ${rank}";
  }

  @override
  String get newGame => "Новая игра";

  @override
  String get continueGame => "Продолжить игру";

  @override
  String get weeklyProgress => "Недельный прогресс";

  @override
  String get rewardsTitle => "Награды";

  @override
  String get rewardNoMistakesTitle => "Пройдите вызов без ошибок";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} сердце",
      few: "${count} сердца",
      many: "${count} сердец",
      other: "${count} сердца",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "Выполните три вызова подряд";

  @override
  String get rewardUniqueTrophy => "Уникальный трофей";

  @override
  String get rewardSevenDayTitle => "Поддерживайте серию 7 дней";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} звезда",
      few: "${count} звезды",
      many: "${count} звёзд",
      other: "${count} звезды",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "Сегодняшняя головоломка";

  @override
  String get todayPuzzleDescription => "Решите судоку, чтобы получить дополнительную награду и продолжить серию.";

  @override
  String get continueAction => "Продолжить";

  @override
  String get adMessage => "Реклама: Найди скрытые объекты! Играй сейчас.";

  @override
  String get adPlay => "Играть";

  @override
  String get undo => "Отменить";

  @override
  String get erase => "Стереть";

  @override
  String get autoNotes => "Автозаметки";

  @override
  String get statusOn => "ВКЛ";

  @override
  String get statusOff => "ВЫКЛ";

  @override
  String get notes => "Заметки";

  @override
  String get hint => "Подсказка";

  @override
  String get undoAdTitle => "Смотреть рекламу для отмены";

  @override
  String get undoAdDescription => "Посмотрите короткую рекламу, чтобы отменить последний ход.";

  @override
  String undoAdCountdown(int seconds) {
    return "Реклама завершится через ${seconds} с";
  }

  @override
  String get hintAdTitle => "Смотреть рекламу для подсказки";

  @override
  String get hintAdDescription => "Посмотрите короткую рекламу, чтобы получить подсказку.";

  @override
  String hintAdCountdown(int seconds) {
    return "Реклама завершится через ${seconds} с";
  }

  @override
  String get lifeAdTitle => "Смотрите рекламу, чтобы восстановить сердце";

  @override
  String get lifeAdDescription => "Посмотрите эту короткую рекламу, чтобы восстановить красное сердце и продолжить игру.";

  @override
  String lifeAdCountdown(int seconds) {
    return "Реклама завершится через ${seconds} с";
  }

  @override
  String get gameScreenTitle => "Судоку";

  @override
  String get noActiveGameMessage => "Нет активной игры. Вернитесь на главный экран.";

  @override
  String get victoryTitle => "Поздравляем!";

  @override
  String victoryMessage(String time) {
    return "Головоломка решена за ${time}.";
  }

  @override
  String get backToHome => "На главную";

  @override
  String get playAnother => "Ещё одну";

  @override
  String get outOfLivesTitle => "Сердца закончились";

  @override
  String get outOfLivesDescription => "Восстановите одно красное сердце, чтобы продолжить игру.";

  @override
  String get restoreLifeAction => "Получить ещё одно сердце (посмотреть рекламу)";

  @override
  String get rewardAdUnavailable => "Реклама сейчас недоступна.";

  @override
  String get cancelAction => "Отмена";

  @override
  String get settingsTitle => "Настройки";

  @override
  String get themeSectionTitle => "Тема";

  @override
  String get themeWhite => "Классическая светлая";

  @override
  String get themeCream => "Кремовая";

  @override
  String get themeGreen => "Мятная";

  @override
  String get themeBlack => "Тёмная";

  @override
  String get themePurple => "Фиолетовая тёмная";

  @override
  String get themeFontSize => "Размер шрифта";

  @override
  String get fontSizeExtraSmall => "Очень маленький";

  @override
  String get fontSizeSmall => "Маленький";

  @override
  String get fontSizeMedium => "Средний";

  @override
  String get fontSizeLarge => "Большой";

  @override
  String get fontSizeExtraLarge => "Очень большой";

  @override
  String get languageSectionTitle => "Язык";

  @override
  String get audioSectionTitle => "Звук и музыка";

  @override
  String get soundsEffectsLabel => "Звуковые эффекты";

  @override
  String get vibrationLabel => "Вибрация";

  @override
  String get miscSectionTitle => "Другое";

  @override
  String get howToPlayTitle => "Как играть";

  @override
  String get howToPlayRowRule => "В каждой строке цифры от 1 до 9 без повторов";

  @override
  String get howToPlayColumnRule => "В каждом столбце цифры от 1 до 9 без повторов";

  @override
  String get howToPlayBoxRule => "В каждом квадрате 3×3 цифры от 1 до 9 без повторов";

  @override
  String get howToPlayFooter => "Заполни все клетки — и победа!";

  @override
  String get howToPlayAction => "ОК";

  @override
  String get championshipLocalSection => "Чемпионат (локально)";

  @override
  String get hideCompletedNumbersLabel => "Убирать использованные цифры";

  @override
  String get aboutApp => "О приложении";

  @override
  String versionLabel(String version) {
    return "Версия ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "Экспорт";

  @override
  String get import => "Импорт";

  @override
  String get resetMyScore => "Сбросить мой счёт";

  @override
  String get resetMyScoreConfirmation => "Вы уверены, что хотите сбросить счёт? Это действие необратимо.";

  @override
  String get resetAction => "Сбросить";

  @override
  String get regenerateOpponents => "Перегенерировать соперников";

  @override
  String get confirm => "Подтвердить";

  @override
  String get cancel => "Отмена";

  @override
  String get done => "Готово";

  @override
  String get privacyPolicyTitle => "Политика конфиденциальности";

  @override
  String get privacyPolicyAccept => "Принимаю";

  @override
  String get privacyPolicyPrompt => "Вы принимаете Политику конфиденциальности?";

  @override
  String get privacyPolicyLearnMore => "Подробнее →";

  @override
  String get privacyPolicyDecline => "Отклоняю";

  @override
  String get privacyPolicyClose => "Закрыть";

  @override
  String get privacyPolicyLoadError => "Не удалось загрузить политику конфиденциальности. Повторите попытку.";

  @override
  String get failed => "Ошибка";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "Место #${current} • +${delta} до #${target}";
  }

  @override
  String get statsTitle => "Статистика";

  @override
  String get statsGamesSection => "Игры";

  @override
  String get statsGamesStarted => "Начатые игры";

  @override
  String get statsGamesWon => "Выигранные игры";

  @override
  String get statsWinRate => "Процент побед";

  @override
  String get statsFlawless => "Победы без ошибок";

  @override
  String get statsTimeSection => "Время";

  @override
  String get statsBestTime => "Лучшее время";

  @override
  String get statsAverageTime => "Среднее время";

  @override
  String get statsStreakSection => "Серия";

  @override
  String get statsCurrentStreak => "Текущая серия";

  @override
  String get statsBestStreak => "Лучшая серия";

  @override
  String get difficultyNovice => "Любитель";

  @override
  String get difficultyNoviceShort => "Люб.";

  @override
  String get difficultyMedium => "Средний";

  @override
  String get difficultyMediumShort => "Ср.";

  @override
  String get difficultyHigh => "Сложный";

  @override
  String get difficultyHighShort => "Слж.";

  @override
  String get difficultyExpert => "Эксперт";

  @override
  String get difficultyExpertShort => "Эксп.";

  @override
  String get difficultyMaster => "Мастер";

  @override
  String get difficultyMasterShort => "Маст.";
}

class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk() : super("uk");

  @override
  String get appTitle => "Судоку Майстер";

  @override
  String get navHome => "Головна";

  @override
  String get navDaily => "Виклик";

  @override
  String get navStats => "Статистика";

  @override
  String get dailyStreak => "Ланцюг днів";

  @override
  String get selectDifficultyTitle => "Виберіть складність";

  @override
  String get selectDifficultyDailyChallenge => "Щоденний виклик";

  @override
  String get playAction => "Грати";

  @override
  String get championshipTitle => "Чемпіонат";

  @override
  String championshipScore(int score) {
    return "Рахунок ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "До наступного місця: ${points} оч.";
  }

  @override
  String get youAreTop => "Ви №1";

  @override
  String get championshipRoundDescriptionPlaceholder => "Зіграйте в цьому раунді, щоб просунутися в чемпіонаті.";

  @override
  String get championshipRoundCompletedLabel => "Завершено";

  @override
  String totalScore(String score) {
    return "Загальний рахунок: ${score}";
  }

  @override
  String get meLabel => "Я";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "Місце ${rank}. ${name}. ${points} очок";
  }

  @override
  String yourPosition(int rank, String points) {
    return "Моє місце ${rank}. ${points} очок";
  }

  @override
  String get pointsShort => "оч.";

  @override
  String get championshipAutoScroll => "Автоскрол до мого місця";

  @override
  String get bestLabel => "Найкращий результат";

  @override
  String get play => "Грати";

  @override
  String get battleTitle => "Битва";

  @override
  String battleWinRate(int count) {
    return "Перемог ${count}%";
  }

  @override
  String get battleYouLabel => "Ти";

  @override
  String get battleVictoryTitle => "Ти переміг!";

  @override
  String get battleDefeatTitle => "Суперник переміг";

  @override
  String battleDefeatMessage(String name) {
    return "${name} розв'язав головоломку раніше за тебе.";
  }

  @override
  String get battleSimpleDefeatTitle => "Ви програли";

  @override
  String get battleExitToMainMenu => "Головне меню";

  @override
  String get playerFlagSettingTitle => "Прапор гравця";

  @override
  String get selectPlayerFlag => "Обери свій прапор";

  @override
  String get confirmFlagSelectionTitle => "Підтвердь свій прапор";

  @override
  String get confirmFlagSelectionMessage => "Ти впевнений, що хочеш обрати цей прапор? Ти зможеш змінити прапор пізніше в налаштуваннях гри.";

  @override
  String get confirmFlagSelectionConfirm => "Підтверджую";

  @override
  String get startAction => "Почати";

  @override
  String levelHeading(int level, String difficulty) {
    return "Рівень ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "Прогрес рангу";

  @override
  String rankLabel(int rank) {
    return "Ранг ${rank}";
  }

  @override
  String get newGame => "Нова гра";

  @override
  String get continueGame => "Продовжити гру";

  @override
  String get weeklyProgress => "Тижневий прогрес";

  @override
  String get rewardsTitle => "Нагороди";

  @override
  String get rewardNoMistakesTitle => "Завершіть виклик без помилок";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} серце",
      few: "${count} серця",
      many: "${count} сердець",
      other: "${count} серця",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "Виконайте три виклики поспіль";

  @override
  String get rewardUniqueTrophy => "Унікальний трофей";

  @override
  String get rewardSevenDayTitle => "Підтримуйте серію 7 днів";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: "${count} зірка",
      few: "${count} зірки",
      many: "${count} зірок",
      other: "${count} зірки",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "Сьогоднішня головоломка";

  @override
  String get todayPuzzleDescription => "Завершіть судоку, щоб отримати додаткову нагороду та продовжити серію.";

  @override
  String get continueAction => "Продовжити";

  @override
  String get adMessage => "Реклама: Знайди приховані об'єкти! Грай зараз.";

  @override
  String get adPlay => "Грати";

  @override
  String get undo => "Скасувати";

  @override
  String get erase => "Стерти";

  @override
  String get autoNotes => "Автоматичні нотатки";

  @override
  String get statusOn => "УВІМК";

  @override
  String get statusOff => "ВИМК";

  @override
  String get notes => "Нотатки";

  @override
  String get hint => "Підказка";

  @override
  String get undoAdTitle => "Перегляд реклами для скасування";

  @override
  String get undoAdDescription => "Перегляньте коротку рекламу, щоб скасувати останній хід.";

  @override
  String undoAdCountdown(int seconds) {
    return "Реклама завершиться через ${seconds} с";
  }

  @override
  String get hintAdTitle => "Перегляньте рекламу, щоб отримати підказку";

  @override
  String get hintAdDescription => "Перегляньте коротку рекламу, щоб отримати підказку.";

  @override
  String hintAdCountdown(int seconds) {
    return "Реклама завершиться через ${seconds} с";
  }

  @override
  String get lifeAdTitle => "Перегляньте рекламу, щоб відновити серце";

  @override
  String get lifeAdDescription => "Перегляньте коротку рекламу, щоб відновити червоне серце й продовжити гру.";

  @override
  String lifeAdCountdown(int seconds) {
    return "Реклама завершиться через ${seconds} с";
  }

  @override
  String get gameScreenTitle => "Судоку";

  @override
  String get noActiveGameMessage => "Немає активної гри. Поверніться на головний екран.";

  @override
  String get victoryTitle => "Вітаємо!";

  @override
  String victoryMessage(String time) {
    return "Головоломку розв'язано за ${time}.";
  }

  @override
  String get backToHome => "На головну";

  @override
  String get playAnother => "Ще одну";

  @override
  String get outOfLivesTitle => "Ви втратили всі серця";

  @override
  String get outOfLivesDescription => "Відновіть одне червоне серце, щоб продовжити гру.";

  @override
  String get restoreLifeAction => "Отримати ще одне серце (за перегляд реклами)";

  @override
  String get rewardAdUnavailable => "Реклама недоступна зараз.";

  @override
  String get cancelAction => "Скасувати";

  @override
  String get settingsTitle => "Налаштування";

  @override
  String get themeSectionTitle => "Тема";

  @override
  String get themeWhite => "Класична світла";

  @override
  String get themeCream => "Кремова";

  @override
  String get themeGreen => "М'ятна";

  @override
  String get themeBlack => "Темна";

  @override
  String get themePurple => "Фіолетова темна";

  @override
  String get themeFontSize => "Розмір шрифту";

  @override
  String get fontSizeExtraSmall => "Дуже малий";

  @override
  String get fontSizeSmall => "Малий";

  @override
  String get fontSizeMedium => "Середній";

  @override
  String get fontSizeLarge => "Великий";

  @override
  String get fontSizeExtraLarge => "Дуже великий";

  @override
  String get languageSectionTitle => "Мова";

  @override
  String get audioSectionTitle => "Звуки та музика";

  @override
  String get soundsEffectsLabel => "Звукові ефекти";

  @override
  String get vibrationLabel => "Вібрація";

  @override
  String get miscSectionTitle => "Інше";

  @override
  String get howToPlayTitle => "Як грати";

  @override
  String get howToPlayRowRule => "У кожному рядку цифри від 1 до 9 без повторів";

  @override
  String get howToPlayColumnRule => "У кожній колонці цифри від 1 до 9 без повторів";

  @override
  String get howToPlayBoxRule => "У кожному квадраті 3×3 цифри від 1 до 9 без повторів";

  @override
  String get howToPlayFooter => "Заповни всі клітинки — і переможи!";

  @override
  String get howToPlayAction => "Зрозуміло";

  @override
  String get championshipLocalSection => "Чемпіонат (локально)";

  @override
  String get hideCompletedNumbersLabel => "Прибирати використані цифри";

  @override
  String get aboutApp => "Про застосунок";

  @override
  String versionLabel(String version) {
    return "Версія ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "Експорт";

  @override
  String get import => "Імпорт";

  @override
  String get resetMyScore => "Скинути мій рахунок";

  @override
  String get resetMyScoreConfirmation => "Ви впевнені, що хочете скинути рахунок? Цю дію неможливо скасувати.";

  @override
  String get resetAction => "Скинути";

  @override
  String get regenerateOpponents => "Перегенерувати суперників";

  @override
  String get confirm => "Підтвердити";

  @override
  String get cancel => "Скасувати";

  @override
  String get done => "Готово";

  @override
  String get privacyPolicyTitle => "Політика конфіденційності";

  @override
  String get privacyPolicyAccept => "Приймаю";

  @override
  String get privacyPolicyPrompt => "Ви приймаєте Політику конфіденційності?";

  @override
  String get privacyPolicyLearnMore => "Детальніше →";

  @override
  String get privacyPolicyDecline => "Відхиляю";

  @override
  String get privacyPolicyClose => "Закрити";

  @override
  String get privacyPolicyLoadError => "Не вдалося завантажити політику конфіденційності. Спробуйте ще раз.";

  @override
  String get failed => "Помилка";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "Місце #${current} • +${delta} до #${target}";
  }

  @override
  String get statsTitle => "Статистика";

  @override
  String get statsGamesSection => "Ігри";

  @override
  String get statsGamesStarted => "Розпочаті ігри";

  @override
  String get statsGamesWon => "Виграні ігри";

  @override
  String get statsWinRate => "Відсоток перемог";

  @override
  String get statsFlawless => "Безпомилкові завершення";

  @override
  String get statsTimeSection => "Час";

  @override
  String get statsBestTime => "Найкращий час";

  @override
  String get statsAverageTime => "Середній час";

  @override
  String get statsStreakSection => "Серія";

  @override
  String get statsCurrentStreak => "Поточна серія";

  @override
  String get statsBestStreak => "Найкраща серія";

  @override
  String get difficultyNovice => "Новачок";

  @override
  String get difficultyNoviceShort => "Нов.";

  @override
  String get difficultyMedium => "Середній";

  @override
  String get difficultyMediumShort => "Сер.";

  @override
  String get difficultyHigh => "Високий";

  @override
  String get difficultyHighShort => "Вис.";

  @override
  String get difficultyExpert => "Експерт";

  @override
  String get difficultyExpertShort => "Експ.";

  @override
  String get difficultyMaster => "Майстр";

  @override
  String get difficultyMasterShort => "Майстр.";
}

class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh() : super("zh");

  @override
  String get appTitle => "数独大师";

  @override
  String get navHome => "首页";

  @override
  String get navDaily => "挑战";

  @override
  String get navStats => "统计";

  @override
  String get dailyStreak => "连续天数";

  @override
  String get selectDifficultyTitle => "选择难度";

  @override
  String get selectDifficultyDailyChallenge => "每日挑战";

  @override
  String get playAction => "游玩";

  @override
  String get championshipTitle => "锦标赛";

  @override
  String championshipScore(int score) {
    return "得分 ${score}";
  }

  @override
  String toNextPlace(int points) {
    return "距下一名还差 ${points} 分";
  }

  @override
  String get youAreTop => "您是第 1 名";

  @override
  String get championshipRoundDescriptionPlaceholder => "进行这一轮，推动你的锦标赛征程。";

  @override
  String get championshipRoundCompletedLabel => "已完成";

  @override
  String totalScore(String score) {
    return "总得分：${score}";
  }

  @override
  String get meLabel => "我";

  @override
  String leaderboardRow(int rank, String name, String points) {
    return "第 ${rank} 名。${name}。${points} 分";
  }

  @override
  String yourPosition(int rank, String points) {
    return "我的名次 ${rank}。${points} 分";
  }

  @override
  String get pointsShort => "分";

  @override
  String get championshipAutoScroll => "自动滚动到我的位置";

  @override
  String get bestLabel => "最佳成绩";

  @override
  String get play => "游玩";

  @override
  String get battleTitle => "对战";

  @override
  String battleWinRate(int count) {
    return "胜场 ${count}%";
  }

  @override
  String get battleYouLabel => "你";

  @override
  String get battleVictoryTitle => "你赢了！";

  @override
  String get battleDefeatTitle => "对手获胜";

  @override
  String battleDefeatMessage(String name) {
    return "${name} 比你更快完成了数独。";
  }

  @override
  String get battleSimpleDefeatTitle => "你输了";

  @override
  String get battleExitToMainMenu => "返回主菜单";

  @override
  String get playerFlagSettingTitle => "玩家旗帜";

  @override
  String get selectPlayerFlag => "选择你的旗帜";

  @override
  String get confirmFlagSelectionTitle => "确认你的旗帜";

  @override
  String get confirmFlagSelectionMessage => "你确定要选择这面旗帜吗？你可以稍后在游戏设置中更改你的旗帜。";

  @override
  String get confirmFlagSelectionConfirm => "确认";

  @override
  String get startAction => "开始";

  @override
  String levelHeading(int level, String difficulty) {
    return "等级 ${level} — ${difficulty}";
  }

  @override
  String get rankProgress => "段位进度";

  @override
  String rankLabel(int rank) {
    return "段位 ${rank}";
  }

  @override
  String get newGame => "新游戏";

  @override
  String get continueGame => "继续游戏";

  @override
  String get weeklyProgress => "每周进度";

  @override
  String get rewardsTitle => "奖励";

  @override
  String get rewardNoMistakesTitle => "无错误完成挑战";

  @override
  String rewardExtraHearts(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: "${count} 颗心",
    );
    return "+" + value;
  }

  @override
  String get rewardThreeInRowTitle => "连续完成三次挑战";

  @override
  String get rewardUniqueTrophy => "专属奖杯";

  @override
  String get rewardSevenDayTitle => "保持 7 天连胜";

  @override
  String rewardStars(num count) {
    final value = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: "${count} 颗星",
    );
    return "+" + value;
  }

  @override
  String get todayPuzzle => "今日谜题";

  @override
  String get todayPuzzleDescription => "完成数独即可获得额外奖励并保持连胜。";

  @override
  String get continueAction => "继续";

  @override
  String get adMessage => "广告：寻找隐藏物品！立即游玩。";

  @override
  String get adPlay => "游玩";

  @override
  String get undo => "撤销";

  @override
  String get erase => "清除";

  @override
  String get autoNotes => "自动笔记";

  @override
  String get statusOn => "开启";

  @override
  String get statusOff => "关闭";

  @override
  String get notes => "笔记";

  @override
  String get hint => "提示";

  @override
  String get undoAdTitle => "观看广告以撤销";

  @override
  String get undoAdDescription => "观看短广告即可撤销上一步。";

  @override
  String undoAdCountdown(int seconds) {
    return "广告将在 ${seconds} 秒后结束";
  }

  @override
  String get hintAdTitle => "观看广告以获得提示";

  @override
  String get hintAdDescription => "观看短广告即可获得提示。";

  @override
  String hintAdCountdown(int seconds) {
    return "广告将在 ${seconds} 秒后结束";
  }

  @override
  String get lifeAdTitle => "观看广告以恢复爱心";

  @override
  String get lifeAdDescription => "观看这段短广告以恢复一个红心并继续游戏。";

  @override
  String lifeAdCountdown(int seconds) {
    return "广告将在 ${seconds} 秒后结束";
  }

  @override
  String get gameScreenTitle => "数独";

  @override
  String get noActiveGameMessage => "没有进行中的游戏。返回主界面。";

  @override
  String get victoryTitle => "恭喜！";

  @override
  String victoryMessage(String time) {
    return "在 ${time} 内完成谜题。";
  }

  @override
  String get backToHome => "首页";

  @override
  String get playAnother => "再来一局";

  @override
  String get outOfLivesTitle => "心已用完";

  @override
  String get outOfLivesDescription => "恢复一个红心以继续游戏。";

  @override
  String get restoreLifeAction => "再获得一颗爱心（观看广告）";

  @override
  String get rewardAdUnavailable => "广告目前不可用。";

  @override
  String get cancelAction => "取消";

  @override
  String get settingsTitle => "设置";

  @override
  String get themeSectionTitle => "主题";

  @override
  String get themeWhite => "经典浅色";

  @override
  String get themeCream => "奶油色";

  @override
  String get themeGreen => "薄荷色";

  @override
  String get themeBlack => "深色";

  @override
  String get themePurple => "暗紫色";

  @override
  String get themeFontSize => "字体大小";

  @override
  String get fontSizeExtraSmall => "特小";

  @override
  String get fontSizeSmall => "小";

  @override
  String get fontSizeMedium => "中";

  @override
  String get fontSizeLarge => "大";

  @override
  String get fontSizeExtraLarge => "特大";

  @override
  String get languageSectionTitle => "语言";

  @override
  String get audioSectionTitle => "声音与音乐";

  @override
  String get soundsEffectsLabel => "音效";

  @override
  String get vibrationLabel => "震动";

  @override
  String get miscSectionTitle => "其他";

  @override
  String get howToPlayTitle => "怎么玩";

  @override
  String get howToPlayRowRule => "每一行都要填上1到9且不重复";

  @override
  String get howToPlayColumnRule => "每一列都要填上1到9且不重复";

  @override
  String get howToPlayBoxRule => "每个3×3宫都要填上1到9且不重复";

  @override
  String get howToPlayFooter => "填满所有格子就赢了！";

  @override
  String get howToPlayAction => "知道了";

  @override
  String get championshipLocalSection => "锦标赛（本地）";

  @override
  String get hideCompletedNumbersLabel => "隐藏已用数字";

  @override
  String get aboutApp => "关于";

  @override
  String versionLabel(String version) {
    return "版本 ${version}";
  }

  @override
  String get aboutLegalese => "Nahreba UZOR Inc.";

  @override
  String get languageEnglish => "English";

  @override
  String get languageRussian => "Русский";

  @override
  String get languageUkrainian => "Українська";

  @override
  String get languageGerman => "Deutsch";

  @override
  String get languageFrench => "Français";

  @override
  String get languageChinese => "中文";

  @override
  String get languageHindi => "हिन्दी";

  @override
  String get languageGeorgian => "ქართული";

  @override
  String get languageSpanish => "Español";

  @override
  String get languageItalian => "Italiano";

  @override
  String get languageJapanese => "日本語";

  @override
  String get languageKorean => "한국어";

  @override
  String get export => "导出";

  @override
  String get import => "导入";

  @override
  String get resetMyScore => "重置我的得分";

  @override
  String get resetMyScoreConfirmation => "确定要重置得分吗？此操作无法撤销。";

  @override
  String get resetAction => "重置";

  @override
  String get regenerateOpponents => "重新生成对手";

  @override
  String get confirm => "确认";

  @override
  String get cancel => "取消";

  @override
  String get done => "完成";

  @override
  String get privacyPolicyTitle => "隐私政策";

  @override
  String get privacyPolicyAccept => "我同意";

  @override
  String get privacyPolicyPrompt => "您是否接受隐私政策？";

  @override
  String get privacyPolicyLearnMore => "了解详情 →";

  @override
  String get privacyPolicyDecline => "我不同意";

  @override
  String get privacyPolicyClose => "关闭";

  @override
  String get privacyPolicyLoadError => "无法加载隐私政策。请重试。";

  @override
  String get failed => "失败";

  @override
  String rankBadgeChasing(int current, int delta, int target) {
    return "第 ${current} 名 • 还差 ${delta} 分到第 ${target} 名";
  }

  @override
  String get statsTitle => "统计";

  @override
  String get statsGamesSection => "对局";

  @override
  String get statsGamesStarted => "开始的对局";

  @override
  String get statsGamesWon => "获胜的对局";

  @override
  String get statsWinRate => "胜率";

  @override
  String get statsFlawless => "完美通关";

  @override
  String get statsTimeSection => "时间";

  @override
  String get statsBestTime => "最佳时间";

  @override
  String get statsAverageTime => "平均时间";

  @override
  String get statsStreakSection => "连胜";

  @override
  String get statsCurrentStreak => "当前连胜";

  @override
  String get statsBestStreak => "最高连胜";

  @override
  String get difficultyNovice => "新手";

  @override
  String get difficultyNoviceShort => "新手";

  @override
  String get difficultyMedium => "中等";

  @override
  String get difficultyMediumShort => "中等";

  @override
  String get difficultyHigh => "困难";

  @override
  String get difficultyHighShort => "困难";

  @override
  String get difficultyExpert => "专家";

  @override
  String get difficultyExpertShort => "专家";

  @override
  String get difficultyMaster => "大师";

  @override
  String get difficultyMasterShort => "大师";
}
