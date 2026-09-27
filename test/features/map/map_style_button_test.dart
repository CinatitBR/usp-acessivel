import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usp_acessivel/features/map/models/map_style.dart';
import 'package:usp_acessivel/features/map/widgets/map_style_button.dart';

void main() {
  testWidgets('MapStyleButton renders and displays options on tap', (
    WidgetTester tester,
  ) async {
    AppMapStyle selectedStyle = AppMapStyle.liberty;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              MapStyleButton(
                currentStyle: selectedStyle,
                onStyleSelected: (style) {
                  selectedStyle = style;
                },
              ),
            ],
          ),
        ),
      ),
    );

    // Verify MapStyleButton icon is present
    expect(find.byIcon(Icons.layers_rounded), findsOneWidget);

    // Tap the button to open popup menu
    await tester.tap(find.byType(PopupMenuButton<AppMapStyle>));
    await tester.pumpAndSettle();

    // Verify both options are presented by name
    expect(find.text('Detalhado'), findsOneWidget);
    expect(find.text('Minimalista'), findsOneWidget);

    // Tap 'Minimalista'
    await tester.tap(find.text('Minimalista'));
    await tester.pumpAndSettle();

    // Verify callback was triggered with Positron
    expect(selectedStyle, equals(AppMapStyle.positron));
  });
}
