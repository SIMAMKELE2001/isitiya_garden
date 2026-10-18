import 'package:flutter_test/flutter_test.dart';
import 'package:isitiya_garden/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects an empty email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('   '), isNotNull);
    });
    test('rejects text that is not an email', () {
      expect(Validators.email('nomsa'), isNotNull);
      expect(Validators.email('nomsa@'), isNotNull);
      expect(Validators.email('nomsa@example'), isNotNull);
    });
    test('accepts a normal email, even with spaces around it', () {
      expect(Validators.email('nomsa@example.com'), isNull);
      expect(Validators.email('  nomsa@example.com  '), isNull);
    });
  });

  group('Validators.phone (matches the database rule)', () {
    test('accepts local and international numbers', () {
      expect(Validators.phone('072 555 0142'), isNull);
      expect(Validators.phone('0725550142'), isNull);
      expect(Validators.phone('+27725550142'), isNull);
    });
    test('rejects short numbers and letters', () {
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('abcdefghij'), isNotNull);
      expect(Validators.phone(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('needs at least 6 characters', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
    test('rejects empty', () => expect(Validators.password(''), isNotNull));
  });

  group('Validators.fullName', () {
    test(
      'rejects one letter',
      () => expect(Validators.fullName('A'), isNotNull),
    );
    test(
      'accepts a real name',
      () => expect(Validators.fullName('Nomsa Mbatha'), isNull),
    );
  });
}
