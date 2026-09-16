# Create endpoint to fetch POIs given the buildingId

# Fetch POIs from the backend and show on the building bottom sheet

- Create a function to fetch all POIs given the building id
- Create a new section on the selected building bottom sheet, to show the list of pois (similar to the visual routes).

In the widget map_page.dart, update bottom `SelectedBuildingBottomSheet` to show a list of pois associated to the building. You can update the method `_fetchBuildingVisualRoutes` to the name `_fetchBuildingAcessibilities`, and get the pois from `data['pois']`.

Add a new section to the bottom sheet, to show the list of pois. You can add the title to the section as "Acessibilidade". The visual routes list should still be shown, and you can add the title this list as "Rotas Visuais". In the end, `SelectedBuildingBottomSheet` should show the list of visual routes and pois.

Below is th openapi.yaml describing how the data is returned from the endpoint /buildings/{id}/accessibility.

---

new: com.github.cinatitbr.usp_acessivel
old: com.example.meu_campus_flutter

---

### Criar um tipo de dado para rota visual

### Criar um array de rotas visutais de exemplo

### Exibir rotas visuais na tela

### Create icons in the map for each visual route.

### Show routes stored in the backend

- Fetch all the routes data from the backend (D1 and R2)
- Show each route in the screen, using the widgets in route_page.dart

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
