import 'package:flutter_test/flutter_test.dart';
import 'package:ujamapp/main.dart';

void main() {
  testWidgets('Humo test de carga uJam', (WidgetTester tester) async {
    // Build nuestra app uJam y dispara un frame.
    await tester.pumpWidget(const UJamApp());

    // Verifica que aparezca el mensaje de bienvenida
    expect(find.text('uJam - El Frasco'), findsOneWidget);
  });
}