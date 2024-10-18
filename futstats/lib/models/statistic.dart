enum StatCategory {
  participation,
  possession,
  attack,
  defense,
  goalkeeping;

  // Getter para obtener el título legible
  String get title {
    switch (this) {
      case StatCategory.participation:
        return "Participación";
      case StatCategory.possession:
        return "Posesión";
      case StatCategory.attack:
        return "Ataque";
      case StatCategory.defense:
        return "Defensa";
      case StatCategory.goalkeeping:
        return "Portería";
    }
  }
}

abstract class Statistic {
  Statistic({
    required this.id,
    required this.title,
    String? shortTitle,
    required this.category,
  }) : shortTitle = shortTitle ?? title;

  final String id;
  final String title;
  final String shortTitle;
  final StatCategory category;

  double get value;

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'shortTitle': shortTitle,
      'category': category.name,
      'value': value,
    };
  }

  factory Statistic.fromMap(Map<String, dynamic> map) {
    return ManualStat(
      id: map['id'],
      title: map['title'],
      shortTitle: map['shortTitle'],
      category: StatCategory.values.byName(map['category']),
      initialValue: map['value'],
    );
  }
}

class ManualStat extends Statistic {
  ManualStat({
    required super.id,
    required super.title,
    super.shortTitle,
    required super.category,
    required double initialValue,
  }) : _value = initialValue;

  // Campo interno para almacenar el valor
  double _value;

  @override
  double get value => _value;

  // Permite modificar el valor
  set value(double newValue) => _value = newValue;
}

class CalculatedStat extends Statistic {
  CalculatedStat({
    required super.id,
    required super.title,
    super.shortTitle,
    required super.category,
    required this.calculationFunction,
  });

  final double Function() calculationFunction;

  @override
  double get value => calculationFunction();
}

class PercentStat extends CalculatedStat {
  PercentStat({
    required super.id,
    required super.title,
    required super.category,
    required super.calculationFunction,
  });
}

// class EmptyStatisticsModel {
//   Map<String, Stat> statistics = createStatisticModel();

//   // HERE: Aquí se definen las estadísticas soportadas por la app
//   static final List<StatTemplate> templates = [
//     // Participación
//     StatTemplate(
//       id: "games_played",
//       title: "Partidos",
//       category: StatCategory.participation,
//     ),
//     StatTemplate(
//       id: "minutes",
//       title: "Minutos",
//       category: StatCategory.participation,
//     ),
//     StatTemplate(
//       id: "wins",
//       title: "Victorias",
//       category: StatCategory.participation,
//     ),
//     StatTemplate(
//       id: "draws",
//       title: "Empates",
//       category: StatCategory.participation,
//     ),
//     StatTemplate(
//       id: "defeats",
//       title: "Derrotas",
//       category: StatCategory.participation,
//     ),
//     StatTemplate(
//       id: "points",
//       title: "Puntos",
//       category: StatCategory.participation,
//     ),
//     StatTemplate(
//       id: "goals_for",
//       title: "Goles a favor",
//       shortTitle: "G. a favor",
//       category: StatCategory.participation,
//     ),
//     StatTemplate(
//       id: "goals_against",
//       title: "Goles en contra",
//       shortTitle: "G. en contra",
//       category: StatCategory.participation,
//     ),
//     StatTemplate(
//       id: "goal_difference",
//       title: "Diferencia de goles",
//       shortTitle: "Dif. goles",
//       category: StatCategory.participation,
//       isManual: false,
//     ),
//     StatTemplate(
//       id: "clean_sheets",
//       title: "Porterías imbatidas",
//       shortTitle: "P. imbatidas",
//       category: StatCategory.participation,
//     ),

