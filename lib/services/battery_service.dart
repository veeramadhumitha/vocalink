import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  final Battery _battery = Battery();

  // Get battery level as percentage
  Future<int> getBatteryLevel() async {
    return await _battery.batteryLevel;
  }

  // Check if the device is charging
  Future<bool> isCharging() async {
    final state = await _battery.batteryState;
    return state == BatteryState.charging || state == BatteryState.full;
  }
}