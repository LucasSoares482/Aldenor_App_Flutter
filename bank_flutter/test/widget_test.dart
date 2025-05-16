// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bank_flutter/main.dart';

void main() {
  testWidgets('App inicializa sem erros', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verificar se o aplicativo iniciou sem erros
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}