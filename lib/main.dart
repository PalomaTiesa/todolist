
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const TodoListApp());
}

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController controller = TextEditingController();

  final List<String> tareas = [
    'tarea5',
    'tarea1',
    'tarea4',
    'tarea2',
    'tarea3',
  ];

  // Agregar una tarea
  void agregarTarea() {
    final texto = controller.text.trim();

    if (texto.isEmpty) return;

    setState(() {
      tareas.add(texto);
      controller.clear();
    });
  }

  // Editar una tarea
  void editarTarea(int index) {
    final TextEditingController editarController =
        TextEditingController(text: tareas[index]);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: editarController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre de la tarea',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final texto = editarController.text.trim();

                if (texto.isEmpty) return;

                setState(() {
                  tareas[index] = texto;
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    ).then((_) => editarController.dispose());
  }

  // Eliminar una tarea
  void eliminarTarea(int index) {
    final String tareaEliminada = tareas[index];

    setState(() {
      tareas.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$tareaEliminada eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            setState(() {
              tareas.insert(
                index.clamp(0, tareas.length),
                tareaEliminada,
              );
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 420),
            color: Colors.white,
            child: Column(
              children: [
                // Encabezado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'To Do List',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Campo de texto y botón para agregar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onSubmitted: (_) => agregarTarea(),
                          decoration: const InputDecoration(
                            hintText: 'Ingresa una tarea...',
                            hintStyle: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        height: 34,
                        child: ElevatedButton(
                          onPressed: agregarTarea,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF80A9F5),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 2,
                          ),
                          child: const Icon(Icons.add, size: 23),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFE5E5E5),
                ),

                // Lista de tareas
                Expanded(
                  child: tareas.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay tareas',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount: tareas.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex--;
                              }

                              final tarea = tareas.removeAt(oldIndex);
                              tareas.insert(newIndex, tarea);
                            });
                          },
                          itemBuilder: (context, index) {
                            final tarea = tareas[index];

                            return Slidable(
                              key: ValueKey(tarea),
                              endActionPane: ActionPane(
                                motion: const BehindMotion(),
                                extentRatio: 0.48,
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => editarTarea(index),
                                    backgroundColor:
                                        const Color(0xFF80A9F5),
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Editar',
                                  ),
                                  SlidableAction(
                                    onPressed: (_) => eliminarTarea(index),
                                    backgroundColor:
                                        const Color(0xFFE05252),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Borrar',
                                  ),
                                ],
                              ),
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 42,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              tarea,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          ReorderableDragStartListener(
                                            index: index,
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                              ),
                                              child: Icon(
                                                Icons.drag_handle,
                                                color: Color(0xFFAAAAAA),
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: Color(0xFFE8E8E8),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
