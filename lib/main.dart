import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:reminder/core/models/medication.dart';
import 'package:reminder/notification_controller.dart';
import 'package:reminder/ui/view/home_view.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
// import 'package:http/http.dart' as http;

Future<void> main() async {
  await NotificationController.initializeLocalNotifications();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(MedicationAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const RootView(),
    ),
  );
}

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox('medications'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Icon(Icons.error)),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const HomeView();
      },
    );
  }
}
