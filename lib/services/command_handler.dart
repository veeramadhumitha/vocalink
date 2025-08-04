import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'battery_service.dart';
import 'contact_service.dart';
import 'tts_service.dart';

class CommandHandler {
  final Function(String) updateUI;
  final TTSService tts;
  final ContactService contactService = ContactService();
  final BatteryService batteryService = BatteryService();

  CommandHandler(this.updateUI, this.tts);

  void handle(String input) async {
    print("🎤 Recognized voice input: $input");
    final command = input.trim().toLowerCase();

    try {
      if (command.startsWith("call")) {
        String name = command.replaceFirst("call", "").trim();
        String? number = await contactService.findPhoneNumberByName(name);

        if (number != null) {
          final tel = Uri.parse("tel:$number");
          if (await canLaunchUrl(tel)) {
            await launchUrl(tel);
            tts.speak("Calling $name now.");
          } else {
            updateUI("❗ Could not launch dialer.");
            tts.speak("Unable to open dialer.");
          }
        } else {
          updateUI("❗ Contact \"$name\" not found.");
          tts.speak("Contact $name not found.");
        }

      } else if (command.startsWith("search for ")) {
        final query = command.replaceFirst("search for ", "").trim();
        tts.speak("Searching for $query");

        if (Platform.isAndroid) {
          final intent = AndroidIntent(
            action: 'android.intent.action.WEB_SEARCH',
            arguments: {'query': query},
          );
          try {
            await intent.launch();
          } catch (_) {
            final url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(query)}');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              updateUI("❗ Unable to open search.");
              tts.speak("Unable to open Google search.");
            }
          }
        }

      } else if (command.contains("open camera")) {
        if (Platform.isAndroid) {
          final intent = AndroidIntent(action: 'android.media.action.IMAGE_CAPTURE');
          try {
            await intent.launch();
            updateUI("📸 Camera opened.");
            tts.speak("Camera opened.");
          } catch (_) {
            updateUI("❗ Failed to open camera.");
            tts.speak("Failed to open camera.");
          }
        }

      } else if (command.contains("time")) {
        final now = DateTime.now();
        final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        updateUI("🕒 The current time is $time.");
        tts.speak("The current time is $time");

      } else if (command.contains("date")) {
        final now = DateTime.now();
        final date = "${now.day}/${now.month}/${now.year}";
        updateUI("📅 Today's date is $date.");
        tts.speak("Today's date is $date");

      } else if (command.contains("battery")) {
        int level = await batteryService.getBatteryLevel();
        bool charging = await batteryService.isCharging();

        String status = charging ? "charging" : "not charging";
        String message = "🔋 Battery is at $level% and currently $status.";
        updateUI(message);
        tts.speak("Battery is at $level percent and currently $status.");

      } else {
        updateUI("❗ Command not recognized.");
        tts.speak("Sorry, I did not understand that command.");
      }
    } catch (e) {
      updateUI("❗ Error processing command.");
      tts.speak("There was an error handling the command.");
    }
  }
}
