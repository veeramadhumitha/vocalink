import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:string_similarity/string_similarity.dart';

class ContactService {
  Future<String?> findPhoneNumberByName(String name) async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) return null;

    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final normalizedInput = name.toLowerCase().replaceAll(RegExp(r'\s+'), '');

    print("🔍 Looking for: $normalizedInput");

    Contact? bestMatch;
    double bestScore = 0.0;

    for (final contact in contacts) {
      final contactName = contact.displayName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      print("👤 Checking: ${contact.displayName} → $contactName");

      if (contactName == normalizedInput && contact.phones.isNotEmpty) {
        print("✅ Exact match: ${contact.displayName}");
        return contact.phones.first.number;
      }

      final score = contactName.similarityTo(normalizedInput);
      if (score > bestScore && contact.phones.isNotEmpty) {
        bestScore = score;
        bestMatch = contact;
      }
    }

    if (bestScore > 0.6) {
      print("🤖 Best fuzzy match: ${bestMatch?.displayName} (score: $bestScore)");
      return bestMatch?.phones.first.number;
    }

    print("❌ No suitable match found.");
    return null;
  }
}
