import 'dart:ui' show PlatformDispatcher;

/// A free crisis helpline in one country.
class Helpline {
  const Helpline({
    required this.countryCode,
    required this.country,
    required this.name,
    required this.contact,
  });

  /// Two-letter country code, as the phone reports it (e.g. "GB").
  final String countryCode;
  final String country;
  final String name;

  /// How to reach it, e.g. "Call or text 988".
  final String contact;

  /// One line for lists and the PDF, e.g. "United States · 988 Lifeline: …".
  String get line => '$country · $name: $contact';
}

/// Free, 24/7 crisis lines for some of the countries where MindCurio is
/// likely to be used. findahelpline.com covers every other country.
///
/// Check these numbers before each release: helplines sometimes change.
/// Last checked: November 2026.
const List<Helpline> helplines = <Helpline>[
  Helpline(
    countryCode: 'US',
    country: 'United States',
    name: '988 Suicide & Crisis Lifeline',
    contact: 'call or text 988',
  ),
  Helpline(
    countryCode: 'CA',
    country: 'Canada',
    name: '988 Suicide Crisis Helpline',
    contact: 'call or text 988',
  ),
  Helpline(
    countryCode: 'GB',
    country: 'United Kingdom',
    name: 'Samaritans',
    contact: 'call 116 123',
  ),
  Helpline(
    countryCode: 'IE',
    country: 'Ireland',
    name: 'Samaritans',
    contact: 'call 116 123',
  ),
  Helpline(
    countryCode: 'AU',
    country: 'Australia',
    name: 'Lifeline',
    contact: 'call 13 11 14',
  ),
  Helpline(
    countryCode: 'NZ',
    country: 'New Zealand',
    name: 'Need to talk?',
    contact: 'call or text 1737',
  ),
  Helpline(
    countryCode: 'IN',
    country: 'India',
    name: 'Tele-MANAS',
    contact: 'call 14416',
  ),
  Helpline(
    countryCode: 'PK',
    country: 'Pakistan',
    name: 'Umang',
    contact: 'call 0311 7786264',
  ),
  Helpline(
    countryCode: 'DE',
    country: 'Germany',
    name: 'TelefonSeelsorge',
    contact: 'call 0800 111 0 111',
  ),
  Helpline(
    countryCode: 'FR',
    country: 'France',
    name: '3114',
    contact: 'call 3114',
  ),
  Helpline(
    countryCode: 'ZA',
    country: 'South Africa',
    name: 'SADAG Suicide Crisis Helpline',
    contact: 'call 0800 567 567',
  ),
];

/// The helpline for the region set on this phone, or null if we don't
/// list one. The phone's region is a guess at where the person is (it can
/// differ when travelling), so screens always show findahelpline.com too.
Helpline? helplineForThisDevice() {
  final String? code = PlatformDispatcher.instance.locale.countryCode;
  if (code == null) return null;
  for (final Helpline h in helplines) {
    if (h.countryCode == code.toUpperCase()) return h;
  }
  return null;
}
