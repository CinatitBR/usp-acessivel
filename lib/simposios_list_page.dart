import 'package:flutter/material.dart';
import 'event_list_item.dart';
import 'simposio_model.dart';

import 'dynamic_visual_route_page.dart';

// Example 2: With search/filter functionality
class SimposiosList extends StatefulWidget {
  const SimposiosList({super.key, this.onTap, required this.visualRoutes});

  final List<dynamic> visualRoutes;
  final VoidCallback? onTap;

  @override
  State<SimposiosList> createState() => _SimposiosListState();
}

class _SimposiosListState extends State<SimposiosList> {
  late Future<List<Simposio>> _simposiosFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _simposiosFuture = loadSimposios();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar simpósios...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // List
          FutureBuilder<List<Simposio>>(
            future: _simposiosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erro: ${snapshot.error}'),
                );
              }

              final simposios = snapshot.data ?? [];

              // Filter based on search query
              final filtered = simposios
                  .where(
                    (sim) =>
                        sim.title.toLowerCase().contains(_searchQuery) ||
                        sim.classroom.toLowerCase().contains(_searchQuery),
                  )
                  .toList();

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum resultado encontrado'),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final simposio = filtered[index];
                  return EventListItem(
                    title: simposio.title,
                    subtitle: simposio.classroom,
                    onTap: () {
                      print('Selected: ${simposio.id}');
                      widget.onTap?.call();

                      if (widget.visualRoutes.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DynamicVisualRoutePage(
                              routeData: widget.visualRoutes.first,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16), // Padding at bottom
        ],
      ),
    );
  }
}
