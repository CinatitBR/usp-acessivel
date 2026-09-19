import 'package:usp_acessivel/features/poi/services/poi_service.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:geolocator/geolocator.dart';
import 'package:usp_acessivel/features/map/models/building_model.dart';
import 'package:usp_acessivel/features/map/repositories/building_repository.dart';

enum PoiCategory { elevator, bathroom, ramp, bus, other }

class CreatePoiPage extends StatefulWidget {
  const CreatePoiPage({super.key});

  @override
  State<CreatePoiPage> createState() => _CreatePoiPageState();
}

class _CreatePoiPageState extends State<CreatePoiPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _category = 'elevator';
  double _lat = -23.563266;
  double _lon = -46.730815;
  String? _selectedBuildingId;
  bool _isLoading = false;
  bool _isLoadingLocation = true;
  bool _locationError = false;

  List<Building> _buildingEntries = [];

  // Dynamic fields
  // Elevator
  List<String> _elevatorFloors = [];
  String _elevatorDimensions = '';

  // Bathroom
  bool _bathroomIsUnisex = false;
  bool _bathroomHasGrabBars = false;
  bool _bathroomIsPcdExclusive = false;

  // Ramp
  bool _rampHasHandrail = false;
  String _rampSteepness = 'moderate';

  // Bus
  bool _busIsCurbAdequate = false;

  // Other
  String _otherDetails = '';

  @override
  void initState() {
    super.initState();
    _loadBuildings();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _locationError = true;
          _isLoadingLocation = false;
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _locationError = true;
            _isLoadingLocation = false;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _locationError = true;
          _isLoadingLocation = false;
        });
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lon = position.longitude;
          _locationError = false;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = true;
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadBuildings() async {
    final entries = await BuildingRepository.instance.getBuildingEntries();
    if (mounted) {
      setState(() {
        _buildingEntries = entries;
      });
    }
  }

  Future<void> _submitPoi() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> details = {};
    if (_category == 'elevator') {
      details['floors'] = _elevatorFloors;
      details['cabin dimensions'] = _elevatorDimensions;
    } else if (_category == 'bathroom') {
      details['is_unisex'] = _bathroomIsUnisex;
      details['has_grab_bars'] = _bathroomHasGrabBars;
      details['is_pcd_exclusive'] = _bathroomIsPcdExclusive;
    } else if (_category == 'ramp') {
      details['has_handrail'] = _rampHasHandrail;
      details['steepness'] = _rampSteepness;
    } else if (_category == 'bus') {
      details['is_curb_adequate'] = _busIsCurbAdequate;
    } else {
      details['description'] = _otherDetails;
    }

    final data = {
      'name': _name,
      'category': _category,
      'lat': _lat,
      'lon': _lon,
      // 'createdBy': 'user_anon',
      'detailsJson': jsonEncode(details),
    };

    if (_selectedBuildingId != null) {
      data['buildingId'] = _selectedBuildingId!;
    }

    try {
      final poiService = PoiService();
      await poiService.createPoi(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ponto de Acessibilidade criado com sucesso!'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar ponto: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Ponto de Acessibilidade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome *'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              PoiCategoryDropdown(
                category: _category,
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_isLoadingLocation)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PoiLocationRow(
                      lat: _lat,
                      lon: _lon,
                      onLatSaved: (value) => _lat = double.parse(value!),
                      onLonSaved: (value) => _lon = double.parse(value!),
                    ),
                    if (_locationError)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Não foi possível obter sua localização atual',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              BuildingAutocomplete(
                buildingEntries: _buildingEntries,
                selectedBuildingId: _selectedBuildingId,
                onBuildingSelected: (selection) => setState(() {
                  _selectedBuildingId = selection?.id;
                }),
              ),
              const SizedBox(height: 24),
              const Text(
                'Detalhes Específicos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_category == 'elevator') ...[
                ElevatorFields(
                  initialFloors: _elevatorFloors,
                  onFloorsChanged: (floors) => setState(() {
                    _elevatorFloors = floors;
                  }),
                  onSavedDimensions: (dimensions) => setState(() {
                    _elevatorDimensions = dimensions ?? '';
                  }),
                ),
              ] else if (_category == 'bathroom') ...[
                BathroomFields(
                  isUnisex: _bathroomIsUnisex,
                  hasGrabBars: _bathroomHasGrabBars,
                  isPcdExclusive: _bathroomIsPcdExclusive,
                  onUnisexChanged: (value) =>
                      setState(() => _bathroomIsUnisex = value),
                  onGrabBarsChanged: (value) =>
                      setState(() => _bathroomHasGrabBars = value),
                  onPcdExclusiveChanged: (value) =>
                      setState(() => _bathroomIsPcdExclusive = value),
                ),
              ] else if (_category == 'ramp') ...[
                RampFields(
                  rampHasHandrail: _rampHasHandrail,
                  rampSteepness: _rampSteepness,
                  onRampHandrailChanged: (val) =>
                      setState(() => _rampHasHandrail = val),
                  onRampSteepnessChanged: (value) =>
                      setState(() => _rampSteepness = value ?? ''),
                ),
              ] else if (_category == 'bus') ...[
                SwitchListTile(
                  title: const Text('O meio-fio é adequado?'),
                  value: _busIsCurbAdequate,
                  onChanged: (val) => setState(() => _busIsCurbAdequate = val),
                ),
              ] else ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Outros detalhes',
                  ),
                  onSaved: (value) => _otherDetails = value ?? '',
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submitPoi,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Ponto de Acessibilidade'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PoiLocationRow extends StatelessWidget {
  final double lat;
  final double lon;

  final FormFieldSetter<String?> onLatSaved;
  final FormFieldSetter<String?> onLonSaved;

  const PoiLocationRow({
    super.key,
    required this.lat,
    required this.lon,
    required this.onLatSaved,
    required this.onLonSaved,
  });

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value) == null) {
      return 'Número inválido';
    }
    return null;
  }

  final TextInputType _keyboardType = const TextInputType.numberWithOptions(
    decimal: true,
    signed: true,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: ValueKey('lat_$lat'),
            decoration: const InputDecoration(labelText: 'Latitude *'),
            initialValue: lat.toString(),
            keyboardType: _keyboardType,
            validator: _validator,
            onSaved: onLatSaved,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            key: ValueKey('lon_$lon'),
            decoration: const InputDecoration(labelText: 'Longitude *'),
            initialValue: lon.toString(),
            keyboardType: _keyboardType,
            validator: _validator,
            onSaved: onLonSaved,
          ),
        ),
      ],
    );
  }
}

