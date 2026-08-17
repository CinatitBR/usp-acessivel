### Show routes stored in the backend

- Fetch all the routes data from the backend (D1 and R2)
- Shouw each route in the screen, using the widgets in route_page.dart

---

- Optimize data handling
  1. Decide how all the ways (features) should be stored in memory (Map<String, dynamic>, Feature<LineString>...)

- (Refactor) Store selected way buffer on a state. Only clean the source 'selected-way' source if this state is not empty and clicked outside a way.

- Update bufferLineString() in utils.dart to make it similar to turf.buffer() (from the turf js library).

## IDEAS

- Ideia: adicionar sprites com personagens interativos que explicam sobre o mapa, estilo Pokémon.
  - Adiconar vídeo flutuante de pessoa explicando sobre o mapa.

## Image processing

Script to convert .HEIC to .webp (using heif-convert, imagemagick):

```bash
for f in *.HEIC; do heif-convert "$f" "${f%.HEIC}.png" && magick "${f%.HEIC}.png" -quality 80 -resize '1200>' "../rotas-odonto-menor/${f%.HEIC}.webp"; done
```

There's also a Python script to extract GPS data and save to a JSON file. The script will soon be updated to execute all the processing pipeline (conversion + GPS extraction), and will be uploaded to a GitHub repo.
