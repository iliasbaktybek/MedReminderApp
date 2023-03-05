import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:reminder/core/models/medication.dart';
import 'package:reminder/notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMedicationView extends StatefulWidget {
  const AddMedicationView({super.key});

  @override
  State<AddMedicationView> createState() => _AddMedicationViewState();
}

class _AddMedicationViewState extends State<AddMedicationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  final _timeController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timeController.text = selectedTime.format(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Name cannot be empty!' : null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  labelStyle: const TextStyle(color: Colors.black),
                  label: const Text('Name'),
                  hintText: 'Name',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.done,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Description cannot be empty' : null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  labelStyle: const TextStyle(color: Colors.black),
                  label: const Text('Description'),
                  hintText: 'Description',
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                      _timeController.text = selectedTime.format(context);
                    });
                  }
                },
                child: TextFormField(
                  controller: _timeController,
                  enabled: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    labelStyle: const TextStyle(color: Colors.black),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    label: const Text('Time'),
                    hintText: 'Time',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Medication'),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs
              .setInt('index', (prefs.getInt('index') ?? -1) + 1)
              .then((_) async {
            if (_formKey.currentState?.validate() ?? false) {
              final medicationsBox = Hive.box('medications');
              final medication = Medication(
                _nameController.text,
                _descriptionController.text,
                selectedTime,
                prefs.getInt('index')!,
              );
              await NotificationController.scheduleNotification(
                context,
                medication,
              );
              medicationsBox.add(medication).then((_) {
                Navigator.pop(context);
              });
            }
          });
        },
      ),
    );
  }
}
