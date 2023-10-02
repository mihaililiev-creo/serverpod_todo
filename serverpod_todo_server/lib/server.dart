import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/module.dart' as auth;
import 'package:serverpod_todo_server/src/web/routes/root.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  // If you are using any future calls, they need to be registered here.
  // pod.registerFutureCall(ExampleFutureCall(), 'exampleFutureCall');

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
    '/*',
  );

  auth.AuthConfig.set(auth.AuthConfig(
    sendValidationEmail: (session, email, validationCode) async {
      // Retrieve the credentials
      // These values have to be defined in passwords.yaml under the env you are running
      // The serverpod.getPassword methods retrieves them by their key name
      // Example in passwords.yaml: gmailEmail: 'myemail@gmailcom' / gmailPassword: 'mypassword'
      final gmailEmail = session.serverpod.getPassword('gmailEmail')!;
      final gmailPassword = session.serverpod.getPassword('gmailPassword')!;

      // Create a SMTP client for Gmail
      final smtpServer = gmail(gmailEmail, gmailPassword);

      // Create an email message with the validation code.
      final message = Message()
        ..from = Address(gmailEmail)
        ..recipients.add(email)
        ..subject = 'Verification code for Serverpod'
        ..html = 'Your verification code is: $validationCode';

      // Send the email message.
      try {
        await send(message, smtpServer);
      } catch (_) {
        // Return false if the email could not be sent.
        return false;
      }

      return true;
    },
    sendPasswordResetEmail: (session, userInfo, validationCode) async {
      // Retrieve the credentials
      final gmailEmail = session.serverpod.getPassword('gmailEmail')!;
      final gmailPassword = session.serverpod.getPassword('gmailPassword')!;

      // Create a SMTP client for Gmail.
      final smtpServer = gmail(gmailEmail, gmailPassword);

      // Create an email message with the password reset link.
      final message = Message()
        ..from = Address(gmailEmail)
        ..recipients.add(userInfo.email!)
        ..subject = 'Password reset link for Serverpod'
        ..html = 'Here is your password reset code: $validationCode>';

      // Send the email message.
      try {
        await send(message, smtpServer);
      } catch (_) {
        // Return false if the email could not be sent.
        return false;
      }

      return true;
    },
  ));

  // Start the server.
  await pod.start();
}
