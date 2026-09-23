enum RouteAccessibilitySeverity {
  warning, // Atenção (irregularidade, desnível moderado)
  severe,  // Barreira crítica (largura incompatível, degraus)
  info,    // Informacional
}

class RouteAccessibilityPoint {
  final String id;
  final String title;
  final double longitude;
  final double latitude;
  final String surfaceType;
  final String regularity;
  final String dimensions;
  final String noise;
  final String iconId;
  final RouteAccessibilitySeverity severity;

  const RouteAccessibilityPoint({
    required this.id,
    required this.title,
    required this.longitude,
    required this.latitude,
    required this.surfaceType,
    required this.regularity,
    required this.dimensions,
    required this.noise,
    required this.iconId,
    required this.severity,
  });

  /// Mocked data specifically for the route from IME to Poli
  static const List<RouteAccessibilityPoint> mockImeToPoliPoints = [
    RouteAccessibilityPoint(
      id: 'ime_poli_point_1',
      title: 'Trecho IME - Travessa C',
      longitude: -46.731597,
      latitude: -23.558584,
      surfaceType: 'Concreto com trechos de asfalto',
      regularity: 'Calçada irregular: raízes de árvore podem atrapalhar a passagem',
      dimensions: 'Largura adequada (~1,60 m)',
      noise: 'Baixo ruído na maior parte do dia',
      iconId: 'accessibility-warning-icon',
      severity: RouteAccessibilitySeverity.warning,
    ),
    RouteAccessibilityPoint(
      id: 'ime_poli_point_2',
      title: 'Acesso Poli / Av. Luciano Gualberto',
      longitude: -46.731967,
      latitude: -23.557672,
      surfaceType: 'Concreto liso',
      regularity: 'Superfície regular e nivelada',
      dimensions: 'Largura apertada (< 80 cm): pode não caber cadeira de rodas',
      noise: 'Há bastante barulho em horários de pico (circulação frequente de ônibus)',
      iconId: 'accessibility-danger-icon',
      severity: RouteAccessibilitySeverity.severe,
    ),
  ];
}
