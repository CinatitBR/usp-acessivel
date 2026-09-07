import 'package:flutter/material.dart';
import 'event_list_item.dart';
import 'simposio_model.dart';

// // Example 1: With custom leading widgets per simposio
// class SimposiosListWithLeadingExample extends StatelessWidget {
//   const SimposiosListWithLeadingExample({super.key});

//   // Map of simposio IDs to their colors and icons
//   static const simposioColors = {
//     'sbes': Color(0xFFE8D5F2), // Purple
//     'sblp': Color(0xFFD5E8F2), // Blue
//     'sbcars': Color(0xFFE8F2D5), // Green
//     'sast': Color(0xFFF2E8D5), // Orange
//   };

//   static const simposioIcons = {
//     'sbes': Icons.engineering,
//     'sblp': Icons.code,
//     'sbcars': Icons.architecture,
//     'sast': Icons.bug_report,
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Simpósios')),
//       body: FutureBuilder<List<Simposio>>(
//         future: loadSimposios(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Erro: ${snapshot.error}'));
//           }

//           final simposios = snapshot.data ?? [];

//           return ListView.separated(
//             itemCount: simposios.length,
//             separatorBuilder: (_, __) => const Divider(),
//             itemBuilder: (context, index) {
//               final simposio = simposios[index];
//               final color = simposioColors[simposio.id] ?? Colors.grey;
//               final icon = simposioIcons[simposio.id] ?? Icons.event;

//               return EventListItem(
//                 title: simposio.title,
//                 subtitle: simposio.classroom,
//                 leading: Icon(icon, size: 40, color: Colors.grey[600]),
//                 leadingBackgroundColor: color,
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('${simposio.title} selected')),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// Example 2: With search/filter functionality
class SimposiosListWithFilter extends StatefulWidget {
  const SimposiosListWithFilter({super.key});

  @override
  State<SimposiosListWithFilter> createState() =>
      _SimposiosListWithFilterState();
}

class _SimposiosListWithFilterState extends State<SimposiosListWithFilter> {
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
