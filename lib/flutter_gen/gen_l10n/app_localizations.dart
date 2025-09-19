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
    Locale('fr'),
    Locale('hi'),
    Locale('ru'),
    Locale('uk'),
    Locale('zh'),
  ];

  static const List<String> _supportedLocaleNames = <String>[
    "de",
    "en",
    "fr",
    "hi",
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

  String get championshipRoundDescriptionPlaceholder;

  String get championshipRoundCompletedLabel;

  String totalScore(String score);

  String get meLabel;

  String get play;

  String get battleTitle;

  String battleWinRate(int percent);

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

  String get gameScreenTitle;

  String get noActiveGameMessage;

  String get victoryTitle;

  String victoryMessage(String time);

  String get backToHome;

  String get playAnother;

  String get outOfLivesTitle;

  String get outOfLivesDescription;

  String get restoreLifeAction;

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

  String get musicLabel;

  String get miscSectionTitle;

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
    case "fr":
      return AppLocalizationsFr();
    case "hi":
      return AppLocalizationsHi();
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
    case "fr":
      return AppLocalizationsFr();
    case "hi":
      return AppLocalizationsHi();
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
  String get selectDifficultyDailyChallenge => "Herausforderung";

  @override
  String get playAction => "Spielen";

  @override
  String get championshipTitle => "Meisterschaft";

  @override
  String championshipScore(int score) {
    return "Punktestand ${score}";
  }

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
  String get play => "Spielen";

  @override
  String get battleTitle => "Duell";

  @override
  String battleWinRate(int percent) {
    return "Siegquote ${percent}%";
  }

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
  String get restoreLifeAction => "1 rotes Herz wiederherstellen";

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
  String get musicLabel => "Hintergrundmusik";

  @override
  String get miscSectionTitle => "Sonstiges";

  @override
  String get hideCompletedNumbersLabel => "Verwendete Ziffern ausblenden";

  @override
  String get aboutApp => "Über";

  @override
  String versionLabel(String version) {
    return "Version ${version}";
  }

  @override
  String get aboutLegalese => "© 2025 Sudoku Inc.";

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
  String get selectDifficultyDailyChallenge => "Challenge";

  @override
  String get playAction => "Play";

  @override
  String get championshipTitle => "Championship";

  @override
  String championshipScore(int score) {
    return "Score ${score}";
  }

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
  String get play => "Play";

  @override
  String get battleTitle => "Battle";

  @override
  String battleWinRate(int percent) {
    return "Win rate ${percent}%";
  }

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
  String get restoreLifeAction => "Restore 1 red heart";

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
  String get musicLabel => "Background music";

  @override
  String get miscSectionTitle => "Other";

  @override
  String get hideCompletedNumbersLabel => "Hide completed digits";

  @override
  String get aboutApp => "About";

  @override
  String versionLabel(String version) {
    return "Version ${version}";
  }

  @override
  String get aboutLegalese => "© 2025 Sudoku Inc.";

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
  String get selectDifficultyDailyChallenge => "Défi";

  @override
  String get playAction => "Jouer";

  @override
  String get championshipTitle => "Championnat";

  @override
  String championshipScore(int score) {
    return "Score ${score}";
  }

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
  String get play => "Jouer";

  @override
  String get battleTitle => "Duel";

  @override
  String battleWinRate(int percent) {
    return "Taux de victoire ${percent}%";
  }

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
  String get restoreLifeAction => "Restaurer 1 cœur rouge";

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
  String get musicLabel => "Musique de fond";

  @override
  String get miscSectionTitle => "Autre";

  @override
  String get hideCompletedNumbersLabel => "Masquer les chiffres utilisés";

  @override
  String get aboutApp => "À propos";

  @override
  String versionLabel(String version) {
    return "Version ${version}";
  }

  @override
  String get aboutLegalese => "© 2025 Sudoku Inc.";

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
  String get selectDifficultyDailyChallenge => "चुनौती";

  @override
  String get playAction => "खेलें";

  @override
  String get championshipTitle => "चैम्पियनशिप";

  @override
  String championshipScore(int score) {
    return "स्कोर ${score}";
  }

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
  String get play => "खेलें";

  @override
  String get battleTitle => "बैटल";

  @override
  String battleWinRate(int percent) {
    return "जीत दर ${percent}%";
  }

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
  String get restoreLifeAction => "1 लाल दिल पुनर्स्थापित करें";

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
  String get musicLabel => "पृष्ठभूमि संगीत";

  @override
  String get miscSectionTitle => "अन्य";

  @override
  String get hideCompletedNumbersLabel => "प्रयुक्त अंकों को छुपाएँ";

  @override
  String get aboutApp => "ऐप के बारे में";

  @override
  String versionLabel(String version) {
    return "संस्करण ${version}";
  }

  @override
  String get aboutLegalese => "© 2025 Sudoku Inc.";

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
  String get selectDifficultyDailyChallenge => "Испытание";

  @override
  String get playAction => "Играть";

  @override
  String get championshipTitle => "Чемпионат";

  @override
  String championshipScore(int score) {
    return "Счёт ${score}";
  }

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
  String get play => "Играть";

  @override
  String get battleTitle => "Битва";

  @override
  String battleWinRate(int percent) {
    return "Процент побед ${percent}%";
  }

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
  String get restoreLifeAction => "Восстановить 1 красное сердце";

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
  String get musicLabel => "Фоновая музыка";

  @override
  String get miscSectionTitle => "Другое";

  @override
  String get hideCompletedNumbersLabel => "Убирать использованные цифры";

  @override
  String get aboutApp => "О приложении";

  @override
  String versionLabel(String version) {
    return "Версия ${version}";
  }

  @override
  String get aboutLegalese => "© 2025 Sudoku Inc.";

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
  String get selectDifficultyDailyChallenge => "Виклик";

  @override
  String get playAction => "Грати";

  @override
  String get championshipTitle => "Чемпіонат";

  @override
  String championshipScore(int score) {
    return "Рахунок ${score}";
  }

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
  String get play => "Грати";

  @override
  String get battleTitle => "Битва";

  @override
  String battleWinRate(int percent) {
    return "Відсоток перемог ${percent}%";
  }

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
  String get restoreLifeAction => "Відновити 1 червоне серце";

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
  String get musicLabel => "Фонова музика";

  @override
  String get miscSectionTitle => "Інше";

  @override
  String get hideCompletedNumbersLabel => "Прибирати використані цифри";

  @override
  String get aboutApp => "Про застосунок";

  @override
  String versionLabel(String version) {
    return "Версія ${version}";
  }

  @override
  String get aboutLegalese => "© 2025 Sudoku Inc.";

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
  String get selectDifficultyDailyChallenge => "挑战";

  @override
  String get playAction => "游玩";

  @override
  String get championshipTitle => "锦标赛";

  @override
  String championshipScore(int score) {
    return "得分 ${score}";
  }

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
  String get play => "游玩";

  @override
  String get battleTitle => "对战";

  @override
  String battleWinRate(int percent) {
    return "胜率 ${percent}%";
  }

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
  String get restoreLifeAction => "恢复 1 个红心";

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
  String get musicLabel => "背景音乐";

  @override
  String get miscSectionTitle => "其他";

  @override
  String get hideCompletedNumbersLabel => "隐藏已用数字";

  @override
  String get aboutApp => "关于";

  @override
  String versionLabel(String version) {
    return "版本 ${version}";
  }

  @override
  String get aboutLegalese => "© 2025 Sudoku Inc.";

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
