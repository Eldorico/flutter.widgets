// Copyright 2019 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile.flutter.testing/font_directory_loader.dart';
import 'package:flutter_widgets/src/feature_discovery/feature_discovery.dart';
import 'package:flutter_widgets/src/feature_discovery/src/overlay_widgets.dart';

Future<void> pumpToOverlayOpen(WidgetTester tester) =>
    tester.pump(Duration(milliseconds: 500));

/// TODO: Support Scuba tests.
void main() {
  setUpAll(() async {
    await loadFontDirectories();
  });

  testWidgets(
      'Flutter exception should be thrown when Feature Discovery Controller.of '
      'is called without a FeatureDiscoveryController ancestor.',
      (WidgetTester tester) async {
    bool tested = false;
    final widget = Builder(builder: (BuildContext context) {
      tested = true;
      FeatureDiscoveryController.of(context); // should throw
      return Container();
    });

    await tester.pumpWidget(widget);

    expect(tested, isTrue);
    expect(tester.takeException(), isFlutterError);
  });

  testWidgets(
      'Assertion error should be thrown when there is more than one '
      'FeatureDiscoveryController in the widget tree.',
      (WidgetTester tester) async {
    final widget = FeatureDiscoveryController(
      FeatureDiscoveryController(Container()),
    );

    await tester.pumpWidget(widget);

    expect(tester.takeException(), isAssertionError);
  });

  testWidgets(
      'No feature discovery widgets should be displayed when showOverlay '
      'parameter is false for two Feature Discovery widgets A and B',
      (WidgetTester tester) async {
    final widget = wrapWidget(false, false);

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);
  });

  group('showOverlay parameter is true for Feature Discovery widgets A and B',
      () {
    testWidgets('Only the first Feature Discovery widget should be displayed',
        (WidgetTester tester) async {
      final widget = wrapWidget(true, true);

      await tester.pumpWidget(widget);
      await tester.pump();

      await pumpToOverlayOpen(tester);

      expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);
      _expectContent(true, false);

      await expectLater(
        find.byKey(FeatureDiscovery.overlayKey),
        matchesGoldenFile('feature_discovery_A_displayed'),
      );
    });

    testWidgets(
        'dismissing the first showing widget should not trigger the second '
        'widget to open', (WidgetTester tester) async {
      final widget = wrapWidget(true, true);

      await tester.pumpWidget(widget);
      await tester.pump();

      await pumpToOverlayOpen(tester);

      expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);
      _expectContent(true, false);

      await expectLater(
        find.byKey(FeatureDiscovery.overlayKey),
        matchesGoldenFile('feature_discovery_A_displayed'),
      );

      await tester.tap(find.byKey(FeatureDiscovery.gestureDetectorKey));
      await tester.pumpAndSettle();

      expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);
      _expectContent(false, false);

      await expectLater(
        find.byType(FeatureDiscoveryController),
        matchesGoldenFile('no_feature_discovery_displayed'),
      );
    });

    testWidgets(
        'tapping the first showing widget should not trigger the second '
        'widget to open', (WidgetTester tester) async {
      final widget = wrapWidget(true, true);

      await tester.pumpWidget(widget);
      await tester.pump();

      await pumpToOverlayOpen(tester);

      expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);
      _expectContent(true, false);

      await expectLater(
        find.byKey(FeatureDiscovery.overlayKey),
        matchesGoldenFile('feature_discovery_A_displayed'),
      );

      // Tap [TapTarget] to trigger a tap action and dismiss showing overlay.
      //
      // We need to manually find the position of the [TapTarget] because it is
      // translated and hit testing will tap at a position before the
      // translation.
      final tapTarget =
          tester.renderObject(find.byType(TapTarget)) as RenderBox;
      await tester.tapAt(tapTarget.localToGlobal(Offset.zero));
      await tester.pumpAndSettle();

      expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);
      _expectContent(false, false);

      await expectLater(
        find.byType(FeatureDiscoveryController),
        matchesGoldenFile('no_feature_discovery_displayed'),
      );
    });
  });

  group(
      'showOverlay parameter is true for Feature Discovery widget A but '
      'false for Feature Discovery widget B', () {
    testWidgets('Only the first Feature Discovery widget should be displayed',
        (WidgetTester tester) async {
      final widget = wrapWidget(true, false);

      await tester.pumpWidget(widget);
      await tester.pump();

      await pumpToOverlayOpen(tester);

      expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);
      _expectContent(true, false);

      await expectLater(
        find.byKey(FeatureDiscovery.overlayKey),
        matchesGoldenFile('feature_discovery_A_displayed'),
      );
    });

    testWidgets(
        'dismissing the first showing widget should not trigger the second '
        'widget to open', (WidgetTester tester) async {
      final widget = wrapWidget(true, false);

      await tester.pumpWidget(widget);
      await tester.pump();

      await pumpToOverlayOpen(tester);

      expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);
      _expectContent(true, false);

      await expectLater(
        find.byKey(FeatureDiscovery.overlayKey),
        matchesGoldenFile('feature_discovery_A_displayed'),
      );

      await tester.tap(find.byKey(FeatureDiscovery.gestureDetectorKey));
      await tester.pumpAndSettle();

      expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);
      _expectContent(false, false);

      await expectLater(
        find.byType(FeatureDiscoveryController),
        matchesGoldenFile('no_feature_discovery_displayed'),
      );
    });

    testWidgets(
        'tapping the first showing widget should not trigger the second '
        'widget to open', (WidgetTester tester) async {
      final widget = wrapWidget(true, false);

      await tester.pumpWidget(widget);
      await tester.pump();

      await pumpToOverlayOpen(tester);

      expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);
      _expectContent(true, false);

      await expectLater(
        find.byKey(FeatureDiscovery.overlayKey),
        matchesGoldenFile('feature_discovery_A_displayed'),
      );

      // Tap [TapTarget] to trigger a tap action and dismiss showing overlay.
      //
      // We need to manually find the position of the [TapTarget] because it is
      // translated and hit testing will tap at a position before the
      // translation.
      final tapTarget =
          tester.renderObject(find.byType(TapTarget)) as RenderBox;
      await tester.tapAt(tapTarget.localToGlobal(Offset.zero));
      await tester.pumpAndSettle();

      expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);
      _expectContent(false, false);

      await expectLater(
        find.byType(FeatureDiscoveryController),
        matchesGoldenFile('no_feature_discovery_displayed'),
      );
    });
  });

  group(
      'showOverlay parameter is false for Feature Discovery widget A but '
      'true for Feature Discovery widget B', () {
    testWidgets('Only the second Feature Discovery widget should be displayed',
        (WidgetTester tester) async {
      final widget = wrapWidget(false, true);

      await tester.pumpWidget(widget);
      await tester.pump();

      await pumpToOverlayOpen(tester);

      expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);
      _expectContent(false, true);

      await expectLater(
        find.byKey(FeatureDiscovery.overlayKey),
        matchesGoldenFile('feature_discovery_B_displayed'),
      );
    });

    testWidgets(
        'dismissing the second showing widget should not trigger the first '
        'widget to open', (WidgetTester tester) async {
      final widget = wrapWidget(false, true);

      await tester.pumpWidget(widget);
      await tester.pump();

      await pumpToOverlayOpen(tester);

      expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);
      _expectContent(false, true);

      await expectLater(
        find.byKey(FeatureDiscovery.overlayKey),
        matchesGoldenFile('feature_discovery_B_displayed'),
      );

      await tester.tap(find.byKey(FeatureDiscovery.gestureDetectorKey));
      await tester.pumpAndSettle();

      expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);
      _expectContent(false, false);

      await expectLater(
        find.byType(FeatureDiscoveryController),
        matchesGoldenFile('no_feature_discovery_displayed'),
      );
    });

    testWidgets(
        'tapping the second showing widget should not trigger the first '
        'widget to open', (WidgetTester tester) async {
      final widget = wrapWidget(false, true);

      await tester.pumpWidget(widget);
      await tester.pump();

      await pumpToOverlayOpen(tester);

      expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);
      _expectContent(false, true);

      await expectLater(
        find.byKey(FeatureDiscovery.overlayKey),
        matchesGoldenFile('feature_discovery_B_displayed'),
      );

      // Tap [TapTarget] to trigger a tap action and dismiss showing overlay.
      //
      // We need to manually find the position of the [TapTarget] because it is
      // translated and hit testing will tap at a position before the
      // translation.
      final tapTarget =
          tester.renderObject(find.byType(TapTarget)) as RenderBox;
      await tester.tapAt(tapTarget.localToGlobal(Offset.zero));
      await tester.pumpAndSettle();

      expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);
      _expectContent(false, false);

      await expectLater(
        find.byType(FeatureDiscoveryController),
        matchesGoldenFile('no_feature_discovery_displayed'),
      );
    });
  });
}

