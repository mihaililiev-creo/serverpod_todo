import 'package:flutter/material.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_todo_client/serverpod_todo_client.dart';
import 'package:serverpod_todo_flutter/home_page.dart';
import 'package:serverpod_todo_flutter/login_page.dart';

late Client client;
late SessionManager sessionManager;

void main() async {
// Need to call this as we are using Flutter bindings before runApp is called.
  WidgetsFlutterBinding.ensureInitialized();

  // The android emulator does not have access to the localhost of the machine.
  // const ipAddress = '10.0.2.2'; // Android emulator ip for the host

  // On a real device replace the ipAddress with the IP address of your computer.
  const ipAddress = 'localhost';

  // Sets up a singleton client object that can be used to talk to the server from
  // anywhere in our app. The client is generated from your server code.
  // The client is set up to connect to a Serverpod running on a local server on
  // the default port. You will need to modify this to connect to staging or
  // production servers.
  client = Client(
    'http://$ipAddress:8080/',
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  // The session manager keeps track of the signed-in state of the user. You
  // can query it to see if the user is currently signed in and get information
  // about the user.
  sessionManager = SessionManager(
    caller: client.modules.auth,
  );
  await sessionManager.initialize();

  final authenticated = sessionManager.isSignedIn;

  runApp(MyApp(
    authenticated: authenticated,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.authenticated}) : super(key: key);

  final bool authenticated;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: authenticated ? '/' : '/login',
      routes: {
        '/': (context) => const HomePage(title: 'Serverpod Example'),
        '/login': (context) => const LoginPage()
      },
    );
  }
}
