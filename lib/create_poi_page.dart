import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_colors.dart';
import 'building_repository.dart';

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

  List<Building> _buildingEntries = [];

  // Dynamic fields
  // Elevator
  final List<String> _elevatorFloors = [];
  final TextEditingController _floorInputController = TextEditingController();
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
  }

  @override
  void dispose() {
    _floorInputController.dispose();
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
      'createdBy': 'user_anon',
      'detailsJson': jsonEncode(details),
    };

    if (_selectedBuildingId != null) {
      data['buildingId'] = _selectedBuildingId!;
    }

    try {
      final dio = Dio();
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8787';
      final response = await dio.post('$baseUrl/pois', data: data);

      if (response.statusCode == 201 && response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ponto de Acessibilidade criado com sucesso!'),
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Failed to create POI');
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoria *'),
                initialValue: _category,
                items: const [
                  DropdownMenuItem(value: 'elevator', child: Text('Elevador')),
                  DropdownMenuItem(value: 'bathroom', child: Text('Banheiro')),
                  DropdownMenuItem(value: 'ramp', child: Text('Rampa')),
                  DropdownMenuItem(
                    value: 'bus',
                    child: Text('Ponto de Ônibus'),
                  ),
                  DropdownMenuItem(value: 'other', child: Text('Outro')),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Latitude *',
                      ),
                      initialValue: _lat.toString(),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Campo obrigatório';
                        if (double.tryParse(value) == null)
                          return 'Número inválido';
                        return null;
                      },
                      onSaved: (value) => _lat = double.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Longitude *',
                      ),
                      initialValue: _lon.toString(),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Campo obrigatório';
                        if (double.tryParse(value) == null)
                          return 'Número inválido';
                        return null;
                      },
                      onSaved: (value) => _lon = double.parse(value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Autocomplete<Building>(
                displayStringForOption: (Building option) => option.name,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Building>.empty();
                  }
                  return _buildingEntries.where((Building option) {
                    return option.name.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                onSelected: (Building selection) {
                  setState(() {
                    _selectedBuildingId = selection.id;
                  });
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Edifício Associado (opcional)',
                          suffixIcon: _selectedBuildingId != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _selectedBuildingId = null;
                                    });
                                    controller.clear();
                                  },
                                )
                              : null,
                        ),
                      );
                    },
              ),
              const SizedBox(height: 24),
              const Text(
                'Detalhes Específicos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_category == 'elevator') ...[
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
                      final digitValue = value.replaceAll(' ', '');
                      if (digitValue.isNotEmpty &&
                          !_elevatorFloors.contains(digitValue)) {
                        setState(() {
                          _elevatorFloors.add(digitValue);
                        });
                      }
                      _floorInputController.clear();
                    }
                  },
                  onFieldSubmitted: (value) {
                    final digitValue = value.replaceAll(' ', '');
                    if (digitValue.isNotEmpty &&
                        !_elevatorFloors.contains(digitValue)) {
                      setState(() {
                        _elevatorFloors.add(digitValue);
                        _floorInputController.clear();
                      });
                    }
                  },
                ),
                if (_elevatorFloors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: _elevatorFloors.map((floor) {
                        return Chip(
                          label: Text(floor),
                          onDeleted: () {
                            setState(() {
                              _elevatorFloors.remove(floor);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Dimensões da cabine (ex: 1.20m x 1.50m)',
                  ),
                  onSaved: (value) => _elevatorDimensions = value ?? '',
                ),
              ] else if (_category == 'bathroom') ...[
                SwitchListTile(
                  title: const Text('É unissex?'),
                  value: _bathroomIsUnisex,
                  onChanged: (val) => setState(() => _bathroomIsUnisex = val),
                ),
                SwitchListTile(
                  title: const Text('Possui barras de apoio?'),
                  value: _bathroomHasGrabBars,
                  onChanged: (val) =>
                      setState(() => _bathroomHasGrabBars = val),
                ),
                SwitchListTile(
                  title: const Text('É exclusivo para PCD?'),
                  value: _bathroomIsPcdExclusive,
                  onChanged: (val) =>
                      setState(() => _bathroomIsPcdExclusive = val),
                ),
              ] else if (_category == 'ramp') ...[
                SwitchListTile(
                  title: const Text('Possui corrimão?'),
                  value: _rampHasHandrail,
                  onChanged: (val) => setState(() => _rampHasHandrail = val),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Inclinação (ex: moderada, íngreme)',
                  ),
                  initialValue: _rampSteepness,
                  onSaved: (value) => _rampSteepness = value ?? '',
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
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