/// A [FeatureDiscovery] needs to have a
/// [Material] ascendant because it uses material widgets.
Widget wrapWidget(bool showOverlayA, bool showOverlayB) {
  return MaterialApp(
    home: FeatureDiscoveryController(
      Scaffold(
        appBar: AppBar(
          title: Text('Feature Discovery'),
          leading: FeatureDiscovery(
            description: featureDiscoveryADescription,
            showOverlay: showOverlayA,
            title: featureDiscoveryATitle,
            onDismiss: () {},
            onTap: () {},
            child: Icon(Icons.add),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Click here to explore feature discovery'),
              RaisedButton(
                onPressed: () {},
                child: Text('TEST'),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: FeatureDiscovery(
            description: featureDiscoveryBDescription,
            showOverlay: showOverlayB,
            title: featureDiscoveryBTitle,
            onDismiss: () {},
            onTap: () {},
            child: Icon(Icons.add),
          ),
        ),
      ),
    ),
  );
}

const featureDiscoveryATitle = 'Title of feature discovery A';
const featureDiscoveryADescription = 'Description of feature discovery A';
const featureDiscoveryBTitle = 'Title of feature discovery B';
const featureDiscoveryBDescription = 'Description of feature discovery B';

void _expectContent(bool isADisplayed, isBDisplayed) {
  expect(find.text(featureDiscoveryATitle),
      isADisplayed ? findsOneWidget : findsNothing);
  expect(find.text(featureDiscoveryADescription),
      isADisplayed ? findsOneWidget : findsNothing);
  expect(find.text(featureDiscoveryBTitle),
      isBDisplayed ? findsOneWidget : findsNothing);
  expect(find.text(featureDiscoveryBDescription),
      isBDisplayed ? findsOneWidget : findsNothing);
}
