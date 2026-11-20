import 'package:flutter_test/flutter_test.dart';
import 'package:mind_check/data/helplines.dart';

void main() {
  test('Every helpline has a unique two-letter country code and a contact',
      () {
    final Set<String> codes = <String>{};
    for (final Helpline h in helplines) {
      expect(h.countryCode, matches(RegExp(r'^[A-Z]{2}$')), reason: h.name);
      expect(codes.add(h.countryCode), isTrue, reason: 'duplicate ${h.countryCode}');
      expect(h.contact, isNotEmpty);
      expect(h.line, contains(h.country));
    }
  });
}
