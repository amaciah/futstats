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

class StatTemplate {
  const StatTemplate({
    required this.id,
    required this.title,
    String? shortTitle,
    required this.category,
  }) : shortTitle = shortTitle ?? title;

  final String id;
  final String title; // Nombre completo de la estadística
  final String shortTitle; // Nombre abreviado
  final StatCategory category;

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'shortTitle': shortTitle,
      'category': category.name,
    };
  }

  factory StatTemplate.fromMap(Map<String, dynamic> map) {
    return StatTemplate(
      id: map['id'],
      title: map['title'],
      shortTitle: map['shortTitle'],
      category: StatCategory.values.byName(map['category']),
    );
  }
}

abstract class Statistic {
  Statistic({
    required this.id,
  });

  final String id;

  double get value;

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
    };
  }

  factory Statistic.fromMap(Map<String, dynamic> map) {
    return ManualStat(
      id: map['id'],
      initialValue: map['value'],
    );
  }
}

class ManualStat extends Statistic {
  ManualStat({
    required super.id,
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
    required this.calculationFunction,
  });

  final double Function() calculationFunction;

  @override
  double get value => calculationFunction();
}

class PercentStat extends CalculatedStat {
  PercentStat({
    required super.id,
    required super.calculationFunction,
  });
}

// HERE: Aquí se definen las estadísticas soportadas por la app
class StatTemplates {
  // HERE: Estadísticas manuales
  static final List<StatTemplate> manualTemplateList = [
    // Participación
    StatTemplate(
      id: "games_played",
      title: "Partidos",
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: "minutes",
      title: "Minutos",
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: "wins",
      title: "Victorias",
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: "draws",
      title: "Empates",
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: "defeats",
      title: "Derrotas",
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: "points",
      title: "Puntos",
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: "goals_for",
      title: "Goles a favor",
      shortTitle: "G. a favor",
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: "goals_against",
      title: "Goles en contra",
      shortTitle: "G. en contra",
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: "clean_sheets",
      title: "Porterías imbatidas",
      shortTitle: "P. imbatidas",
      category: StatCategory.participation,
    ),

    // Ataque
    StatTemplate(
      id: "shots",
      title: "Tiros totales",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "shots_on_target",
      title: "Tiros a puerta",
      shortTitle: "A puerta",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "goals",
      title: "Goles",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "assists",
      title: "Asistencias",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "key_passes",
      title: "Pases clave",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "penalty_goals",
      title: "Goles de penalti",
      shortTitle: "G. penalti",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "penalty_attempts",
      title: "Penaltis lanzados",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "set_piece_goals",
      title: "Goles a balón parado",
      shortTitle: "G. balón parado",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "set_piece_assists",
      title: "Asistencias a balón parado",
      shortTitle: "Asist. balón parado",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "set_piece_attempts",
      title: "Lanzamientos a balón parado",
      shortTitle: "Lanz. balón parado",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "crosses",
      title: "Centros completados",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "cross_attempts",
      title: "Centros intentados",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "fouls_received",
      title: "Faltas recibidas",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "penalties_received",
      title: "Penaltis recibidos",
      category: StatCategory.attack,
    ),

    // Defensa
    StatTemplate(
      id: "tackles",
      title: "Entradas exitosas",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "tackle_attempts",
      title: "Entradas intentadas",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "blocks",
      title: "Bloqueos",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "clearances",
      title: "Despejes",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "interceptions",
      title: "Intercepciones",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "fouls_commited",
      title: "Faltas cometidas",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "penalties_commited",
      title: "Penaltis cometidos",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "yellow_cards",
      title: "Tarjetas amarillas",
      shortTitle: "T. amarillas",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "second_yellow_cards",
      title: "Segundas tarjetas",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "red_cards",
      title: "Taretas rojas",
      shortTitle: "T. rojas",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "aerial_duels_won",
      title: "Duelos aéreos ganados",
      shortTitle: "D. aéreos ganados",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "aerial_duels_lost",
      title: "Duelos aéreos perdidos",
      shortTitle: "D. aéreos perdidos",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "times_dribbled",
      title: "Veces superado",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "goal_leading_errors",
      title: "Errores que llevan a gol",
      shortTitle: "Err. llev. gol",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "own_goals",
      title: "Goles en propia puerta",
      shortTitle: "G. propia",
      category: StatCategory.defense,
    ),

    // Portería
    StatTemplate(
      id: "goals_conceded",
      title: "Goles encajados",
      shortTitle: "G. encajados",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "shots_stopped",
      title: "Paradas",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "shots_on_target_received",
      title: "Tiros a puerta recibidos",
      shortTitle: "T. a puerta recibidos",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "penalties_against_stopped",
      title: "Penaltis en contra parados",
      shortTitle: "Pen. contra parados",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "penalties_against_missed",
      title: "Penaltis en contra fallados",
      shortTitle: "Pen. contra fallados",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "penalties_against_commited",
      title: "Penaltis en contra cometidos",
      shortTitle: "Pen. contra cometidos",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "crosses_stopped",
      title: "Centros atrapados",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "crosses_cleared",
      title: "Centros despejados",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "gk_1v1_won",
      title: "Mano a mano ganados",
      shortTitle: "MaM ganados",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "gk_1v1_lost",
      title: "Mano a mano perdidos",
      shortTitle: "MaM perdidos",
      category: StatCategory.goalkeeping,
    ),

    // Posesión
    StatTemplate(
      id: "passes",
      title: "Pases completados",
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: "passes_missed",
      title: "Pases fallados",
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: "recoveries",
      title: "Recuperaciones",
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: "losses",
      title: "Pérdidas",
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: "progressive_passes",
      title: "Pases progresivos",
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: "through_balls",
      title: "Pases al hueco",
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: "dribbles",
      title: "Regates exitosos",
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: "dribble_attempts",
      title: "Regates intentados",
      category: StatCategory.possession,
    ),
  ];

