import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/module.dart';
import 'package:serverpod_todo_server/src/generated/protocol.dart';

class TodoEndpoint extends Endpoint {
  Future<void> createTodo(Session session, {required String title}) async {
    final userId = await session.auth.authenticatedUserId;

    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final todo = Todo(user_id: userId, title: title, completed: false);
    Todo.insert(session, todo);
  }

  Future<void> updateTodo(Session session, {required Todo todo}) async {
    await Todo.update(session, todo);
  }

  Future<void> deleteTodo(Session session, {required Todo todo}) async {
    await Todo.deleteRow(session, todo);
  }

  Future<List<Todo>> getTodosForUser(Session session) async {
    final userId = await session.auth.authenticatedUserId;

    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final todos =
        Todo.find(session, where: (todo) => todo.user_id.equals(userId));
    return todos;
  }

  Future<void> makeMeAdmin(Session session) async {
    final userId = await session.auth.authenticatedUserId;
    await Users.updateUserScopes(session, userId!, {Scope.admin});
  }
}
