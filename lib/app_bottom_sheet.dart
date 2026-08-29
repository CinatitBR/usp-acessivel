import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppBottomSheet extends StatefulWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.maxChildSize = 0.98,
    this.onDismissed,
  });

  final Widget child;
  final double maxChildSize;
  final double minChildSize = 0;
  final VoidCallback? onDismissed;

  @override
  State<AppBottomSheet> createState() => _AppBottomSheetState();
}

class _AppBottomSheetState extends State<AppBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  bool _isClosing = false; // Prevents duplicate dismiss triggers

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280), // Smooth entry duration
      vsync: this,
    );

    _sizeAnimation = Tween<double>(begin: 0.0, end: widget.maxChildSize)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic, // Elegant slowing down curve
            reverseCurve: Curves.easeInCubic,
          ),
        );

    // Run the animation immediately when the widget enters the tree
    _controller.forward();
  }

  void _animateClose() {
    if (_isClosing || !mounted) return;
    setState(() => _isClosing = true);

    _controller.reverse().then((value) {
      widget.onDismissed?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Blocks the default immediate system back pop
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // If already popped elsewhere, do nothing

        _animateClose();
      },
      child: SizedBox.expand(
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            // Only trigger dismiss logic if the entrance animation has finished
            if (_controller.isCompleted &&
                // Add a + 0.02 treshold: Flutter restricts scrolling below minChildSize, making exact equality unreliable.
                notification.extent <= widget.minChildSize + 0.02 &&
                !_isClosing) {
              // Triggers the close animation
              _animateClose();
              return true;
            }
            return false;
          },
          child: AnimatedBuilder(
            animation: _sizeAnimation,
            builder: (context, _) {
              final currentAnimatedSize = _sizeAnimation.value;

              // Ensure minChildSize is never greater than the current animating size
              final dynamicMinSize = widget.minChildSize.clamp(
                0.0,
                currentAnimatedSize,
              );

              return DraggableScrollableSheet(
                initialChildSize: currentAnimatedSize,
                maxChildSize: widget.maxChildSize,
                // When closing via code, lock min to 0.0 so it can slide all the way down
                minChildSize: _isClosing ? 0.0 : dynamicMinSize,
                snap: !_isClosing, // Disable snapping during closing phase
                snapSizes: const [0.5],
                builder:
                    (BuildContext context, ScrollController scrollController) {
                      return _SheetContainer(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              _SheetHeader(onClose: _animateClose),
                              widget.child,
                            ],
                          ),
                        ),
                      );
                    },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
      child: child,
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(height: 54),
        const _SheetHandle(),
        Positioned(
          top: 8,
          right: 16,
          child: IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 28,
              color: AppColors.neutral[500],
            ),
            onPressed: onClose,
            padding: const EdgeInsets.all(6),
          ),
        ),
      ],
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
          color: AppColors.neutral[300],
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }
}
