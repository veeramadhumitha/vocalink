import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    try {
      await _tts.setLanguage("en-IN");
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      _isInitialized = true;
      print("TTS initialized");
    } catch (e) {
      print("TTS initialization failed: $e");
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      print("TTS not initialized. Initializing now...");
      await init();
    }

    if (text.trim().isEmpty) {
      print("TTS: Skipped speaking empty text");
      return;
    }

    try {
      await _tts.speak(text);
      print("Speaking: $text");
    } catch (e) {
      print("TTS speak failed: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      print("TTS stopped");
    } catch (e) {
      print("TTS stop failed: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _tts.pause();
      print("TTS paused");
    } catch (e) {
      print("TTS pause failed: $e");
    }
  }
}
