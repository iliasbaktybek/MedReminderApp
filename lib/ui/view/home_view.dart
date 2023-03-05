import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:reminder/core/models/medication.dart';
import 'package:reminder/notification_controller.dart';
import 'package:reminder/ui/view/add_medication_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final medicationsBox = Hive.box('medications');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicaitons')),
      body: ValueListenableBuilder(
        valueListenable: medicationsBox.listenable(),
        builder: (_, box, __) {
          log(box.toMap().toString());
          return box.isEmpty
              ? const Center(child: Text('No medications yet'))
              : ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (_, index) {
                    final medication =
                        box.toMap().values.toList()[index] as Medication;
                    return ListTile(
                      leading: Text(medication.time.format(context)),
                      title: Text(medication.name),
                      subtitle: Text(medication.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await NotificationController.cancelNotification(
                            medication.id,
                          );
                          await box.deleteAt(index);
                        },
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Medication'),
        onPressed: () => Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const AddMedicationView()),
        ),
      ),
    );
  }
}