//     // Ataque
//     StatTemplate(
//       id: "shot_accuracy",
//       title: "Acierto en tiros",
//       shortTitle: "Ac. tiros",
//       category: StatCategory.attack,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "shots",
//       title: "Tiros totales",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "shots_on_target",
//       title: "Tiros a puerta",
//       shortTitle: "A puerta",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "goals",
//       title: "Goles",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "open_play_goals",
//       title: "Goles en jugada",
//       shortTitle: "G. jugada",
//       category: StatCategory.attack,
//       isManual: false,
//     ),
//     StatTemplate(
//       id: "assists",
//       title: "Asistencias",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "goal_contributions",
//       title: "Contribuciones de gol",
//       shortTitle: "Contrib. gol",
//       category: StatCategory.attack,
//       isManual: false,
//     ),
//     StatTemplate(
//       id: "key_passes",
//       title: "Pases clave",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "penalty_accuracy",
//       title: "Acierto en penaltis",
//       shortTitle: "Ac. penaltis",
//       category: StatCategory.attack,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "penalty_goals",
//       title: "Goles de penalti",
//       shortTitle: "G. penalti",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "penalty_attempts",
//       title: "Penaltis lanzados",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "set_piece_accuracy",
//       title: "Acierto a balón parado",
//       shortTitle: "Ac. balón parado",
//       category: StatCategory.attack,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "set_piece_goals",
//       title: "Goles a balón parado",
//       shortTitle: "G. balón parado",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "set_piece_assists",
//       title: "Asistencias a balón parado",
//       shortTitle: "Asist. balón parado",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "set_piece_attempts",
//       title: "Lanzamientos a balón parado",
//       shortTitle: "Lanz. balón parado",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "cross_accuracy",
//       title: "Acierto en centros",
//       shortTitle: "Ac. centros",
//       category: StatCategory.attack,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "crosses",
//       title: "Centros completados",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "cross_attempts",
//       title: "Centros intentados",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "fouls_received",
//       title: "Faltas recibidas",
//       category: StatCategory.attack,
//     ),
//     StatTemplate(
//       id: "penalties_received",
//       title: "Penaltis recibidos",
//       category: StatCategory.attack,
//     ),

//     // Defensa
//     StatTemplate(
//       id: "tackle_accuracy",
//       title: "Acierto en entradas",
//       shortTitle: "Ac. entradas",
//       category: StatCategory.defense,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "tackles",
//       title: "Entradas exitosas",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "tackle_attempts",
//       title: "Entradas intentadas",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "defensive_actions",
//       title: "Acciones defensivas",
//       shortTitle: "Acc. defensivas",
//       category: StatCategory.defense,
//       isManual: false,
//     ),
//     StatTemplate(
//       id: "blocks",
//       title: "Bloqueos",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "clearances",
//       title: "Despejes",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "interceptions",
//       title: "Intercepciones",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "fouls_commited",
//       title: "Faltas cometidas",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "penalties_commited",
//       title: "Penaltis cometidos",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "cards_received",
//       title: "Tarjetas recibidas",
//       shortTitle: "T. recibidas",
//       category: StatCategory.defense,
//       isManual: false,
//     ),
//     StatTemplate(
//       id: "yellow_cards",
//       title: "Tarjetas amarillas",
//       shortTitle: "T. amarillas",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "second_yellow_cards",
//       title: "Segundas tarjetas",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "red_cards",
//       title: "Taretas rojas",
//       shortTitle: "T. rojas",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "aerial_accuracy",
//       title: "Acierto aéreo",
//       category: StatCategory.defense,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "aerial_duels_won",
//       title: "Duelos aéreos ganados",
//       shortTitle: "D. aéreos ganados",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "aerial_duels_lost",
//       title: "Duelos aéreos perdidos",
//       shortTitle: "D. aéreos perdidos",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "times_dribbled",
//       title: "Veces superado",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "goal_leading_errors",
//       title: "Errores que llevan a gol",
//       shortTitle: "Err. llev. gol",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "own_goals",
//       title: "Goles en propia puerta",
//       shortTitle: "G. propia",
//       category: StatCategory.defense,
//     ),
//     StatTemplate(
//       id: "defensive_accuracy",
//       title: "Balance defensivo",
//       category: StatCategory.defense,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "duels_won",
//       title: "Duelos ganados",
//       category: StatCategory.defense,
//       isManual: false,
//     ),
//     StatTemplate(
//       id: "duels_lost",
//       title: "Duelos perdidos",
//       category: StatCategory.defense,
//       isManual: false,
//     ),

