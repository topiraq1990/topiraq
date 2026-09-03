import 'dart:math';

class LuckyWheel {
  const LuckyWheel(this.prizes);

  final List<String> prizes;

  String spin() => prizes[Random().nextInt(prizes.length)];
}