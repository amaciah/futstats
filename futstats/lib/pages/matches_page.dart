import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/pages/match_details_page.dart';
import 'package:intl/intl.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({
    super.key,
    required this.onReturnToHomePage,
  });

  // Como se diseña como parte de la página principal, la navegación debe
  // proporcionarse como método
  final Function onReturnToHomePage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidos'),
      ),
      body: FutureBuilder<List<Match>>(
        future: MyApp.matchRepo.getAllMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay partidos disponibles'));
          }

          final matches = snapshot.data!;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return ListTile(
                title: Text(match.opponent),
                subtitle: Text(
                    DateFormat.yMd(Localizations.localeOf(context).toString())
                        .format(match.date)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchDetailsPage(match: match),
                    ),
                  ).then((_) => onReturnToHomePage());
                },
              );
            },
          );
        },
      ),
    );
  }
}
