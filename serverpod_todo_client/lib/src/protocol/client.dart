/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:serverpod_todo_client/src/protocol/todo.dart' as _i3;
import 'package:serverpod_auth_client/module.dart' as _i4;
import 'dart:io' as _i5;
import 'protocol.dart' as _i6;

class _EndpointExample extends _i1.EndpointRef {
  _EndpointExample(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'example';

  _i2.Future<String> hello(String name) => caller.callServerEndpoint<String>(
        'example',
        'hello',
        {'name': name},
      );
}

class _EndpointTodo extends _i1.EndpointRef {
  _EndpointTodo(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'todo';

  _i2.Future<void> createTodo({required String title}) =>
      caller.callServerEndpoint<void>(
        'todo',
        'createTodo',
        {'title': title},
      );

  _i2.Future<void> updateTodo({required _i3.Todo todo}) =>
      caller.callServerEndpoint<void>(
        'todo',
        'updateTodo',
        {'todo': todo},
      );

  _i2.Future<void> deleteTodo({required _i3.Todo todo}) =>
      caller.callServerEndpoint<void>(
        'todo',
        'deleteTodo',
        {'todo': todo},
      );

  _i2.Future<List<_i3.Todo>> getTodosForUser() =>
      caller.callServerEndpoint<List<_i3.Todo>>(
        'todo',
        'getTodosForUser',
        {},
      );

  _i2.Future<void> makeMeAdmin() => caller.callServerEndpoint<void>(
        'todo',
        'makeMeAdmin',
        {},
      );
}

class _Modules {
  _Modules(Client client) {
    auth = _i4.Caller(client);
  }

  late final _i4.Caller auth;
}

class Client extends _i1.ServerpodClient {
  Client(
    String host, {
    _i5.SecurityContext? context,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
  }) : super(
          host,
          _i6.Protocol(),
          context: context,
          authenticationKeyManager: authenticationKeyManager,
        ) {
    example = _EndpointExample(this);
    todo = _EndpointTodo(this);
    modules = _Modules(this);
  }

  late final _EndpointExample example;

  late final _EndpointTodo todo;

  late final _Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'example': example,
        'todo': todo,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
