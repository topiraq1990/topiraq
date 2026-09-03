import 'dart:math';

class DiceGame {
  const DiceGame();

  int roll() => Random().nextInt(6) + 1;
}