  // HERE: Estadísticas calculadas
  static final List<StatTemplate> calculatedTemplateList = [
    // Participación
    StatTemplate(
      id: "goal_difference",
      title: "Diferencia de goles",
      shortTitle: "Dif. goles",
      category: StatCategory.participation,
    ),

    // Ataque
    StatTemplate(
      id: "open_play_goals",
      title: "Goles en jugada",
      shortTitle: "G. jugada",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "goal_contributions",
      title: "Contribuciones de gol",
      shortTitle: "Contrib. gol",
      category: StatCategory.attack,
    ),

    // Defensa
    StatTemplate(
      id: "defensive_actions",
      title: "Acciones defensivas",
      shortTitle: "Acc. defensivas",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "cards_received",
      title: "Tarjetas recibidas",
      shortTitle: "T. recibidas",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "duels_won",
      title: "Duelos ganados",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "duels_lost",
      title: "Duelos perdidos",
      category: StatCategory.defense,
    ),

    // Portería
    StatTemplate(
      id: "crosses_intervened",
      title: "Centros intervenidos",
      category: StatCategory.goalkeeping,
    ),

    // Posesión
    StatTemplate(
      id: "possession_retention",
      title: "Retención de posesión",
      shortTitle: "Ret. posesión",
      category: StatCategory.possession,
    ),
  ];

  // HERE: Estadísticas porcentuales
  static final List<StatTemplate> percentTemplateList = [
    // Ataque
    StatTemplate(
      id: "shot_accuracy",
      title: "Acierto en tiros",
      shortTitle: "Ac. tiros",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "penalty_accuracy",
      title: "Acierto en penaltis",
      shortTitle: "Ac. penaltis",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "set_piece_accuracy",
      title: "Acierto a balón parado",
      shortTitle: "Ac. balón parado",
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: "cross_accuracy",
      title: "Acierto en centros",
      shortTitle: "Ac. centros",
      category: StatCategory.attack,
    ),

    // Defensa
    StatTemplate(
      id: "tackle_accuracy",
      title: "Acierto en entradas",
      shortTitle: "Ac. entradas",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "aerial_accuracy",
      title: "Acierto aéreo",
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: "defensive_accuracy",
      title: "Balance defensivo",
      category: StatCategory.defense,
    ),

    // Portería
    StatTemplate(
      id: "shot_stopping_accuracy",
      title: "Acierto en paradas",
      shortTitle: "Ac. paradas",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "penalty_stopping_accuracy",
      title: "Acierto en penaltis",
      shortTitle: "Ac. penaltis",
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: "gk_1v1_accuracy",
      title: "Acierto en mano a mano",
      shortTitle: "Ac. mano a mano",
      category: StatCategory.goalkeeping,
    ),

    // Posesión
    StatTemplate(
      id: "pass_accuracy",
      title: "Acierto en pases",
      shortTitle: "Ac. pases",
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: "dribble_success",
      title: "Acierto en regate",
      shortTitle: "Ac. regate",
      category: StatCategory.possession,
    ),
  ];

