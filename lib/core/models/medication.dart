import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'medication.g.dart';

@HiveType(typeId: 0)
class Medication {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(3)
  final TimeOfDay time;

  @HiveField(4)
  final int id;

  Medication(this.name, this.description, this.time, this.id);
}
