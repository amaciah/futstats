import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/pages/home_page.dart';
import 'package:futstats/pages/season_form_page.dart';

class SeasonsPage extends StatelessWidget {
  const SeasonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir temporada'),
      ),
      body: FutureBuilder<List<Season>>(
        future: MyApp.seasonRepo.getAllSeasons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay temporadas disponibles'));
          }

          final seasons = snapshot.data!;
          return ListView.builder(
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              final season = seasons[index];
              return ListTile(
                title: Text('Temporada ${season.date}'),
                onTap: () {
                  MyApp.player.setCurrentSeason(season.id);
                  MyApp.season = season;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SeasonFormPage()),
          ).then(
            (_) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SeasonsPage()),
            ),
          );
        },
      ),
    );
  }
}
