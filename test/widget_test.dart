import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_rehberi/main.dart';

void main() {
  testWidgets('Uygulama başlatma testi', (WidgetTester tester) async {
    // BURASI DÜZELDİ: Artık senin sınıf adını kullanıyor
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}