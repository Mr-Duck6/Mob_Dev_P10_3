
import 'package:hive/hive.dart';
import 'task.dart';

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final id = reader.readInt();
    final title = reader.readString();
    final isCompleted = reader.readBool();

    return Task(
      id: id,
      title: title,
      isCompleted: isCompleted,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeInt(obj.id ?? 0);
    writer.writeString(obj.title);
    writer.writeBool(obj.isCompleted);
  }
}
