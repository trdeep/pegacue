import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/custom_scan_result.dart';
import '../services/global.dart';

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  final Set<CustomScanResult> _scanResults = {};
  bool _isScanning = false;
  String? _connectingDeviceId;

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    await _checkBluetoothState();
    _updateConnectedDevices();

    FlutterBluePlus.events.onConnectionStateChanged.listen((event) {
      if (event.connectionState == BluetoothConnectionState.disconnected) {
        debugPrint('全局监听：蓝牙断开');
        if (mounted) {
          setState(() {
            Global.connectedDevices.remove(event.device.remoteId.str);
            _scanResults.removeWhere((result) =>
                result.device.remoteId.str == event.device.remoteId.str);
          });
        }
      } else {
        debugPrint('全局监听：蓝牙连接');
        Global.setBluetoothDevice(event.device);
      }
    });

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        if (!_isScanning) {
          _startScan();
        }
      } else {
        if (mounted) {
          setState(() {
            _isScanning = false;
            _scanResults.clear();
          });
        }
      }
    });
  }

  void _updateConnectedDevices() {
    _scanResults.clear();

    try {
      final connectedDevices = FlutterBluePlus.connectedDevices;
      setState(() {
        for (var device in connectedDevices) {
          if (Global.connectedDevices.contains(device.remoteId.str)) {
            // 已经记录的连接设置
            _scanResults.add(CustomScanResult.fromBluetoothDevice(device));
            continue;
          }

          Global.connectedDevices.add(device.remoteId.str);
          // 将已连接设备添加到扫描结果列表
          final existingResult = _scanResults
              .where(
                  (result) => result.device.remoteId.str == device.remoteId.str)
              .firstOrNull;
          if (existingResult == null) {
            _scanResults.add(CustomScanResult.fromBluetoothDevice(device));
          }
        }
      });
    } catch (e) {
      _showError('获取已连接设备失败: $e');
    }
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _checkBluetoothState() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        if (!mounted) return;
        _showError('此设备不支持蓝牙功能');
        return;
      }

      // 请求蓝牙权限
      await Permission.bluetooth.request();

      // 检查蓝牙是否开启
      if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.off) {
        if (!mounted) return;
        _showError('请开启蓝牙');
        await FlutterBluePlus.turnOn();
        return;
      }

      // 蓝牙状态监听已移至 _initBluetooth 方法
    } catch (e) {
      _showError('蓝牙初始化失败: $e');
    }
  }

  Future<void> _startScan() async {
    _updateConnectedDevices();

    if (_isScanning) return;

    _checkBluetoothState();

    try {
      setState(() {
        _isScanning = true;
      });

      await FlutterBluePlus.stopScan();
      _scanResultsSubscription?.cancel();

      _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          if (mounted) {
            setState(() {
              _scanResults.addAll(results
                  .where((s) => s.device.platformName.isNotEmpty)
                  .map((result) => CustomScanResult.fromScanResult(result)));
            });
          }
        },
        onError: (error) {
          _showError('扫描出错: $error');
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
          }
        },
      );

      if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on) {
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 10),
        );
      }

      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      _showError('扫描失败: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // 断开所有已连接的设备
      final connectedDevices = FlutterBluePlus.connectedDevices;
      for (var connectedDevice in connectedDevices) {
        if (connectedDevice.remoteId.str != device.remoteId.str) {
          await connectedDevice.disconnect();
          setState(() {
            Global.connectedDevices.remove(connectedDevice.remoteId.str);
          });
        }
      }

      await device.connect();
      setState(() {
        Global.connectedDevices.add(device.remoteId.str);
      });
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          setState(() {
            Global.connectedDevices.remove(device.remoteId.str);
          });
          _connectionStateSubscription?.cancel();
        }
      });
      _showMessage('连接成功');
    } catch (e) {
      _showError('连接失败，请重试');
    }
  }

  Future<void> _disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      setState(() {
        Global.connectedDevices.remove(device.remoteId.str);
      });
      _showMessage('已断开连接');
    } catch (e) {
      _showError('断开连接失败: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('蓝牙设备扫描'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _startScan,
        child: ListView.builder(
          itemCount: _scanResults.length,
          itemBuilder: (context, index) {
            final result = _scanResults.elementAt(index);
            final device = result.device;
            final rssi = result.rssi;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.bluetooth,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  device.platformName.isEmpty ? '未知设备' : device.platformName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.remoteId.str),
                    Text(
                      '信号强度: ${rssi}dBm',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 70,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Global.connectedDevices.contains(device.remoteId.str)
                              ? Colors.red.withOpacity(0.6)
                              : Colors.orange.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      if (_isScanning) return;
                      setState(() {
                        _connectingDeviceId = device.remoteId.str;
                      });
                      try {
                        if (Global.connectedDevices
                            .contains(device.remoteId.str)) {
                          await _disconnectDevice(device);
                        } else {
                          await _connectToDevice(device);
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _connectingDeviceId = null;
                          });
                        }
                      }
                    },
                    child: _connectingDeviceId == device.remoteId.str
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            Global.connectedDevices
                                    .contains(device.remoteId.str)
                                ? '断开'
                                : '连接',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
