import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitpastel/main.dart';
import 'package:fitpastel/services/storage_service.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('tr_TR', null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  Future<void> saveScreenshot(WidgetTester tester, GlobalKey key, String name) async {
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      try {
        final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 2.0);
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            final file = File('test_screenshots/$name.png');
            file.parent.createSync(recursive: true);
            file.writeAsBytesSync(byteData.buffer.asUint8List());
          }
        }
      } catch (e) {
        // Screenshot capture error should not break the test flow
      }
    });
  }

  group('Full Application End-to-End & Screen Inspection Tests', () {
    testWidgets('Inspects Android and iOS UI layout, interactions and modals with zero errors', (WidgetTester tester) async {
      FlutterErrorDetails? overflowDetails;
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('overflowed')) {
          overflowDetails = details;
        }
        prevOnError?.call(details);
      };

      final globalKey = GlobalKey();

      // Configure Android Screen Dimensions (e.g. Pixel 7 / Galaxy S23)
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        RepaintBoundary(
          key: globalKey,
          child: const FitClassApp(),
        ),
      );
      await tester.pumpAndSettle();

      final err = tester.takeException();
      if (overflowDetails != null) {
        debugPrint('OVERFLOW DETAILS:\n${overflowDetails.toString()}');
      }
      expect(err, isNull);
      await saveScreenshot(tester, globalKey, '01_android_dashboard_light');

      // -------------------------------------------------------------
      // 1. DASHBOARD VIEW INTERACTIONS
      // -------------------------------------------------------------
      // Test Water Quick Add: +250 ml
      final add250Btn = find.text('+250 ml');
      if (add250Btn.evaluate().isNotEmpty) {
        await tester.tap(add250Btn);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Test Water Quick Add: +500 ml
      final add500Btn = find.text('+500 ml');
      if (add500Btn.evaluate().isNotEmpty) {
        await tester.tap(add500Btn);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await saveScreenshot(tester, globalKey, '02_android_dashboard_water_added');

      // -------------------------------------------------------------
      // 2. WORKOUT VIEW INTERACTIONS
      // -------------------------------------------------------------
      final workoutTab = find.byIcon(Icons.fitness_center_outlined);
      await tester.tap(workoutTab);
      await tester.pumpAndSettle();
      final workoutErr = tester.takeException();
      if (overflowDetails != null) {
        debugPrint('WORKOUT OVERFLOW DETAILS:\n${overflowDetails.toString()}');
      }
      expect(workoutErr, isNull);
      await saveScreenshot(tester, globalKey, '03_android_workout_tab');

      // Open Bar Plaka Hesaplayıcı Dialog
      final plateBtn = find.text('Plaka');
      if (plateBtn.evaluate().isNotEmpty) {
        await tester.tap(plateBtn);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await saveScreenshot(tester, globalKey, '04_android_plate_calculator_modal');

        // Select different weight: 70 kg
        final chip70 = find.text('70 kg');
        if (chip70.evaluate().isNotEmpty) {
          await tester.tap(chip70);
          await tester.pumpAndSettle();
        }

        // Select EZ Bar: 10 kg
        final ezBar = find.text('10 kg (EZ Bar)');
        if (ezBar.evaluate().isNotEmpty) {
          await tester.tap(ezBar);
          await tester.pumpAndSettle();
        }
        await saveScreenshot(tester, globalKey, '05_android_plate_calculator_ezbar');

        // Close plate calculator
        final closeBtn = find.byIcon(Icons.close);
        if (closeBtn.evaluate().isNotEmpty) {
          await tester.tap(closeBtn.last);
          await tester.pumpAndSettle();
        }
      }

      // Start Rest Timer (30s)
      final timer30s = find.text('30s');
      if (timer30s.evaluate().isNotEmpty) {
        await tester.tap(timer30s);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await saveScreenshot(tester, globalKey, '06_android_workout_rest_timer_active');

        // Pause/Resume timer
        final pauseBtn = find.byIcon(Icons.pause_circle_outline);
        if (pauseBtn.evaluate().isNotEmpty) {
          await tester.tap(pauseBtn);
          await tester.pumpAndSettle();
        }

        // Cancel timer
        final cancelTimerBtn = find.byIcon(Icons.close);
        if (cancelTimerBtn.evaluate().isNotEmpty) {
          await tester.tap(cancelTimerBtn.first);
          await tester.pumpAndSettle();
        }
      }

      // -------------------------------------------------------------
      // 3. NUTRITION VIEW INTERACTIONS
      // -------------------------------------------------------------
      final nutritionTab = find.text('Beslenme');
      await tester.tap(nutritionTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await saveScreenshot(tester, globalKey, '07_android_nutrition_tab');

      // Open Add Meal Bottom Sheet
      final addMealFab = find.byType(FloatingActionButton);
      if (addMealFab.evaluate().isNotEmpty) {
        await tester.tap(addMealFab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await saveScreenshot(tester, globalKey, '08_android_nutrition_add_meal_sheet');

        // Close bottom sheet
        final closeSheet = find.byIcon(Icons.close);
        if (closeSheet.evaluate().isNotEmpty) {
          await tester.tap(closeSheet.last);
          await tester.pumpAndSettle();
        }
      }

      // -------------------------------------------------------------
      // 4. ANALYTICS VIEW INTERACTIONS
      // -------------------------------------------------------------
      final analyticsTab = find.byIcon(Icons.show_chart_outlined);
      await tester.tap(analyticsTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await saveScreenshot(tester, globalKey, '09_android_analytics_tab_workouts');

      // Switch to Vücut Ölçüleri Tab
      final bodyMeasureTab = find.text('Vücut Ölçüleri');
      if (bodyMeasureTab.evaluate().isNotEmpty) {
        await tester.tap(bodyMeasureTab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await saveScreenshot(tester, globalKey, '10_android_analytics_tab_body');
      }

      // Switch to Su Trendi Tab
      final waterTrendTab = find.text('Su Trendi');
      if (waterTrendTab.evaluate().isNotEmpty) {
        await tester.tap(waterTrendTab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await saveScreenshot(tester, globalKey, '11_android_analytics_tab_water');
      }

      // -------------------------------------------------------------
      // 5. PROFILE VIEW INTERACTIONS
      // -------------------------------------------------------------
      final profileTab = find.byIcon(Icons.person_outline);
      await tester.tap(profileTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await saveScreenshot(tester, globalKey, '12_android_profile_tab_light');

      // Switch Goal Card: "Kilo Verme & Yağ Yakımı"
      final kiloVermeCard = find.text('Kilo Verme & Yağ Yakımı');
      if (kiloVermeCard.evaluate().isNotEmpty) {
        await tester.ensureVisible(kiloVermeCard);
        await tester.pumpAndSettle();
        await tester.tap(kiloVermeCard);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await saveScreenshot(tester, globalKey, '13_android_profile_goal_kilo_verme');
      }

      // Switch Goal Card: "Form Koruma & Sağlıklı Yaşam"
      final formKorumaCard = find.text('Form Koruma & Sağlıklı Yaşam');
      if (formKorumaCard.evaluate().isNotEmpty) {
        await tester.ensureVisible(formKorumaCard);
        await tester.pumpAndSettle();
        await tester.tap(formKorumaCard);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // -------------------------------------------------------------
      // 6. DARK THEME TESTING (iOS Geometry: iPhone 14/15 Pro)
      // -------------------------------------------------------------
      // Switch screen size to iOS standard (393 x 852 dp)
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;

      // Toggle Dark Mode from AppBar
      final themeToggle = find.byTooltip('Karanlık Tema');
      if (themeToggle.evaluate().isNotEmpty) {
        await tester.tap(themeToggle);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await saveScreenshot(tester, globalKey, '14_ios_profile_dark_mode');
      }

      // Inspect Dashboard in Dark Mode
      final dashTab = find.byIcon(Icons.dashboard_outlined);
      await tester.tap(dashTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await saveScreenshot(tester, globalKey, '15_ios_dashboard_dark_mode');

      // Inspect Workout in Dark Mode
      await tester.tap(workoutTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await saveScreenshot(tester, globalKey, '16_ios_workout_dark_mode');

      // Inspect Nutrition in Dark Mode
      await tester.tap(nutritionTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await saveScreenshot(tester, globalKey, '17_ios_nutrition_dark_mode');

      // Inspect Analytics in Dark Mode
      await tester.tap(analyticsTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await saveScreenshot(tester, globalKey, '18_ios_analytics_dark_mode');
    });
  });
}
