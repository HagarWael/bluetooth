import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:p2/blue_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BlueController controller = Get.put(BlueController());
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }

    if (await Permission.location.isGranted) {
      controller.scanDevices();
    } else {
      print('Location permission denied. Bluetooth scan will not work.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blue Scanner'),
      ),
      body: Obx(() {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: controller.devicesList.isNotEmpty
                    ? ListView.builder(
                        itemCount: controller.devicesList.length,
                        itemBuilder: (context, index) {
                          final device = controller.devicesList[index];
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(device.platformName.isNotEmpty
                                  ? device.platformName
                                  : "Unknown Device"),
                              subtitle: Text(device.id.id),
                              trailing: IconButton(
                                icon: const Icon(Icons.bluetooth),
                                onPressed: () {
                                  controller.connectToDevice(device);
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : const Text('No nearby devices found'),
              ),
              ElevatedButton(
                onPressed: () => controller.scanDevices(),
                child: const Text('Scan'),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      }),
    );
  }
}
