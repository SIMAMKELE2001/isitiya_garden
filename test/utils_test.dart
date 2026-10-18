import 'package:flutter_test/flutter_test.dart';
import 'package:isitiya_garden/core/utils/format.dart';
import 'package:isitiya_garden/core/utils/phone_utils.dart';

void main() {
  group('PhoneUtils.toInternational', () {
    test('turns local South African numbers into international form', () {
      expect(PhoneUtils.toInternational('073 555 0178'), '27735550178');
      expect(PhoneUtils.toInternational('0735550178'), '27735550178');
    });
    test('keeps numbers that are already international', () {
      expect(PhoneUtils.toInternational('+27 73 555 0178'), '27735550178');
      expect(PhoneUtils.toInternational('0027735550178'), '27735550178');
      expect(PhoneUtils.toInternational('27735550178'), '27735550178');
    });
  });

  group('Format.date', () {
    test('writes day, short month and year', () {
      expect(Format.date(DateTime(2026, 10, 15)), '15 Oct 2026');
      expect(Format.date(DateTime(2027, 1, 3)), '3 Jan 2027');
    });
  });

  group('Format.availability (FR10)', () {
    test('no dates means available now', () {
      expect(Format.availability(null, null), 'Available now');
    });
    test('a start date in the future says "from"', () {
      final future = DateTime.now().add(const Duration(days: 10));
      expect(Format.availability(future, null), startsWith('Available from'));
    });
    test('an end date is mentioned', () {
      final until = DateTime.now().add(const Duration(days: 5));
      expect(Format.availability(null, until), startsWith('Available now, until'));
    });
  });

  group('Format.listed', () {
    test('today, yesterday and days ago', () {
      expect(Format.listed(DateTime.now()), 'Listed today');
      expect(
        Format.listed(DateTime.now().subtract(const Duration(days: 1, hours: 1))),
        'Listed yesterday',
      );
      expect(
        Format.listed(DateTime.now().subtract(const Duration(days: 3, hours: 1))),
        'Listed 3 days ago',
      );
    });
    test('no date', () => expect(Format.listed(null), 'Recently listed'));
  });
}
