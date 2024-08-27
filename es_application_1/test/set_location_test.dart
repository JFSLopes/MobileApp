import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:es_application_1/registration_manager/set_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MockGeolocator extends Mock implements GeolocatorPlatform {}

void main() {
  testWidgets('Widget displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AskDistance(),
    ));

    expect(find.text('Choose the distance'), findsOneWidget);

    expect(find.text('Select the location'), findsOneWidget);

    expect(find.byType(Slider), findsOneWidget);

    expect(find.byType(GoogleMap), findsOneWidget);

    expect(find.text('Use current location'), findsOneWidget);

    expect(find.text('Save'), findsOneWidget);
  });
}
