class GeoJsonFeatureCollection {
  final String type;
  final List<GeoJsonFeature> features;

  GeoJsonFeatureCollection({required this.type, required this.features});

  factory GeoJsonFeatureCollection.fromJson(Map<String, dynamic> json) {
    return GeoJsonFeatureCollection(
      type: json['type'] as String,
      features: (json['features'] as List<dynamic>)
          .map((item) => GeoJsonFeature.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GeoJsonFeature {
  final String type;
  final Geometry geometry;
  final FeatureProperties properties;

  GeoJsonFeature({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory GeoJsonFeature.fromJson(Map<String, dynamic> json) {
    return GeoJsonFeature(
      type: json['type'] as String,
      geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      properties: FeatureProperties.fromJson(
        json['properties'] as Map<String, dynamic>,
      ),
    );
  }
}

class Geometry {
  final String type;
  final List<double> coordinates;

  Geometry({required this.type, required this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => e as double)
          .toList(),
    );
  }
}

class FeatureProperties {
  final String id;
  final String clazz;
  final String name;

  FeatureProperties({
    required this.id,
    required this.clazz,
    required this.name,
  });

  factory FeatureProperties.fromJson(Map<String, dynamic> json) {
    return FeatureProperties(
      id: json['id'] as String,
      clazz: json['class'] as String,
      name: json['name'] as String,
    );
  }
}
