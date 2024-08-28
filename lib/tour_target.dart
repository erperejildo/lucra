import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> targets = [];

List<TargetFocus> landingPageTargets({
  required GlobalKey navigationBalances,
  required GlobalKey incomeCard,
  required GlobalKey expenseCard,
}) {
  targets.clear();

  targets.add(
    TargetFocus(
      keyTarget: navigationBalances,
      alignSkip: Alignment.bottomRight,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "This is your balances page. In here, you will find different and regular incomes and expenses.\n\nWe created a couple of them as an example.",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: incomeCard,
      identify: 'incomeCard',
      alignSkip: Alignment.bottomRight,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Green cards are incomes. These cards could be salary, payments or any other positive profit.\n\nYou can see name, total amount, frequency and date.",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: expenseCard,
      identify: 'expenseCard',
      alignSkip: Alignment.bottomRight,
      enableOverlayTab: false,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Same thing with the expenses. These ones could be mortgage, subscriptions, payments or any other negative profit.\n\nThe details are similar to incomes.\n\nClick this expense to see its details.",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );

  return targets;
}