  static final Map<String, StatTemplate> manualTemplates = {
    for (var template in manualTemplateList) template.id: template
  };

  static final Map<String, StatTemplate> calculatedTemplates = {
    for (var template in calculatedTemplateList) template.id: template
  };

  static final Map<String, StatTemplate> percentTemplates = {
    for (var template in percentTemplateList) template.id: template
  };

  static final Map<String, StatTemplate> allTemplates = {}
    ..addAll(manualTemplates)
    ..addAll(calculatedTemplates)
    ..addAll(percentTemplates);

  static StatTemplate getTemplateById(String id) => allTemplates[id]!;
}

class StatFormulas {
  static final Map<String, double Function(Map<String, double>)> formulas = {
    // Participación
    'goal_difference': (Map<String, double> stats) =>
        stats['goals_for']! - stats['goals_against']!,

    // Ataque
    'shot_accuracy': (Map<String, double> stats) =>
        stats['shots_on_target']! / stats['shots']!,
    'open_play_goals': (Map<String, double> stats) =>
        stats['goals']! - stats['set_piece_goals']! - stats['penalty_goals']!,
    'goal_contributions': (Map<String, double> stats) =>
        stats['goals']! + stats['assists']!,
    'penalty_accuracy': (Map<String, double> stats) =>
        stats['penalty_goals']! / stats['penalty_attempts']!,
    'set_piece_accuracy': (Map<String, double> stats) =>
        (stats['set_piece_goals']! + stats['set_piece_assists']!) /
        stats['set_piece_attempts']!,
    'cross_accuracy': (Map<String, double> stats) =>
        stats['crosses']! / stats['cross_attempts']!,

    // Defensa
    'tackle_accuracy': (Map<String, double> stats) =>
        stats['tackles']! / stats['tackle_attempts']!,
    'defensive_actions': (Map<String, double> stats) =>
        stats['blocks']! + stats['clearances']! + stats['interceptions']!,
    'cards_received': (Map<String, double> stats) =>
        stats['yellow_cards']! +
        stats['second_yellow_cards']! +
        stats['red_cards']!,
    'aerial_accuracy': (Map<String, double> stats) =>
        stats['aerial_duels_won']! /
        (stats['aerial_duels_won']! + stats['aerial_duels_lost']!),
    'defensive_accuracy': (Map<String, double> stats) =>
        stats['duels_won']! / (stats['duels_won']! + stats['duels_lost']!),
    'duels_won': (Map<String, double> stats) =>
        stats['defensive_actions']! +
        stats['aerial_duels_won']! +
        stats['recoveries']!,
    'duels_lost': (Map<String, double> stats) =>
        stats['fouls_commited']! +
        stats['aerial_duels_lost']! +
        stats['times_dribbled']! +
        stats['losses']!,

    // Portería
    'shot_stopping_accuracy': (Map<String, double> stats) =>
        stats['shots_stopped']! / stats['shots_on_target_received']!,
    'penalty_stopping_accuracy': (Map<String, double> stats) =>
        stats['penalties_against_stopped']! /
        (stats['penalties_against_commited']! -
            stats['penalties_against_missed']!),
    'crosses_intervened': (Map<String, double> stats) =>
        stats['crosses_stopped']! + stats['crosses_cleared']!,
    'gk_1v1_accuracy': (Map<String, double> stats) =>
        stats['gk_1v1_won']! / (stats['gk_1v1_won']! + stats['gk_1v1_lost']!),

    // Posesión
    'pass_accuracy': (Map<String, double> stats) =>
        stats['passes']! / (stats['passes']! + stats['passes_missed']!),
    'possession_retention': (Map<String, double> stats) =>
        stats['recoveries']! / stats['losses']!,
    'dribble_success': (Map<String, double> stats) =>
        stats['dribbles']! / stats['dribble_attempts']!,
  };

  static double Function(Map<String, double>) getFormulaById(String statId) =>
      formulas[statId]!;
}
