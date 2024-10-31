import 'package:futstats/main.dart';

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
        return 'Participación';
      case StatCategory.possession:
        return 'Posesión';
      case StatCategory.attack:
        return 'Ataque';
      case StatCategory.defense:
        return 'Defensa';
      case StatCategory.goalkeeping:
        return 'Portería';
    }
  }
}

enum StatValueType {
  integer,
  decimal,
  percent;

  // Método para obtener la representación del valor en texto
  String repr(double value) {
    switch (this) {
      case StatValueType.integer:
        return '${value.toInt()}';
      case StatValueType.decimal:
        return value.toStringAsFixed(2);
      case StatValueType.percent:
        return '${value.toStringAsFixed(1)}%';
    }
  }
}

class Statistic {
  Statistic({
    required this.id,
    required this.value,
  });

  final String id;
  final double value;

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
    };
  }

  factory Statistic.fromMap(Map<String, dynamic> map) {
    return Statistic(
      id: map['id'],
      value: map['value'],
    );
  }
}

class StatTemplate {
  const StatTemplate({
    required this.id,
    required this.title,
    String? shortTitle,
    required this.description,
    required this.category,
    this.type = StatValueType.integer,
  }) : shortTitle = shortTitle ?? title;

  final String id;
  final String title; // Nombre completo de la estadística
  final String shortTitle; // Nombre abreviado
  final String description;
  final StatCategory category;
  final StatValueType type;

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'shortTitle': shortTitle,
      'description': description,
      'category': category.name,
    };
  }

  factory StatTemplate.fromMap(Map<String, dynamic> map) {
    return StatTemplate(
      id: map['id'],
      title: map['title'],
      shortTitle: map['shortTitle'],
      description: map['description'],
      category: StatCategory.values.byName(map['category']),
    );
  }
}

