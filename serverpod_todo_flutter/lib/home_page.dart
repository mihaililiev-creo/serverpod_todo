import 'package:flutter/material.dart';
import 'package:serverpod_todo_client/serverpod_todo_client.dart';
import 'package:serverpod_todo_flutter/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? _resultMessage;
  String? _errorMessage;
  List<Todo>? todos;

  final _textEditingController = TextEditingController();

  @override
  void initState() {
    _getTodosForUser();
    super.initState();
  }

  void _addTodo({required String title}) async {
    try {
      await client.todo.createTodo(title: title);
      setState(() {
        _resultMessage = 'Todo created';
      });
      _getTodosForUser();
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  void _updateTodo({
    required Todo todo,
    required bool completed,
  }) async {
    try {
      todo.completed = completed;
      await client.todo.updateTodo(todo: todo);
      setState(() {
        _resultMessage = 'Todo updated';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  void _deleteTodo({
    required Todo todo,
  }) async {
    try {
      await client.todo.deleteTodo(todo: todo);
      setState(() {
        _getTodosForUser();
        _resultMessage = 'Todo deleted';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  void _getTodosForUser() async {
    try {
      final userTodos = await client.todo.getTodosForUser();

      setState(() {
        todos = userTodos;

        _resultMessage = 'Todos: ${todos?.length}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...?todos?.map((todo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(todo.title),
                    ),
                    Checkbox(
                      value: todo.completed,
                      onChanged: (value) =>
                          _updateTodo(todo: todo, completed: value!),
                    ),
                    sessionManager.signedInUser?.scopeNames
                                .where((e) => e.contains('admin'))
                                .isNotEmpty ??
                            false
                        ? ElevatedButton(
                            onPressed: () => _deleteTodo(todo: todo),
                            child: const Text('Delete'))
                        : const SizedBox.shrink()
                  ],
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Enter todo title',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () => _addTodo(title: _textEditingController.text),
                child: const Text('Send to Server'),
              ),
            ),
            _ResultDisplay(
              resultMessage: _resultMessage,
              errorMessage: _errorMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// _ResultDisplays shows the result of the call. Either the returned result from
// the `example.hello` endpoint method or an error message.
class _ResultDisplay extends StatelessWidget {
  final String? resultMessage;
  final String? errorMessage;

  const _ResultDisplay({
    this.resultMessage,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    if (errorMessage != null) {
      backgroundColor = Colors.red[300]!;
      text = errorMessage ?? '';
    } else if (resultMessage != null) {
      backgroundColor = Colors.green[300]!;
      text = resultMessage ?? '';
    } else {
      backgroundColor = Colors.grey[300]!;
      text = 'No server response yet.';
    }

    return Container(
      height: 50,
      color: backgroundColor,
      child: Center(
        child: Text(text),
      ),
    );
  }
}