//     // Portería
//     StatTemplate(
//       id: "goals_conceded",
//       title: "Goles encajados",
//       shortTitle: "G. encajados",
//       category: StatCategory.goalkeeping,
//     ),
//     StatTemplate(
//       id: "shot_stopping_accuracy",
//       title: "Acierto en paradas",
//       shortTitle: "Ac. paradas",
//       category: StatCategory.goalkeeping,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "shots_stopped",
//       title: "Paradas",
//       category: StatCategory.goalkeeping,
//     ),
//     StatTemplate(
//       id: "shots_on_target_received",
//       title: "Tiros a puerta recibidos",
//       shortTitle: "T. a puerta recibidos",
//       category: StatCategory.goalkeeping,
//     ),
//     StatTemplate(
//       id: "penalty_stopping_accuracy",
//       title: "Acierto en penaltis",
//       shortTitle: "Ac. penaltis",
//       category: StatCategory.goalkeeping,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "penalties_against_stopped",
//       title: "Penaltis en contra parados",
//       shortTitle: "Pen. contra parados",
//       category: StatCategory.goalkeeping,
//     ),
//     StatTemplate(
//       id: "penalties_against_missed",
//       title: "Penaltis en contra fallados",
//       shortTitle: "Pen. contra fallados",
//       category: StatCategory.goalkeeping,
//     ),
//     StatTemplate(
//       id: "penalties_against_commited",
//       title: "Penaltis en contra cometidos",
//       shortTitle: "Pen. contra cometidos",
//       category: StatCategory.goalkeeping,
//     ),
//     StatTemplate(
//       id: "crosses_intervened",
//       title: "Centros intervenidos",
//       category: StatCategory.goalkeeping,
//       isManual: false,
//     ),
//     StatTemplate(
//       id: "crosses_stopped",
//       title: "Centros atrapados",
//       category: StatCategory.goalkeeping,
//     ),
//     StatTemplate(
//       id: "crosses_cleared",
//       title: "Centros despejados",
//       category: StatCategory.goalkeeping,
//     ),
//     StatTemplate(
//       id: "gk_1v1_accuracy",
//       title: "Acierto en mano a mano",
//       shortTitle: "Ac. mano a mano",
//       category: StatCategory.goalkeeping,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "gk_1v1_won",
//       title: "Mano a mano ganados",
//       shortTitle: "MaM ganados",
//       category: StatCategory.goalkeeping,
//     ),
//     StatTemplate(
//       id: "gk_1v1_lost",
//       title: "Mano a mano perdidos",
//       shortTitle: "MaM perdidos",
//       category: StatCategory.goalkeeping,
//     ),

//     // Posesión
//     StatTemplate(
//       id: "pass_accuracy",
//       title: "Acierto en pases",
//       shortTitle: "Ac. pases",
//       category: StatCategory.possession,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "passes",
//       title: "Pases completados",
//       category: StatCategory.possession,
//     ),
//     StatTemplate(
//       id: "passes_missed",
//       title: "Pases fallados",
//       category: StatCategory.possession,
//     ),
//     StatTemplate(
//       id: "possession_retention",
//       title: "Retención de posesión",
//       shortTitle: "Ret. posesión",
//       category: StatCategory.possession,
//       isManual: false,
//     ),
//     StatTemplate(
//       id: "recoveries",
//       title: "Recuperaciones",
//       category: StatCategory.possession,
//     ),
//     StatTemplate(
//       id: "losses",
//       title: "Pérdidas",
//       category: StatCategory.possession,
//     ),
//     StatTemplate(
//       id: "progressive_passes",
//       title: "Pases progresivos",
//       category: StatCategory.possession,
//     ),
//     StatTemplate(
//       id: "through_balls",
//       title: "Pases al hueco",
//       category: StatCategory.possession,
//     ),
//     StatTemplate(
//       id: "dribble_success",
//       title: "Acierto en regate",
//       shortTitle: "Ac. regate",
//       category: StatCategory.possession,
//       type: StatType.percent,
//     ),
//     StatTemplate(
//       id: "dribbles",
//       title: "Regates exitosos",
//       category: StatCategory.possession,
//     ),
//     StatTemplate(
//       id: "dribble_attempts",
//       title: "Regates intentados",
//       category: StatCategory.possession,
//     ),
//   ];

//   static final Map<String, StatTemplate> templateMap = {
//     for (var template in templates) template.id: template
//   };

//   Map<String, Stat> createStatisticModel() {
//     Map<String, Stat> stats = {
//       for (var template in templates)
//         if (template.isManual) template.id: Stat(template: template, value: 0)
//     };

//     stats.addAll({
//       // Participación
//       'goal_difference': CalculatedStat(
//         template: templateMap['goal_difference']!,
//         calculationFunction: () =>
//             stats['goals_for']!.value + stats['goals_against']!.value,
//       ),

