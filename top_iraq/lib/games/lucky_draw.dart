import 'dart:math';

class LuckyDraw {
  const LuckyDraw(this.entries);

  final List<String> entries;

  String draw() => entries[Random().nextInt(entries.length)];
}