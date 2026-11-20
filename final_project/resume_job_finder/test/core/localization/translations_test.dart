import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Arabic contain the same non-empty messages', () {
    Map<String, dynamic> messages(String locale) {
      final data = jsonDecode(
        File('lib/l10n/app_$locale.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      return Map.fromEntries(
        data.entries.where((entry) => !entry.key.startsWith('@')),
      );
    }

    final english = messages('en');
    final arabic = messages('ar');
    expect(english, isNotEmpty);
    expect(arabic.keys, unorderedEquals(english.keys));
    for (final value in [...english.values, ...arabic.values]) {
      expect(value, isA<String>());
      expect((value as String).trim(), isNotEmpty);
    }
  });
}
