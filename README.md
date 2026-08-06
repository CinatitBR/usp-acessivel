This can be compiled into web, android and IOS.

## Tech stack

- [**flutter_maplibre**](https://github.com/josxha/flutter-maplibre): responsible for rendering and style the map, following the [MapLibre specification](https://maplibre.org/maplibre-style-spec/). This package is a modern rewrite of maplibre_gl. Here is a [demo app](https://flutter-maplibre.pages.dev/demo/) showcasing its capabilities, the repository of the demo app with the source code of many examples.
-

## Folder structure

#### `lib/data/`

- Contains data in the [GeoJSON format](https://geojson.org/), representing features (geographic elements) on the map.
- The name of each file represents the kind of data it contains. For example, `ways.json` stores a collection of OSM (OpenStreetmap) ways (streets, highways...).
- Some of this data is written by hand, while others are collected from the OSM database using services like [Overpass Turbo](https://overpass-turbo.eu/).

#### `lib/assets/`

- Contains the assets (images) used in the project.
- `tiles`: The tiles (texture) rendered over surfaces.
- `surface-points/`, `leisure/`: Data related to the two kinds of POIs (Points of Interest).
