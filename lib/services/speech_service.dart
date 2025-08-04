import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool isAvailable = false;
  bool isListening = false;
  String recognizedText = "";

  Function(String)? onResultCallback;

  Future<bool> init() async {
    isAvailable = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        isListening = status == 'listening';
      },
      onError: (error) {
        print('Speech error: $error');
      },
    );
    print("Speech initialized: $isAvailable");
    return isAvailable;
  }

  void listen(Function(String) onResult) {
    onResultCallback = onResult;
    if (isAvailable && !isListening) {
      _speech.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          print("Result: $recognizedText");
          onResultCallback?.call(recognizedText);
        },
        localeId: "en_US",
      );
      isListening = true;
    }
  }

  void stop() {
    if (isListening) {
      _speech.stop();
      isListening = false;
    }
  }
}
