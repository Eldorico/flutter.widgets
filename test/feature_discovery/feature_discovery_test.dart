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

  group(
      'Feature Discovery should display overlay when isDisplayable '
      'parameter is true', () {
    testWidgets('top left', (WidgetTester tester) async {
      await runOpenScreenDiffTest(tester, Alignment.topLeft);
    });

    testWidgets('top right', (WidgetTester tester) async {
      await runOpenScreenDiffTest(tester, Alignment.topRight);
    });

    testWidgets('bottom left', (WidgetTester tester) async {
      await runOpenScreenDiffTest(tester, Alignment.bottomLeft);
    });

    testWidgets('bottom right', (WidgetTester tester) async {
      await runOpenScreenDiffTest(tester, Alignment.bottomRight);
    });

    testWidgets('center', (WidgetTester tester) async {
      await runOpenScreenDiffTest(tester, Alignment.center);
    });
  });

  testWidgets(
      'Feature Discovery should not display overlay when isDisplayable '
      'parameter is false', (WidgetTester tester) async {
    final widget = wrapWidget(
      FeatureDiscovery(
        title: 'Title',
        description: 'Description',
        child: Icon(Icons.add),
        showOverlay: false,
      ),
      Alignment.topLeft,
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);
  });

  group(
      'Feature Discovery can dismiss showing overlay by tapping outside the '
      'background', () {
    testWidgets('top left', (WidgetTester tester) async {
      await runDismissScreenDiffTest(
        tester,
        Alignment.topLeft,
        Offset(750.0, 500.0),
      );
    });

    testWidgets('top right', (WidgetTester tester) async {
      await runDismissScreenDiffTest(
        tester,
        Alignment.topRight,
        Offset(0.0, 0.0),
      );
    });

    testWidgets('bottom left', (WidgetTester tester) async {
      await runDismissScreenDiffTest(
        tester,
        Alignment.bottomLeft,
        Offset(0.0, 0.0),
      );
    });

    testWidgets('bottom right', (WidgetTester tester) async {
      await runDismissScreenDiffTest(
        tester,
        Alignment.bottomRight,
        Offset(0.0, 0.0),
      );
    });

    testWidgets('center', (WidgetTester tester) async {
      await runDismissScreenDiffTest(
        tester,
        Alignment.center,
        Offset(0.0, 0.0),
      );
    });
  });

  group(
      'Feature Discovery can tap on tap target to trigger action and dismiss '
      'showing overlay.', () {
    testWidgets('top left', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.topLeft,
      );
    });

    testWidgets('top right', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.topRight,
      );
    });

    testWidgets('bottom left', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.bottomLeft,
      );
    });

    testWidgets('bottom right', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.bottomRight,
      );
    });

    testWidgets('center', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.center,
      );
    });
  });

  group(
      'Feature Discovery does no operations for tapping on the background or '
      'the content of the overlay', () {
    testWidgets('top left', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.topLeft,
      );
    });

    testWidgets('top right', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.topRight,
      );
    });

    testWidgets('bottom left', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.bottomLeft,
      );
    });

    testWidgets('bottom right', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.bottomRight,
      );
    });

    testWidgets('center', (WidgetTester tester) async {
      await runTapScreenDiffTest(
        tester,
        Alignment.center,
      );
    });
  });
}

/// A [FeatureDiscovery] needs to have a
/// [Material] ascendant because it uses material widgets.
Widget wrapWidget(Widget widget, Alignment alignment) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: alignment,
        child: FeatureDiscoveryController(widget),
      ),
    ),
  );
}

void runOpenScreenDiffTest(WidgetTester tester, Alignment alignment) async {
  final widget = wrapWidget(
    FeatureDiscovery(
      title: 'Title of the overlay',
      description: 'Description of the overlay',
      child: Icon(Icons.add),
      showOverlay: true,
    ),
    alignment,
  );

  await tester.pumpWidget(widget);
  await tester.pump(); // Pump for post frame callbacks.
  await pumpToOverlayOpen(tester);

  expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);

  expect(find.text('Title of the overlay'), findsOneWidget);
  expect(find.text('Description of the overlay'), findsOneWidget);

  await expectLater(
    find.byKey(FeatureDiscovery.overlayKey),
    matchesGoldenFile('overlay_opened_${alignment.toString()}'),
  );
}

