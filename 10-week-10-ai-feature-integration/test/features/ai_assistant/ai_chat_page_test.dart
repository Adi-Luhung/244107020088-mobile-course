import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/ai_assistant/presentation/pages/ai_chat_page.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const ProviderScope(child: MaterialApp(home: AiChatPage()));
  }

  group('AiChatPage Widget Test', () {
    testWidgets(
      'Harus merender elemen utama AppBar, Quick Prompts, dan Input Bar',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Asisten AI Kampus'), findsOneWidget);
        expect(find.text('Jadwal UTS?'), findsOneWidget);
        expect(find.text('Syarat Beasiswa?'), findsOneWidget);
        expect(find.byKey(const Key('chat_input_field')), findsOneWidget);
        expect(find.byKey(const Key('send_message_button')), findsOneWidget);
        expect(find.byKey(const Key('voice_input_button')), findsOneWidget);
      },
    );

    testWidgets(
      'Mengetik dan mengirim pesan harus memunculkan bubble pesan user di layar',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final inputField = find.byKey(const Key('chat_input_field'));
        final sendButton = find.byKey(const Key('send_message_button'));

        await tester.enterText(
          inputField,
          'Bagaimana cara mengajukan beasiswa?',
        );
        await tester.tap(sendButton);
        await tester.pump();

        expect(
          find.text('Bagaimana cara mengajukan beasiswa?'),
          findsOneWidget,
        );

        // Tunggu penyelesaian respons AI simulasi
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Menekan quick prompt chip harus mengirimkan pertanyaan otomatis ke chat',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final chip = find.text('Jadwal UTS?');
        expect(chip, findsOneWidget);

        await tester.tap(chip);
        await tester.pump();

        expect(find.text('Jadwal UTS?'), findsNWidgets(2)); // chip + pesan user

        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Menekan tombol mic harus memicu status indikator input suara (Speech-to-Text)',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final micButton = find.byKey(const Key('voice_input_button'));
        await tester.tap(micButton);
        await tester.pump();

        expect(find.textContaining('Mendengarkan suara'), findsWidgets);

        // Biarkan timer simulasi transkripsi selesai
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
      },
    );
  });
}
