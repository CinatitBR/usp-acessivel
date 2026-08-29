import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.maxChildSize = 0.98,
    this.minChildSize = 0.15,
    this.onDismissed,
  });

  final Widget child;
  final double maxChildSize;
  final double minChildSize;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          if (notification.extent <= minChildSize) {
            onDismissed?.call();
          }
          return false;
        },
        child: DraggableScrollableSheet(
          initialChildSize: maxChildSize,
          maxChildSize: maxChildSize,
          minChildSize: minChildSize,
          snap: true,
          snapSizes: [0.5],
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    // Top header area containing both the centered handle and right-aligned close button
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(height: 16),
                        const _SheetHandle(),
                        Positioned(
                          right: 16,
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: onDismissed,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.neutral[100],
                              foregroundColor: AppColors.neutral[600],
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ],
                    ),
                    child,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Simple drag handle element
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        width: 70,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.neutral[200],
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }
}

/// A draggable widget that accepts vertical drag gestures.
///
/// This is typically only used in desktop or web platforms.
class Grabber extends StatelessWidget {
  const Grabber({super.key, required this.onVerticalDragUpdate});

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: 300,
        color: colorScheme.onSurface,
        child: Align(
          alignment: .topCenter,
          child: Container(
            margin: const .symmetric(vertical: 8.0),
            width: 32.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: .circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