class PoiCategoryDropdown extends StatelessWidget {
  final String category;
  final ValueChanged<String?> onChanged;

  const PoiCategoryDropdown({
    super.key,
    required this.category,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Categoria *'),
      initialValue: category,
      items: const [
        DropdownMenuItem(value: 'elevator', child: Text('Elevador')),
        DropdownMenuItem(value: 'bathroom', child: Text('Banheiro')),
        DropdownMenuItem(value: 'ramp', child: Text('Rampa')),
        DropdownMenuItem(value: 'bus', child: Text('Ponto de Ônibus')),
        DropdownMenuItem(value: 'other', child: Text('Outro')),
      ],
      onChanged: onChanged,
    );
  }
}

class BuildingAutocomplete extends StatelessWidget {
  final List<Building> buildingEntries;
  final String? selectedBuildingId;
  final ValueChanged<Building?> onBuildingSelected;

  const BuildingAutocomplete({
    super.key,
    required this.buildingEntries,
    required this.selectedBuildingId,
    required this.onBuildingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Building>(
      displayStringForOption: (Building option) => option.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Building>.empty();
        }
        return buildingEntries.where((Building option) {
          return option.name.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: onBuildingSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Edifício Associado (opcional)',
            suffixIcon: selectedBuildingId != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      onBuildingSelected(null);
                      controller.clear();
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}

class ElevatorFields extends StatefulWidget {
  final List<String> initialFloors;
  final ValueChanged<List<String>> onFloorsChanged;
  final FormFieldSetter<String> onSavedDimensions;

  const ElevatorFields({
    super.key,
    required this.initialFloors,
    required this.onFloorsChanged,
    required this.onSavedDimensions,
  });

  @override
  State<ElevatorFields> createState() => _ElevatorFieldsState();
}

class _ElevatorFieldsState extends State<ElevatorFields> {
  final TextEditingController _floorInputController = TextEditingController();
  late List<String> _elevatorFloors = [];

  @override
  void initState() {
    super.initState();
    _elevatorFloors = List.from(widget.initialFloors);
  }

  @override
  void dispose() {
    _floorInputController.dispose();
    super.dispose();
  }

  void _addFloor(String value) {
    final digitValue = value.replaceAll(' ', '');
    if (digitValue.isNotEmpty && !_elevatorFloors.contains(digitValue)) {
      setState(() {
        _elevatorFloors.add(digitValue);
      });
      // Notify parent form of the update
      widget.onFloorsChanged(_elevatorFloors);
    }
    _floorInputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _floorInputController,
          decoration: const InputDecoration(
            labelText: 'Adicionar Andar',
            hintText: 'Digite o número e pressione Espaço ou Enter',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
          ],
          onChanged: (value) {
            if (value.contains(' ')) {
              _addFloor(value);
            }
          },
          onFieldSubmitted: (value) {
            _addFloor(value);
          },
        ),
        if (_elevatorFloors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Wrap(
              spacing: 8.0,
              children: _elevatorFloors.map((floor) {
                return Semantics(
                  label: 'Remover andar $floor',
                  child: Chip(
                    label: Text(floor),
                    onDeleted: () {
                      setState(() {
                        _elevatorFloors.remove(floor);
                      });
                      widget.onFloorsChanged(_elevatorFloors);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Dimensões da cabine (ex: 1.20m x 1.50m)',
          ),
          onSaved: widget.onSavedDimensions,
        ),
      ],
    );
  }
}

class BathroomFields extends StatelessWidget {
  final bool isUnisex;
  final bool hasGrabBars;
  final bool isPcdExclusive;
  final ValueChanged<bool> onUnisexChanged;
  final ValueChanged<bool> onGrabBarsChanged;
  final ValueChanged<bool> onPcdExclusiveChanged;

  const BathroomFields({
    super.key,
    required this.isUnisex,
    required this.hasGrabBars,
    required this.isPcdExclusive,
    required this.onUnisexChanged,
    required this.onGrabBarsChanged,
    required this.onPcdExclusiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Banheiro Unissex'),
          subtitle: const Text('Acessível para qualquer gênero'),
          value: isUnisex,
          onChanged: onUnisexChanged,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Possui Barras de Apoio'),
          subtitle: const Text(
            'Presença de barras de segurança regulamentadas',
          ),
          value: hasGrabBars,
          onChanged: onGrabBarsChanged,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Exclusivo PCD'),
          subtitle: const Text('Destinado apenas para pessoas com deficiência'),
          value: isPcdExclusive,
          onChanged: onPcdExclusiveChanged,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class RampFields extends StatelessWidget {
  final bool rampHasHandrail;
  final String rampSteepness;
  final ValueChanged<bool> onRampHandrailChanged;
  final ValueChanged<String?> onRampSteepnessChanged;

  const RampFields({
    super.key,
    required this.rampHasHandrail,
    required this.onRampHandrailChanged,
    required this.rampSteepness,
    required this.onRampSteepnessChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Possui corrimão?'),
          value: rampHasHandrail,
          onChanged: onRampHandrailChanged,
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Inclinação (ex: moderada, íngreme)',
          ),
          initialValue: rampSteepness,
          onSaved: onRampSteepnessChanged,
        ),
      ],
    );
  }
}
