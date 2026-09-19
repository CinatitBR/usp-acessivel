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

## 🛠️ Environment Setup & Flavors

This project manages environment variables across multiple environments (Development and Production). Because these files contain sensitive API keys, they are ignored by Git and not committed to the repository.

To get the project running locally, you must initialize your local environment files from the provided templates.

### 1. Create your local configuration files

Duplicate the template file provided in the root directory to create both your development and production configurations:

```bash
# Create development environment file
cp .env.example .env.development

# Create production environment file
cp .env.example .env.production
```

### 2. Add your API Keys

Open both `.env.development` and `.env.production` and replace the placeholder values with your respective environment keys (e.g., test variables in development, live production credentials in production):

- **BASE_URL**: The main backend API URL (e.g., `https://example.com`). **Do not include a trailing slash.**
- **STORAGE_BASE_URL**: The cloud storage bucket endpoint for user media assets. **Do not include a trailing slash.**
- **OPEN_ROUTE_SERVICE_API_KEY**: Retrieve your routing engine key from the [OpenRouteService Dashboard](https://openrouteservice.org). Remember to apply IP or HTTP referrer restrictions for your production keys.

> ⚠️ **Important**: Never commit `.env.development` or `.env.production` to Git. If you introduce a new variable, remember to update the public `.env.example` file with the corresponding placeholder.
