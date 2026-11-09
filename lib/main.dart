
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: const TodoPage(),
    );
  }
}

// Clase para representar una tarea
class Tarea {
  int id;
  String nombre;

  Tarea({
    required this.id,
    required this.nombre,
  });
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {

  final TextEditingController controlador = TextEditingController();

  int siguienteId = 6;

  List<Tarea> tareas = [
    Tarea(id: 1, nombre: 'tarea5'),
    Tarea(id: 2, nombre: 'tarea1'),
    Tarea(id: 3, nombre: 'tarea4'),
    Tarea(id: 4, nombre: 'tarea2'),
    Tarea(id: 5, nombre: 'tarea3'),
  ];

  // Agregar una tarea
  void agregarTarea() {
    String nombre = controlador.text.trim();

    if (nombre.isEmpty) return;

    setState(() {
      tareas.add(
        Tarea(
          id: siguienteId++,
          nombre: nombre,
        ),
      );
    });

    controlador.clear();
  }

  // Editar una tarea
  Future<void> editarTarea(int index) async {
    final TextEditingController editarController =
        TextEditingController(text: tareas[index].nombre);

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: editarController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nombre de la tarea',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  editarController.text.trim(),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (resultado != null && resultado.isNotEmpty) {
      setState(() {
        tareas[index].nombre = resultado;
      });
    }

    editarController.dispose();
  }

  // Eliminar una tarea
  Future<bool> eliminarTarea(int index) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Eliminar tarea'),
              content: const Text(
                '¿Estás seguro de eliminar esta tarea?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Cambiar el orden de las tareas
  void reordenarTareas(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex--;
      }

      final tarea = tareas.removeAt(oldIndex);
      tareas.insert(newIndex, tarea);
    });
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Center(
          child: Container(
            width: 500,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),

            child: Column(
              children: [

                // Título
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'To Do List',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Campo para agregar tareas
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [

                      Expanded(
                        child: TextField(
                          controller: controlador,
                          onSubmitted: (_) => agregarTarea(),
                          decoration: const InputDecoration(
                            hintText: 'Ingresa una tarea...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      SizedBox(
                        width: 42,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: agregarTarea,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF80A9F0),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                ),

                // Lista de tareas
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    itemCount: tareas.length,
                    onReorder: reordenarTareas,

                    itemBuilder: (context, index) {

                      final tarea = tareas[index];

                      return Dismissible(
                        key: ValueKey(tarea.id),

                        direction: DismissDirection.horizontal,

                        // Deslizar a la derecha: editar
                        // Deslizar a la izquierda: eliminar
                        confirmDismiss: (direction) async {

                          if (direction ==
                              DismissDirection.startToEnd) {

                            await editarTarea(index);
                            return false;
                          }

                          if (direction ==
                              DismissDirection.endToStart) {

                            return await eliminarTarea(index);
                          }

                          return false;
                        },

                        background: Container(
                          color: Colors.blue,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),

                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),

                        onDismissed: (_) {
                          setState(() {
                            tareas.removeWhere(
                              (element) => element.id == tarea.id,
                            );
                          });
                        },

                        child: Container(
                          height: 66,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),

                          child: Row(
                            children: [

                              Expanded(
                                child: Text(
                                  tarea.nombre,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              // Control para reordenar
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
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
