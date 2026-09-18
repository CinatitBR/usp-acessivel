import 'package:flutter/material.dart';
import 'package:usp_acessivel/core/theme/app_colors.dart';
import 'package:usp_acessivel/features/map/models/building_model.dart';
class MapSearchBar extends StatelessWidget {
  final AutocompleteOptionsBuilder<Building> optionsBuilder;
  final AutocompleteOnSelected<Building> onSelected;
  final VoidCallback? onClear; // Callback to handle clearing parent state

  const MapSearchBar({
    super.key,
    required this.optionsBuilder,
    required this.onSelected,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Building>(
      displayStringForOption: (Building option) => option.name,
      optionsBuilder: optionsBuilder, // Passed from parent
      onSelected: onSelected, // Passed from parent
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return ListenableBuilder(
              listenable: textEditingController,
              builder: (context, child) {
                final hasText = textEditingController.text.isNotEmpty;
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (value) => onFieldSubmitted(),
                  decoration: InputDecoration(
                    hintText: 'Buscar edifício',
                    hintStyle: TextStyle(color: AppColors.neutral[400]),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.neutral[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(color: AppColors.neutral[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(color: AppColors.neutral[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: hasText
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.neutral[500],
                            ),
                            onPressed: () {
                              textEditingController.clear();
                              if (onClear != null) {
                                onClear!(); // Triggers state reset in parent
                              }
                            },
                          )
                        : null,
                  ),
                );
              },
            );
          },
    );
  }
}