// HERE: Aquí se definen las estadísticas soportadas por la app
abstract class StatTemplates {
  // HERE: Estadísticas manuales
  static final List<StatTemplate> manualTemplateList = [
    // Participación
    StatTemplate(
      id: 'minutes',
      title: 'Minutos',
      description: 'Minutos jugados',
      category: StatCategory.participation,
    ),

    // Ataque
    StatTemplate(
      id: 'shots',
      title: 'Tiros totales',
      description: 'Lanzamientos totales ejecutados',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'shots_on_target',
      title: 'Tiros a puerta',
      shortTitle: 'A puerta',
      description: 'Lanzamientos en dirección a la portería contraria',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'goals',
      title: 'Goles',
      description: 'Goles anotados',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'assists',
      title: 'Asistencias',
      description: 'Asistencias de gol',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'key_passes',
      title: 'Pases clave',
      description: 'Pases que resultan en un tiro a puerta de un compañero',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'penalty_goals',
      title: 'Goles de penalti',
      shortTitle: 'G. penalti',
      description: 'Goles anotados en lanzamientos de penalti',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'penalty_attempts',
      title: 'Penaltis lanzados',
      description: 'Lanzamientos de penalti intentados',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'set_piece_goals',
      title: 'Goles a balón parado',
      shortTitle: 'G. balón parado',
      description:
          'Goles anotados en jugadas de balón parado (excluyendo penaltis)',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'set_piece_assists',
      title: 'Asistencias a balón parado',
      shortTitle: 'Asist. balón parado',
      description: 'Asistencias de gol en jugadas de balón parado',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'set_piece_attempts',
      title: 'Lanzamientos a balón parado',
      shortTitle: 'Lanz. balón parado',
      description: 'Lanzamientos de jugadas de balón parado intentados',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'crosses',
      title: 'Centros completados',
      description: 'Centros al área rival completados',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'cross_attempts',
      title: 'Centros intentados',
      description: 'Centros al área rival intentados',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'fouls_received',
      title: 'Faltas recibidas',
      description: 'Faltas recibidas por el jugador',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'penalties_received',
      title: 'Penaltis recibidos',
      description: 'Penaltis recibidos por el jugador',
      category: StatCategory.attack,
    ),

    // Defensa
    StatTemplate(
      id: 'tackles',
      title: 'Entradas exitosas',
      description:
          'Quites de balón a jugadores rivales, tanto si acaba el balón en posesión como si no',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'tackle_attempts',
      title: 'Entradas intentadas',
      description: 'Intentos de quitar el balón a jugadores rivales',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'blocks',
      title: 'Bloqueos',
      description: 'Tiros rivales bloqueados',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'clearances',
      title: 'Despejes',
      description: 'Balones despejados',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'interceptions',
      title: 'Intercepciones',
      description:
          'Pases rivales interrumpidos para evitar que lleguen a su objetivo',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'fouls_commited',
      title: 'Faltas cometidas',
      description: 'Faltas cometidas sobre jugadores rivales',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'penalties_commited',
      title: 'Penaltis cometidos',
      description: 'Penaltis cometidos sobre jugadores rivales',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'yellow_cards',
      title: 'Tarjetas amarillas',
      shortTitle: 'T. amarillas',
      description: 'Tarjetas amarillas recibidas',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'second_yellow_cards',
      title: 'Segundas tarjetas',
      description: 'Segundas tarjetas amarillas que resultan en expulsión',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'red_cards',
      title: 'Taretas rojas',
      shortTitle: 'T. rojas',
      description: 'Tarjetas rojas directas recibidas',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'aerial_duels_won',
      title: 'Duelos aéreos ganados',
      shortTitle: 'D. aéreos ganados',
      description: 'Saltos de cabeza contra un rival ganados',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'aerial_duels_lost',
      title: 'Duelos aéreos perdidos',
      shortTitle: 'D. aéreos perdidos',
      description: 'Saltos de cabeza contra un rival perdidos',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'times_dribbled',
      title: 'Veces superado',
      description: 'Veces en que un rival supera en regate al jugador',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'goal_leading_errors',
      title: 'Errores que llevan a gol',
      shortTitle: 'Err. llev. gol',
      description: 'Errores que resultan directamente en un gol en contra',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'own_goals',
      title: 'Goles en propia puerta',
      shortTitle: 'G. propia',
      description: 'Goles marcados en la portería propia',
      category: StatCategory.defense,
    ),

    // Portería
    StatTemplate(
      id: 'goals_conceded',
      title: 'Goles encajados',
      shortTitle: 'G. encajados',
      description: 'Goles encajados por el portero',
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: 'shots_stopped',
      title: 'Paradas',
      description: 'Lanzamientos rivales a puerta detenidos',
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: 'shots_on_target_received',
      title: 'Tiros a puerta recibidos',
      shortTitle: 'T. a puerta recibidos',
      description: 'Lanzamientos rivales a puerta recibidos',
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: 'penalties_against_stopped',
      title: 'Penaltis en contra parados',
      shortTitle: 'Pen. contra parados',
      description: 'Lanzamientos de penalti rivales detenidos',
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: 'penalties_against_missed',
      title: 'Penaltis en contra fallados',
      shortTitle: 'Pen. contra fallados',
      description: 'Lanzamientos de penalti fallados por el rival',
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: 'penalties_against_commited',
      title: 'Penaltis en contra cometidos',
      shortTitle: 'Pen. contra cometidos',
      description: 'Penaltis sobre rivales cometidos por el equipo',
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: 'crosses_stopped',
      title: 'Centros atrapados',
      description: 'Centros atrapados por el portero',
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: 'crosses_cleared',
      title: 'Centros despejados',
      description: 'Centros despejados por el portero',
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: 'gk_1v1_won',
      title: 'Mano a mano ganados',
      shortTitle: 'MaM ganados',
      description: 'Duelos contra un jugador rival ganados por el portero',
      category: StatCategory.goalkeeping,
    ),
    StatTemplate(
      id: 'gk_1v1_lost',
      title: 'Mano a mano perdidos',
      shortTitle: 'MaM perdidos',
      description: 'Duelos contra un jugador rival perdidos por el portero',
      category: StatCategory.goalkeeping,
    ),

    // Posesión
    StatTemplate(
      id: 'passes',
      title: 'Pases completados',
      description: 'Pases realizados que alcanzan a un compañero',
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: 'passes_missed',
      title: 'Pases fallados',
      description: 'Pases intentados que no alcanzan a un compañero',
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: 'recoveries',
      title: 'Recuperaciones',
      description: 'Total de balones recuperados',
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: 'losses',
      title: 'Pérdidas',
      description: 'Pérdidas de la posesión de balón',
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: 'progressive_passes',
      title: 'Pases progresivos',
      description: 'Pases que avanzan el ataque completados',
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: 'through_balls',
      title: 'Pases al hueco',
      description: 'Pases que atraviesan líneas defensivas completados',
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: 'dribbles',
      title: 'Regates exitosos',
      description: 'Veces en que se supera a un jugador rival en regate',
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: 'dribble_attempts',
      title: 'Regates intentados',
      description: 'Intentos de superar a un jugador rival en regate',
      category: StatCategory.possession,
    ),
    StatTemplate(
      id: 'progressive_carries',
      title: 'Conducciones',
      description: 'Conducciones de balón que avanzan el ataque',
      category: StatCategory.possession,
    ),
  ];

