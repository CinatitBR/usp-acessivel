import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usp_acessivel/features/map/controllers/map_controller.dart';
import 'package:usp_acessivel/features/map/models/map_style.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'OPEN_ROUTE_SERVICE_API_KEY=test_key');
  });
  group('AppMapStyle enum', () {
    test('contains Detalhado (Liberty) and Minimalista (Positron)', () {
      expect(AppMapStyle.liberty.name, equals('Detalhado'));
      expect(
        AppMapStyle.liberty.url,
        equals('https://tiles.openfreemap.org/styles/liberty'),
      );

      expect(AppMapStyle.positron.name, equals('Minimalista'));
      expect(
        AppMapStyle.positron.url,
        equals('https://tiles.openfreemap.org/styles/positron'),
      );
    });
  });

  group('MapController style management', () {
    test('defaults to AppMapStyle.liberty', () {
      final controller = MapController();
      expect(controller.currentMapStyle, equals(AppMapStyle.liberty));
    });

    test('updates style and notifies listeners when setMapStyle is called', () {
      final controller = MapController();
      var notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      controller.setMapStyle(AppMapStyle.positron);
      expect(controller.currentMapStyle, equals(AppMapStyle.positron));
      expect(notificationCount, equals(1));

      // Setting the same style should not trigger another notification
      controller.setMapStyle(AppMapStyle.positron);
      expect(notificationCount, equals(1));

      controller.setMapStyle(AppMapStyle.liberty);
      expect(controller.currentMapStyle, equals(AppMapStyle.liberty));
      expect(notificationCount, equals(2));
    });
  });
}
