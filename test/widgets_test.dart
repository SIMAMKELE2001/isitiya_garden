import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isitiya_garden/core/utils/validators.dart';
import 'package:isitiya_garden/core/widgets/app_text_field.dart';
import 'package:isitiya_garden/core/widgets/choice_pill.dart';
import 'package:isitiya_garden/core/widgets/produce_card.dart';
import 'package:isitiya_garden/core/widgets/status_badge.dart';
import 'package:isitiya_garden/features/produce/models/produce.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

const spinach = Produce(
  id: '1',
  name: 'Fresh spinach',
  category: 'Vegetables',
  quantity: 40,
  unit: 'bunch',
  price: 12,
  isPriceNegotiable: false,
  status: AvailabilityStatus.available,
  community: 'Qunu',
  farmerName: 'Nomsa Mbatha',
);

void main() {
  testWidgets('StatusBadge shows words for every status', (tester) async {
    for (final status in AvailabilityStatus.values) {
      await tester.pumpWidget(host(StatusBadge(status)));
      expect(find.text(status.label), findsOneWidget);
    }
  });

  testWidgets('ChoicePill reports taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        ChoicePill(label: 'Vegetables', selected: false, onTap: () => taps++),
      ),
    );
    await tester.tap(find.text('Vegetables'));
    expect(taps, 1);
  });

  testWidgets('ProduceCard shows the key listing details', (tester) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 380,
          child: SingleChildScrollView(child: ProduceCard(produce: spinach)),
        ),
      ),
    );
    expect(find.text('Fresh spinach'), findsOneWidget);
    expect(find.text('From Nomsa Mbatha'), findsOneWidget);
    expect(find.text('Qunu'), findsOneWidget);
    expect(find.text('R12 per bunch'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('View produce'), findsOneWidget);
  });

  testWidgets('AppTextField shows the validator message inline (NFR05)', (
    tester,
  ) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(
      host(
        Form(
          key: key,
          child: AppTextField(label: 'Email', validator: Validators.email),
        ),
      ),
    );

    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Email is required.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'nomsa@example.com');
    expect(key.currentState!.validate(), isTrue);
  });
}