  // HERE: Estadísticas calculadas
  static final List<StatTemplate> calculatedTemplateList = [
    // Participación
    StatTemplate(
      id: 'goal_difference',
      title: 'Diferencia de goles',
      shortTitle: 'Dif. goles',
      description: 'Diferencia entre goles a favor y en contra',
      category: StatCategory.participation,
    ),

    // Ataque
    StatTemplate(
      id: 'open_play_goals',
      title: 'Goles en jugada',
      shortTitle: 'G. jugada',
      description: 'Goles anotados en jugada abierta',
      category: StatCategory.attack,
    ),
    StatTemplate(
      id: 'goal_contributions',
      title: 'Contribuciones de gol',
      shortTitle: 'Contrib. gol',
      description: 'Suma de goles y asistencias',
      category: StatCategory.attack,
    ),

    // Defensa
    StatTemplate(
      id: 'defensive_actions',
      title: 'Acciones defensivas',
      shortTitle: 'Acc. defensivas',
      description: 'Suma de bloqueos, despejes e intercepciones',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'cards_received',
      title: 'Tarjetas recibidas',
      shortTitle: 'T. recibidas',
      description: 'Total de tarjetas recibidas',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'duels_won',
      title: 'Duelos ganados',
      description:
          'Suma de acciones defensivas, duelos aéreos ganados y recuperaciones',
      category: StatCategory.defense,
    ),
    StatTemplate(
      id: 'duels_lost',
      title: 'Duelos perdidos',
      description:
          'Suma de veces superado, duelos aéreos perdidos, faltas cometidas y pérdidas',
      category: StatCategory.defense,
    ),

    // Portería
    StatTemplate(
      id: 'crosses_intervened',
      title: 'Centros intervenidos',
      description: 'Centros atrapados o despejados por el portero',
      category: StatCategory.goalkeeping,
    ),

    // Posesión
    StatTemplate(
      id: 'possession_retention',
      title: 'Retención de posesión',
      shortTitle: 'Ret. posesión',
      description:
          'Índice de retención de posesión de balón (+: más recuperaciones, -: más pérdidas)',
      category: StatCategory.possession,
      type: StatValueType.decimal,
    ),
  ];

