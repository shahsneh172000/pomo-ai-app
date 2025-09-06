class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Pomo AI',
      'selectModelAndImage': 'Select model and pick an image',
      'modelsLoading': 'Please wait, models are loading...',
      'runningInference': 'Running inference...',
      'inferenceError': 'Inference Error',
      'modelLoadFailed': 'Model load failed: {error}',
      'inferenceFailed': 'Inference failed: {error}',
      'fruitModel': 'Fruit Model',
      'leafModel': 'Leaf Model',
      'gallery': 'Gallery',
      'camera': 'Camera',
      // Model Labels
      'Bacterial Blight': 'Bacterial Blight',
      'Calyx Rot': 'Calyx Rot',
      'Fungal Cercospora': 'Fungal Cercospora',
      'Fruit Rot': 'Fruit Rot',
      'Healthy': 'Healthy',
      'Fungal Scab': 'Fungal Scab',
      'Bacterial': 'Bacterial',
      'Fungal': 'Fungal',
    },
    'hi': {
      'appTitle': 'पोमो एआई',
      'selectModelAndImage': 'मॉडल चुनें और एक छवि चुनें',
      'modelsLoading': 'कृपया प्रतीक्षा करें, मॉडल लोड हो रहे हैं...',
      'runningInference': 'अनुमान चल रहा है...',
      'inferenceError': 'अनुमान में त्रुटि',
      'modelLoadFailed': 'मॉडल लोड विफल: {error}',
      'inferenceFailed': 'अनुमान विफल: {error}',
      'fruitModel': 'फल मॉडल',
      'leafModel': 'पत्ती मॉडल',
      'gallery': 'गैलरी',
      'camera': 'कैमरा',
      // Model Labels
      'Bacterial Blight': 'जीवाणु झुलसा',
      'Calyx Rot': 'कैलिक्स रॉट',
      'Fungal Cercospora': 'फंगल सर्कोस्पोरा',
      'Fruit Rot': 'फल सड़न',
      'Healthy': 'स्वस्थ',
      'Fungal Scab': 'फंगल स्कैब',
      'Bacterial': 'जीवाणु',
      'Fungal': 'कवक',
    },
  };

  String get(String key) {
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String getWithParam(String key, Map<String, String> params) {
    String value = get(key);
    params.forEach((paramKey, paramValue) {
      value = value.replaceAll('{$paramKey}', paramValue);
    });
    return value;
  }
}