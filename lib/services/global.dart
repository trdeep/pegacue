import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/custom_scan_result.dart';

class Global {
  static final Set<String> connectedDevices = {};
  static final Set<CustomScanResult> _devices = {};

  static void setCustomScanResult(CustomScanResult result) {
    _devices.add(result);
  }

  static void setBluetoothDevice(BluetoothDevice device) {
    _devices.clear();
    _devices.add(CustomScanResult.fromBluetoothDevice(device));
  }

  static BluetoothDevice? getBluetoothDevice() {
    return _devices.isEmpty ? null : _devices.first.device;
  }
}
