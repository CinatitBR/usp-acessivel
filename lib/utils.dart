import 'dart:math' as math;
import 'package:maplibre/maplibre.dart';

/// Generates a buffered [Polygon] surrounding a [LineString].
/// [distance] is in the same units as the coordinates (e.g. degrees/meters).
/// [stepsPerCap] controls the smoothness of rounded caps and joins.
Polygon bufferLineString(
  LineString line,
  double distance, {
  int stepsPerCap = 8,
}) {
  // final coords = line.chain.toPositions();
  final coords = line.chain.positions.toList();
  if (coords.length < 2) {
    throw ArgumentError('LineString must have at least 2 points.');
  }

  final leftSide = <Position>[];
  final rightSide = <Position>[];

  // 1. Process intermediate segment offsets & vertex joins
  for (int i = 0; i < coords.length - 1; i++) {
    final p1 = coords[i];
    final p2 = coords[i + 1];

    final dx = p2.x - p1.x;
    final dy = p2.y - p1.y;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) continue;

    // Normal vector perpendicular to the segment (length = distance)
    final nx = (-dy / len) * distance;
    final ny = (dx / len) * distance;

    // Left and right offsets for segment (p1 -> p2)
    final l1 = Position.create(x: p1.x + nx, y: p1.y + ny);
    final l2 = Position.create(x: p2.x + nx, y: p2.y + ny);
    final r1 = Position.create(x: p1.x - nx, y: p1.y - ny);
    final r2 = Position.create(x: p2.x - nx, y: p2.y - ny);

    if (i == 0) {
      leftSide.add(l1);
      rightSide.add(r1);
    } else {
      // Add round join at intermediate vertex on left side
      _addArc(
        leftSide,
        center: p1,
        radius: distance,
        startPoint: leftSide.last,
        endPoint: l1,
        steps: stepsPerCap,
      );
      // Add round join at intermediate vertex on right side
      _addArc(
        rightSide,
        center: p1,
        radius: distance,
        startPoint: rightSide.last,
        endPoint: r1,
        steps: stepsPerCap,
      );
    }

    leftSide.add(l2);
    rightSide.add(r2);
  }

  // 2. Generate semi-circular cap at end point
  final endCap = <Position>[];
  _addArc(
    endCap,
    center: coords.last,
    radius: distance,
    startPoint: leftSide.last,
    endPoint: rightSide.last,
    steps: stepsPerCap,
  );

  // 3. Generate semi-circular cap at start point
  final startCap = <Position>[];
  _addArc(
    startCap,
    center: coords.first,
    radius: distance,
    startPoint: rightSide.first,
    endPoint: leftSide.first,
    steps: stepsPerCap,
  );

  // 4. Combine into a closed polygon ring
  final exteriorRing = <Position>[
    ...leftSide,
    ...endCap,
    ...rightSide.reversed,
    ...startCap,
    leftSide.first, // Close ring
  ];

  return Polygon.build([PositionSeries.from(exteriorRing).values]);
}

/// Helper function to interpolate arc points between [startPoint] and [endPoint]
void _addArc(
  List<Position> target, {
  required Position center,
  required double radius,
  required Position startPoint,
  required Position endPoint,
  required int steps,
}) {
  final startAngle = math.atan2(
    startPoint.y - center.y,
    startPoint.x - center.x,
  );
  var endAngle = math.atan2(endPoint.y - center.y, endPoint.x - center.x);

  // Ensure arc takes shortest angular path
  var sweep = endAngle - startAngle;
  if (sweep > math.pi) sweep -= 2 * math.pi;
  if (sweep < -math.pi) sweep += 2 * math.pi;

  for (int i = 1; i <= steps; i++) {
    final t = i / steps;
    final angle = startAngle + sweep * t;
    target.add(
      Position.create(
        x: center.x + radius * math.cos(angle),
        y: center.y + radius * math.sin(angle),
      ),
    );
  }
}