  // HERE: Estadísticas porcentuales
  static final List<StatTemplate> percentTemplateList = [
    // Ataque
    StatTemplate(
      id: 'shot_accuracy',
      title: 'Acierto en tiros',
      shortTitle: 'Ac. tiros',
      description: 'Porcentaje de tiros a puerta sobre tiros totales',
      category: StatCategory.attack,
      type: StatValueType.percent,
    ),
    StatTemplate(
      id: 'penalty_accuracy',
      title: 'Acierto en penaltis',
      shortTitle: 'Ac. penaltis',
      description: 'Porcentaje de penaltis marcados sobre penaltis lanzados',
      category: StatCategory.attack,
      type: StatValueType.percent,
    ),
    StatTemplate(
      id: 'set_piece_accuracy',
      title: 'Acierto a balón parado',
      shortTitle: 'Ac. balón parado',
      description: 'Porcentaje de jugadas a balón parado con gol o asistencia',
      category: StatCategory.attack,
      type: StatValueType.percent,
    ),
    StatTemplate(
      id: 'cross_accuracy',
      title: 'Acierto en centros',
      shortTitle: 'Ac. centros',
      description: 'Porcentaje de centros completados sobre centros intentados',
      category: StatCategory.attack,
      type: StatValueType.percent,
    ),

    // Defensa
    StatTemplate(
      id: 'tackle_accuracy',
      title: 'Acierto en entradas',
      shortTitle: 'Ac. entradas',
      description: 'Porcentaje de entradas exitosas sobre entradas intentadas',
      category: StatCategory.defense,
      type: StatValueType.percent,
    ),
    StatTemplate(
      id: 'aerial_accuracy',
      title: 'Acierto aéreo',
      description: 'Porcentaje de duelos aéreos ganados sobre totales',
      category: StatCategory.defense,
      type: StatValueType.percent,
    ),
    StatTemplate(
      id: 'defensive_accuracy',
      title: 'Balance defensivo',
      description: 'Porcentaje de duelos ganados sobre totales',
      category: StatCategory.defense,
      type: StatValueType.percent,
    ),

    // Portería
    StatTemplate(
      id: 'shot_stopping_accuracy',
      title: 'Acierto en paradas',
      shortTitle: 'Ac. paradas',
      description: 'Porcentaje de tiros a puerta detenidos sobre recibidos',
      category: StatCategory.goalkeeping,
      type: StatValueType.percent,
    ),
    StatTemplate(
      id: 'penalty_stopping_accuracy',
      title: 'Acierto en penaltis',
      shortTitle: 'Ac. penaltis',
      description:
          'Porcentaje de penaltis en contra detenidos sobre intentos a puerta',
      category: StatCategory.goalkeeping,
      type: StatValueType.percent,
    ),
    StatTemplate(
      id: 'gk_1v1_accuracy',
      title: 'Acierto en mano a mano',
      shortTitle: 'Ac. mano a mano',
      description:
          'Porcentaje de duelos contra un jugador rival ganados por el portero sobre el total',
      category: StatCategory.goalkeeping,
      type: StatValueType.percent,
    ),

    // Posesión
    StatTemplate(
      id: 'pass_accuracy',
      title: 'Acierto en pases',
      shortTitle: 'Ac. pases',
      description: 'Porcentaje de pases completados sobre el total de intentos',
      category: StatCategory.possession,
      type: StatValueType.percent,
    ),
    StatTemplate(
      id: 'dribble_success',
      title: 'Acierto en regate',
      shortTitle: 'Ac. regate',
      description: 'Porcentaje de regates exitosos sobre intentados',
      category: StatCategory.possession,
      type: StatValueType.percent,
    ),
  ];

