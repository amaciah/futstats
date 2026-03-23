import 'package:flutter/material.dart';
import 'package:futstats/models/match.dart';

class MatchResultDisplay extends StatelessWidget {
  const MatchResultDisplay({
    super.key,
    required this.match,
  });

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: match.result.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${match.goalsFor} - ${match.goalsAgainst}',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
