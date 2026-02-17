// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedReportModelAdapter extends TypeAdapter<SavedReportModel> {
  @override
  final int typeId = 0;

  @override
  SavedReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedReportModel(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      scanTypeString: fields[2] as String,
      diagnosisJson: (fields[3] as Map).cast<dynamic, dynamic>(),
      patientInfoJson: (fields[4] as Map).cast<dynamic, dynamic>(),
      healthReportJson: (fields[5] as Map?)?.cast<dynamic, dynamic>(),
      timestamp: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedReportModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.scanTypeString)
      ..writeByte(3)
      ..write(obj.diagnosisJson)
      ..writeByte(4)
      ..write(obj.patientInfoJson)
      ..writeByte(5)
      ..write(obj.healthReportJson)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
