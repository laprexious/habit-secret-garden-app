import 'package:flutter_test/flutter_test.dart';
import '../lib/Screens/habit_details.dart';
//test for 3 weeks 
void main() {
  test('Garden Guide suggests 3 from weekly counts of 2, 3, and 4', () {
    final result = calculateGardenGuideSuggestion(
      checkInDates: [
        '2026-10-12',
        '2026-10-14',
        '2026-10-19',
        '2026-10-20',
        '2026-10-21',
        '2026-10-26',
        '2026-10-27',
        '2026-10-28',
        '2026-10-29',
      ],
      startedLocalDate: '2026-10-05',
      asOfDate: DateTime(2026, 11, 2),
    );

    expect(result, isNotNull);
    expect(result!['weekCounts'], [2, 3, 4]);
    expect(result['suggestedTarget'], 3);
  });
  // test 2
  test('Garden Guide includes weeks with zero check-ins', () {
    final result = calculateGardenGuideSuggestion(
      checkInDates: [
        '2026-10-12',
        '2026-10-14',
        '2026-10-26',
        '2026-10-27',
      ],
      startedLocalDate: '2026-10-05',
      asOfDate: DateTime(2026, 11, 2),
    );

    expect(result, isNotNull);
    expect(result!['weekCounts'], [2, 0, 2]);
    expect(result['suggestedTarget'], 1);
  });
  // test 3
  test('Garden Guide returns no suggestion with fewer than three weeks', () {
    final result = calculateGardenGuideSuggestion(
      checkInDates: [
        '2026-10-26',
        '2026-10-27',
      ],
      startedLocalDate: '2026-10-26',
      asOfDate: DateTime(2026, 11, 2),
    );

    expect(result, isNull);
  });
  
  //test 4
test('Garden Guide excludes the partial starting week', () {
  final result = calculateGardenGuideSuggestion(
    checkInDates: [
      '2026-10-14',
      '2026-10-19',
      '2026-10-20',
      '2026-10-26',
      '2026-10-27',
      '2026-11-02',
      '2026-11-03',
    ],
    startedLocalDate: '2026-10-14',
    asOfDate: DateTime(2026, 11, 9),
  );

  expect(result, isNotNull);
  expect(result!['weekCounts'], [2, 2, 2]);
  expect(result['suggestedTarget'], 2);
});

//test 5
  test('Garden Guide keeps suggested target between 1 and 7', () {
    final lowResult = calculateGardenGuideSuggestion(
      checkInDates: [],
      startedLocalDate: '2026-10-05',
      asOfDate: DateTime(2026, 11, 2),
    );

    expect(lowResult!['suggestedTarget'], 1);

    final highResult = calculateGardenGuideSuggestion(
      checkInDates: [
        '2026-10-12',
        '2026-10-13',
        '2026-10-14',
        '2026-10-15',
        '2026-10-16',
        '2026-10-17',
        '2026-10-18',
        '2026-10-19',
        '2026-10-20',
        '2026-10-21',
        '2026-10-22',
        '2026-10-23',
        '2026-10-24',
        '2026-10-25',
        '2026-10-26',
        '2026-10-27',
        '2026-10-28',
        '2026-10-29',
        '2026-10-30',
        '2026-10-31',
        '2026-11-01',
      ],
      startedLocalDate: '2026-10-05',
      asOfDate: DateTime(2026, 11, 2),
    );

    expect(highResult!['suggestedTarget'], 7);
  });
  
}