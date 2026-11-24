
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/task_repository_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repositoryProvider = TaskRepositoryProvider();

  await repositoryProvider.initSQLite();

  runApp(
    ChangeNotifierProvider.value(
      value: repositoryProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final TextEditingController controller =
      TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> addTask() async {
    final title = controller.text.trim();

    if (title.isEmpty) return;

    await context
        .read<TaskRepositoryProvider>()
        .addTask(title);

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TaskRepositoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мої завдання'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: state.currentType,
              decoration: const InputDecoration(
                labelText: 'Тип сховища',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'sqlite',
                  child: Text('SQLite'),
                ),
                DropdownMenuItem(
                  value: 'hive',
                  child: Text('Hive'),
                ),
                DropdownMenuItem(
                  value: 'memory',
                  child: Text('In-Memory'),
                ),
              ],
              onChanged: (value) async {
                if (value != null) {
                  await state.changeRepository(value);
                }
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Нове завдання',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addTask(),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton.filled(
                  onPressed: addTask,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text('Усього: ${state.tasks.length}'),

                Text('Виконано: ${state.completedCount}'),
              ],
            ),

            const SizedBox(height: 8),

            Expanded(
              child: state.tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'Поки що завдань немає',
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.tasks.length,

                      itemBuilder: (context, index) {
                        final task = state.tasks[index];

                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) {
                                state.toggleTask(task);
                              },
                            ),

                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),

                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                              ),
                              onPressed: () {
                                state.removeTask(task.id!);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Text(
              'Активне сховище: ${state.currentType.toUpperCase()}',
            ),
          ],
        ),
      ),
    );
  }
}
