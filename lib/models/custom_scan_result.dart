import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CustomScanResult {
  final BluetoothDevice device;
  final int rssi;
  final DateTime timeStamp;
  final AdvertisementData? advertisementData;

  CustomScanResult({
    required this.device,
    required this.rssi,
    required this.timeStamp,
    this.advertisementData,
  });

  /// 从 ScanResult 创建 CustomScanResult
  factory CustomScanResult.fromScanResult(ScanResult scanResult) {
    return CustomScanResult(
      device: scanResult.device,
      rssi: scanResult.rssi,
      timeStamp: scanResult.timeStamp,
      advertisementData: scanResult.advertisementData,
    );
  }

  /// 从已连接的 BluetoothDevice 创建 CustomScanResult
  factory CustomScanResult.fromBluetoothDevice(BluetoothDevice device) {
    return CustomScanResult(
      device: device,
      rssi: -50, // 默认信号强度
      timeStamp: DateTime.now(),
      advertisementData: null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomScanResult && other.device.remoteId.str == device.remoteId.str;
  }

  @override
  int get hashCode => device.remoteId.str.hashCode;
}