void runDismissScreenDiffTest(
  WidgetTester tester,
  Alignment alignment,
  Offset dismissTapAt,
) async {
  bool isDismissCallbackInvoked = false;
  bool isTapCallbackInvoked = false;

  final widget = wrapWidget(
    FeatureDiscovery(
      title: 'Title',
      description: 'Description',
      child: Icon(Icons.add),
      showOverlay: true,
      onDismiss: () {
        isDismissCallbackInvoked = true;
      },
      onTap: () {
        isTapCallbackInvoked = true;
      },
    ),
    alignment,
  );

  await tester.pumpWidget(widget);
  await tester.pump();
  await pumpToOverlayOpen(tester);

  expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);

  expect(find.text('Title'), findsOneWidget);
  expect(find.text('Description'), findsOneWidget);

  // Tap outside the background of the overlay to dismiss.
  await tester.tapAt(dismissTapAt);
  await tester.pumpAndSettle();

  expect(isDismissCallbackInvoked, isTrue);
  expect(isTapCallbackInvoked, isFalse);
  expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);

  expect(find.text('Title'), findsNothing);
  expect(find.text('Description'), findsNothing);

  await expectLater(
    find.byType(FeatureDiscovery),
    matchesGoldenFile('overlay_closed_${alignment.toString()}'),
  );
}

void runTapScreenDiffTest(WidgetTester tester, Alignment alignment) async {
  bool isDismissCallbackInvoked = false;
  bool isTapCallbackInvoked = false;

  final widget = wrapWidget(
    FeatureDiscovery(
      title: 'Title',
      description: 'Description',
      child: Icon(Icons.add),
      showOverlay: true,
      onDismiss: () {
        isDismissCallbackInvoked = true;
      },
      onTap: () {
        isTapCallbackInvoked = true;
      },
    ),
    alignment,
  );

  await tester.pumpWidget(widget);
  await tester.pump(); // Pump for post frame callbacks.
  await pumpToOverlayOpen(tester);

  expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);

  expect(find.text('Title'), findsOneWidget);
  expect(find.text('Description'), findsOneWidget);

  // Tap [TapTarget] to trigger a tap action and dismiss showing overlay.
  //
  // We need to manually find the position of the [TapTarget] because it is
  // translated and hit testing will tap at a position before the translation.
  final tapTarget = tester.renderObject(find.byType(TapTarget)) as RenderBox;
  await tester.tapAt(tapTarget.localToGlobal(Offset.zero));
  await tester.pumpAndSettle();

  expect(isDismissCallbackInvoked, isFalse);
  expect(isTapCallbackInvoked, isTrue);
  expect(find.byKey(FeatureDiscovery.overlayKey), findsNothing);

  expect(find.text('Title'), findsNothing);
  expect(find.text('Description'), findsNothing);

  await expectLater(
    find.byType(FeatureDiscovery),
    matchesGoldenFile('overlay_closed_${alignment.toString()}'),
  );
}

void runNoOperationScreenDiffTest(
  WidgetTester tester,
  Alignment alignment,
) async {
  bool isDismissCallbackInvoked = false;
  bool isTapCallbackInvoked = false;

  final widget = wrapWidget(
    FeatureDiscovery(
      title: 'Title',
      description: 'Description',
      child: Icon(Icons.add),
      showOverlay: true,
      onDismiss: () {
        isDismissCallbackInvoked = true;
      },
      onTap: () {
        isTapCallbackInvoked = true;
      },
    ),
    alignment,
  );

  await tester.pumpWidget(widget);
  await tester.pump();
  await pumpToOverlayOpen(tester);

  expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);

  expect(find.text('Title'), findsOneWidget);
  expect(find.text('Description'), findsOneWidget);

  // We need to manually find the position of the [Background] because it is
  // translated and hit testing will tap at a position before the translation.
  final background = tester.renderObject(find.byType(Background)) as RenderBox;
  await tester.tapAt(background.localToGlobal(Offset.zero));
  await tester.pump();

  expect(isDismissCallbackInvoked, isFalse);
  expect(isTapCallbackInvoked, isFalse);
  expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);

  expect(find.text('Title'), findsOneWidget);
  expect(find.text('Description'), findsOneWidget);

  await expectLater(
    find.byType(FeatureDiscovery),
    matchesGoldenFile('overlay_opened_${alignment.toString()}'),
  );

  await tester.tap(find.byType(Content));
  await tester.pump();

  expect(isDismissCallbackInvoked, isFalse);
  expect(isTapCallbackInvoked, isFalse);
  expect(find.byKey(FeatureDiscovery.overlayKey), findsOneWidget);

  expect(find.text('Title'), findsOneWidget);
  expect(find.text('Description'), findsOneWidget);

  await expectLater(
    find.byType(FeatureDiscovery),
    matchesGoldenFile('overlay_opened_${alignment.toString()}'),
  );
}