  static final List<StatTemplate> seasonTemplateList = [
    StatTemplate(
      id: 'games_played',
      title: 'Partidos',
      description: 'Partidos jugados',
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: 'wins',
      title: 'Victorias',
      description: 'Partidos ganados en los que participó',
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: 'draws',
      title: 'Empates',
      description: 'Partidos empatados en los que participó',
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: 'defeats',
      title: 'Derrotas',
      description: 'Partidos perdidos en los que participó',
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: 'points',
      title: 'Puntos',
      description: 'Puntos acumulados en partidos jugados',
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: 'goals_for',
      title: 'Goles a favor',
      shortTitle: 'G. a favor',
      description: 'Goles anotados por el equipo en partidos jugados',
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: 'goals_against',
      title: 'Goles en contra',
      shortTitle: 'G. en contra',
      description: 'Goles encajados por el equipo en partidos jugados',
      category: StatCategory.participation,
    ),
    StatTemplate(
      id: 'clean_sheets',
      title: 'Porterías imbatidas',
      shortTitle: 'P. imbatidas',
      description: 'Partidos jugados sin que el equipo encaje goles',
      category: StatCategory.participation,
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

  static final Map<String, StatTemplate> seasonTemplates = {
    for (var template in seasonTemplateList) template.id: template
  };

  static final Map<String, StatTemplate> allMatchTemplates = {}
    ..addAll(manualTemplates)
    ..addAll(calculatedTemplates)
    ..addAll(percentTemplates);

  static final Map<String, StatTemplate> allSeasonTemplates = {}
    ..addAll(seasonTemplates)
    ..addAll(allMatchTemplates);

  static final List<String> manualStatIds = manualTemplates.keys.toList();
  static final List<String> calculatedStatIds =
      calculatedTemplates.keys.toList();
  static final List<String> percentStatIds = percentTemplates.keys.toList();
  static final List<String> allMatchStatIds = allMatchTemplates.keys.toList();
  static final List<String> allSeasonStatIds = allSeasonTemplates.keys.toList();

  static StatTemplate getTemplateById(String id) => allSeasonTemplates[id]!;
}

// HERE: Aquí se definen las fórmulas para las estadísticas calculadas
abstract class StatFormulas {
  // HERE: Fórmulas de partido
  static final Map<String, double Function(Map<String, double>)> matchFormulas =
      {
    // Ataque
    'shot_accuracy': (Map<String, double> stats) {
      double onTarget = stats['shots_on_target'] ?? 0;
      double shots = stats['shots'] ?? 0;
      return shots > 0 ? onTarget / shots * 100 : 0;
    },
    'open_play_goals': (Map<String, double> stats) =>
        (stats['goals'] ?? 0) -
        (stats['set_piece_goals'] ?? 0) -
        (stats['penalty_goals'] ?? 0),
    'goal_contributions': (Map<String, double> stats) =>
        (stats['goals'] ?? 0) + (stats['assists'] ?? 0),
    'penalty_accuracy': (Map<String, double> stats) {
      double goals = stats['penalty_goals'] ?? 0;
      double attempts = stats['penalty_attempts'] ?? 0;
      return attempts > 0 ? goals / attempts * 100 : 0;
    },
    'set_piece_accuracy': (Map<String, double> stats) {
      double goals = stats['set_piece_goals'] ?? 0;
      double assists = stats['set_piece_assists'] ?? 0;
      double attempts = stats['set_piece_attempts'] ?? 0;
      return attempts > 0 ? (goals + assists) / attempts * 100 : 0;
    },
    'cross_accuracy': (Map<String, double> stats) {
      double crosses = stats['crosses'] ?? 0;
      double attempts = stats['cross_attempts'] ?? 0;
      return attempts > 0 ? crosses / attempts * 100 : 0;
    },

    // Defensa
    'tackle_accuracy': (Map<String, double> stats) {
      double tackles = stats['tackles'] ?? 0;
      double attempts = stats['tackle_attempts'] ?? 0;
      return attempts > 0 ? tackles / attempts * 100 : 0;
    },
    'defensive_actions': (Map<String, double> stats) =>
        (stats['blocks'] ?? 0) +
        (stats['clearances'] ?? 0) +
        (stats['interceptions'] ?? 0),
    'cards_received': (Map<String, double> stats) =>
        (stats['yellow_cards'] ?? 0) +
        (stats['second_yellow_cards'] ?? 0) +
        (stats['red_cards'] ?? 0),
    'aerial_accuracy': (Map<String, double> stats) {
      double won = stats['aerial_duels_won'] ?? 0;
      double lost = stats['aerial_duels_lost'] ?? 0;
      double total = won + lost;
      return total > 0 ? won / total * 100 : 0;
    },
    'duels_won': (Map<String, double> stats) =>
        (stats['defensive_actions'] ?? 0) +
        (stats['aerial_duels_won'] ?? 0) +
        (stats['recoveries'] ?? 0),
    'duels_lost': (Map<String, double> stats) =>
        (stats['fouls_commited'] ?? 0) +
        (stats['aerial_duels_lost'] ?? 0) +
        (stats['times_dribbled'] ?? 0) +
        (stats['losses'] ?? 0),
    // Depende de las anteriores
    'defensive_accuracy': (Map<String, double> stats) {
      double won = stats['duels_won'] ?? 0;
      double lost = stats['duels_lost'] ?? 0;
      double total = won + lost;
      return total > 0 ? won / total * 100 : 0;
    },

    // Portería
    'shot_stopping_accuracy': (Map<String, double> stats) {
      double stopped = stats['shots_stopped'] ?? 0;
      double received = stats['shots_on_target_received'] ?? 0;
      return received > 0 ? stopped / received * 100 : 0;
    },
    'penalty_stopping_accuracy': (Map<String, double> stats) {
      double stopped = stats['penalties_against_stopped'] ?? 0;
      double commited = stats['penalties_against_commited'] ?? 0;
      double missed = stats['penalties_against_missed'] ?? 0;
      double received = commited - missed;
      return received > 0 ? stopped / received * 100 : 0;
    },
    'crosses_intervened': (Map<String, double> stats) =>
        (stats['crosses_stopped'] ?? 0) + (stats['crosses_cleared'] ?? 0),
    'gk_1v1_accuracy': (Map<String, double> stats) {
      double won = stats['gk_1v1_won'] ?? 0;
      double lost = stats['gk_1v1_lost'] ?? 0;
      double total = won + lost;
      return total > 0 ? won / total * 100 : 0;
    },

    // Posesión
    'pass_accuracy': (Map<String, double> stats) {
      double passes = stats['passes'] ?? 0;
      double missed = stats['passes_missed'] ?? 0;
      double total = passes + missed;
      return total > 0 ? passes / total * 100 : 0;
    },
    'possession_retention': (Map<String, double> stats) {
      double recoveries = stats['recoveries'] ?? 0;
      double losses = stats['losses'] ?? 0;
      return losses > 0
          ? recoveries / losses - 1
          : recoveries > 0
              ? double.infinity
              : 0;
    },
    'dribble_success': (Map<String, double> stats) {
      double dribbles = stats['dribbles'] ?? 0;
      double attempts = stats['dribble_attempts'] ?? 0;
      return attempts > 0 ? dribbles / attempts * 100 : 0;
    },
  };

  // HERE: Fórmulas de temporada
  static final Map<String, double Function(Map<String, double>)>
      seasonFormulas = {
    // Participación
    'goal_difference': (Map<String, double> stats) =>
        (stats['goals_for'] ?? 0) - (stats['goals_against'] ?? 0),
  };

  static final Map<String, double Function(Map<String, double>)> allFormulas =
      {}
        ..addAll(matchFormulas)
        ..addAll(seasonFormulas);

  static double Function(Map<String, double>) getFormulaById(String statId) =>
      allFormulas[statId]!;

  static void calculateMatchStats(Map<String, double> stats) {
    matchFormulas.forEach((statId, formula) {
      stats[statId] = formula(stats);
    });
  }

  static void calculateSeasonStats(Map<String, double> stats) {
    // Actualizar stats para poder calcular fórmulas que dependen de otros cálculos
    matchFormulas.forEach((statId, formula) {
      var value = formula(stats);
      stats[statId] = value;
      MyApp.statsRepo.setStatistic(Statistic(id: statId, value: value));
    });
    seasonFormulas.forEach((statId, formula) {
      var value = formula(stats);
      stats[statId] = value;
      MyApp.statsRepo.setStatistic(Statistic(id: statId, value: value));
    });
  }
}
