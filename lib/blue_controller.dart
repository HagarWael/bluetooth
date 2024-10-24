import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BlueController extends GetxController {
  var devicesList = <BluetoothDevice>[].obs;
  BluetoothDevice? connectedDevice;

  Future<void> scanDevices() async {
    devicesList.clear();
    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.contains(r.device)) {
          devicesList.add(r.device);
          print("Found device: ${r.device.platformName} - ${r.device.advName}");
        }
      }
    });

    await Future.delayed(Duration(seconds: 4));
    FlutterBluePlus.stopScan();
    print("Scan stopped.");
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await device.connect();
        connectedDevice = device;
        print("Connected to ${device.name}");
        return;
      } catch (e) {
        print("Error connecting to device: $e");
        if (retryCount == maxRetries - 1) {
          String errorMessage =
              'Could not connect to ${device.name} after $maxRetries attempts.';
          Get.snackbar('Connection Error', errorMessage,
              snackPosition: SnackPosition.BOTTOM);
        }
        retryCount++;
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  Future<void> disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
    }
  }

  List<BluetoothDevice> getDevices() {
    return devicesList;
  }
}
