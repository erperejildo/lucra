import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../main.dart';
import '../tour_target.dart';

class Tutorial {
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey navigationBalances;
  GlobalKey incomeCard;
  GlobalKey expenseCard;
  GlobalKey addButton;

  Tutorial({
    required this.navigationBalances,
    required this.incomeCard,
    required this.expenseCard,
    required this.addButton,
  });

  check(BuildContext context) async {
    final shownTutorial = prefs.getBool('shownTutorial');
    if (shownTutorial is! bool) return prefs.setBool('shownTutorial', false);
    if (shownTutorial) return;
    prefs.setBool('shownTutorial', true);
    show(context);
  }

  show(BuildContext context) {
    tutorialCoachMark = TutorialCoachMark(
      targets: landingPageTargets(
        navigationBalances: navigationBalances,
        incomeCard: incomeCard,
        expenseCard: expenseCard,
        addButton: addButton,
      ),
      colorShadow: Colors.blue[900]!,
      textSkip: translate('slides.skip').toUpperCase(),
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onClickTarget: (target) {
        // Check if the clicked target is the one you want to perform a specific action for
        if (target.identify == "expenseCard") {
          // TODO: refactor this without duplicating this code
        }
      },
    );
    tutorialCoachMark.show(context: context);
  }
}