//       // Ataque
//       'shot_accuracy': PercentageStat(
//         template: templateMap['shot_accuracy']!,
//         calculationFunction: () =>
//             stats['shots_on_target']!.value / stats['shots']!.value,
//       ),
//       'open_play_goals': CalculatedStat(
//         template: templateMap['open_play_goals']!,
//         calculationFunction: () =>
//             stats['goals']!.value -
//             stats['set_piece_goals']!.value -
//             stats['penalty_goals']!.value,
//       ),
//       'goal_contributions': CalculatedStat(
//         template: templateMap['goal_contributions']!,
//         calculationFunction: () =>
//             stats['goals']!.value + stats['assists']!.value,
//       ),
//       'penalty_accuracy': PercentageStat(
//         template: templateMap['penalty_accuracy']!,
//         calculationFunction: () =>
//             stats['penalty_goals']!.value / stats['penalty_attempts']!.value,
//       ),
//       'set_piece_accuracy': PercentageStat(
//         template: templateMap['set_piece_accuracy']!,
//         calculationFunction: () =>
//             (stats['set_piece_goals']!.value +
//                 stats['set_piece_assists']!.value) /
//             stats['set_piece_attempts']!.value,
//       ),
//       'cross_accuracy': PercentageStat(
//         template: templateMap['cross_accuracy']!,
//         calculationFunction: () =>
//             stats['crosses']!.value / stats['cross_attempts']!.value,
//       ),

//       // Defensa
//       'tackle_accuracy': PercentageStat(
//         template: templateMap['tackle_accuracy']!,
//         calculationFunction: () =>
//             stats['tackles']!.value / stats['tackle_attempts']!.value,
//       ),
//       'defensive_actions': CalculatedStat(
//         template: templateMap['defensive_actions']!,
//         calculationFunction: () =>
//             stats['blocks']!.value +
//             stats['clearances']!.value +
//             stats['interceptions']!.value,
//       ),
//       'cards_received': CalculatedStat(
//         template: templateMap['cards_received']!,
//         calculationFunction: () =>
//             stats['yellow_cards']!.value +
//             stats['second_yellow_cards']!.value +
//             stats['red_cards']!.value,
//       ),
//       'aerial_accuracy': PercentageStat(
//         template: templateMap['aerial_accuracy']!,
//         calculationFunction: () =>
//             stats['aerial_duels_won']!.value /
//             (stats['aerial_duels_won']!.value +
//                 stats['aerial_duels_lost']!.value),
//       ),
//       'defensive_accuracy': PercentageStat(
//         template: templateMap['defensive_accuracy']!,
//         calculationFunction: () =>
//             stats['duels_won']!.value /
//             (stats['duels_won']!.value + stats['duels_lost']!.value),
//       ),
//       'duels_won': CalculatedStat(
//         template: templateMap['duels_won']!,
//         calculationFunction: () =>
//             stats['defensive_actions']!.value +
//             stats['aerial_duels_won']!.value +
//             stats['recoveries']!.value,
//       ),
//       'duels_lost': CalculatedStat(
//         template: templateMap['duels_lost']!,
//         calculationFunction: () =>
//             stats['fouls_commited']!.value +
//             stats['aerial_duels_lost']!.value +
//             stats['times_dribbled']!.value +
//             stats['losses']!.value,
//       ),

//       // Portería
//       'shot_stopping_accuracy': PercentageStat(
//         template: templateMap['shot_stopping_accuracy']!,
//         calculationFunction: () =>
//             stats['shots_stopped']!.value /
//             stats['shots_on_target_received']!.value,
//       ),
//       'penalty_stopping_accuracy': PercentageStat(
//         template: templateMap['penalty_stopping_accuracy']!,
//         calculationFunction: () =>
//             stats['penalties_against_stopped']!.value /
//             (stats['penalties_against_commited']!.value -
//                 stats['penalties_against_missed']!.value),
//       ),
//       'crosses_intervened': CalculatedStat(
//         template: templateMap['crosses_intervened']!,
//         calculationFunction: () =>
//             stats['crosses_stopped']!.value + stats['crosses_cleared']!.value,
//       ),
//       'gk_1v1_accuracy': PercentageStat(
//         template: templateMap['gk_1v1_accuracy']!,
//         calculationFunction: () =>
//             stats['gk_1v1_won']!.value /
//             (stats['gk_1v1_won']!.value + stats['gk_1v1_lost']!.value),
//       ),

//       // Posesión
//       'pass_accuracy': PercentageStat(
//         template: templateMap['pass_accuracy']!,
//         calculationFunction: () =>
//             stats['passes']!.value /
//             (stats['passes']!.value + stats['passes_missed']!.value),
//       ),
//       'possession_retention': CalculatedStat(
//         template: templateMap['possession_retention']!,
//         calculationFunction: () =>
//             stats['recoveries']!.value / stats['losses']!.value,
//       ),
//       'dribble_success': PercentageStat(
//         template: templateMap['dribble_success']!,
//         calculationFunction: () =>
//             stats['dribbles']!.value / stats['dribble_attempts']!.value,
//       ),
//     });

//     return stats;
//   }
// }
