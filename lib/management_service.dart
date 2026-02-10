import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ManagementService {
  Map<String, dynamic>? _managementData;

  Future<void> loadManagementData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/management_techniques.json');
      _managementData = json.decode(jsonString);
      print('✅ Loaded management techniques');
    } catch (e) {
      print('❌ Error loading management techniques: $e');
      _managementData = {}; // Initialize to empty map on error
    }
  }

  dynamic getTechnique(String diseaseKey, String languageCode) {
    if (_managementData == null) {
      return 'Management data not loaded.';
    }
    // Fallback to English if the language or key is not found
    final technique = _managementData?[languageCode]?[diseaseKey] ?? _managementData?['en']?[diseaseKey];
    return technique ?? {'description': 'No management information available for this disease.'};
  }
}