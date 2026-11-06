
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fintrack/main.dart';
import 'package:fintrack/providers/app_settings.dart';
import 'package:fintrack/viewmodels/goals_viewmodel.dart';

void main() {
  testWidgets('FinTrack app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<GoalsViewModel>(
            create: (_) => GoalsViewModel(),
          ),
          ChangeNotifierProvider<AppSettings>(
            create: (_) => AppSettings(),
          ),
        ],
        child: FinTrackApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
