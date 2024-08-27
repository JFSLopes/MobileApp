import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:es_application_1/create_post/location_picker.dart';

class MockGeolocator extends Mock implements Geolocator {}

void main() {
  group('LocationPicker', () {
      group('LocationPickerState', () {
      test('Instantiation', () {
        final locationPickerState = LocationPickerState();
        
        expect(locationPickerState, isNotNull);
      });
    });
    group('LocationPicker', () {
      testWidgets('widget test', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: LocationPicker(),
        ));

        expect(find.text('Select Location'), findsOneWidget);
        expect(find.text('Save Location'), findsOneWidget);

        await tester.tap(find.text('Save Location'));
        await tester.pump();
      });
    });
  });
}
