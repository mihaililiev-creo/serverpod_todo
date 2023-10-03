# Todo CRUD app example with Serverpod

In this example, we will go through all the steps to set a functional, working Todo list that reads and writes to a database.
You can check the commit history for a breakdown of each process written in code. Here I will go step-by-step, explaining each process and what is happening.

### Project Prerequisites

1. **Flutter SDK**: Install from [Flutter Installation](https://flutter.dev/docs/get-started/install).
   - Verify installation: `flutter --version`

2. **Docker**: Install from [Docker Installation](https://docs.docker.com/engine/install/).
3. **Postico 2** (Optional): Install from [Postico Installation](https://eggerapps.at/postico2/).


### If you want to run this project:
1. Clone the github repo to your machine.
2. Create a `passwords.yaml` file in the server's `config` folder.
3. Add the passwords from the `docker-compose.yaml` file.
4. Run `docker-compose up --build --detach`
5. Run `flutter pub get` in every folder.
6. Run `serverpod generate` in the server folder.
7. From the server folder run `dart bin/main.dart` to start the server.
8. Start the app.


## 1) Creating a servepod project
To create a serverpod app, you first need to install the Serverpod CLI by running

```
dart pub global activate serverpod_cli
```

in the terminal.
From there you can generate a project with
```
serverpod create my_app
```
This is similar to `flutter create`. This will generate a client folder, server folder and frontend folder (called flutter).
All the communication with the database will happen through the server folder, and the client folder is there to make the connection between the server and the frontend.
Generally you will never need to modify the client folder.

The `serverpod create` command will also build and run 2 `Docker` containers in a collection - a `postgres` and a `redis` one.
The `postgres` container is where our DB will be stored and the `redis` container is used for in-memory caching. A `passwords.yaml` file will be generated as well, which will hold all the passwords and is used by the server to connect to the containers.

>SIDE NOTE: The `passwords.yaml` file is contained in `.gitignore`, so in case you will use multiple machines for development, it has to be handed out manually. The default Serverpod ports for postgres and redis are 8090 and 8091, but they can be changed in the `docker-compose` and `development.yaml` files.

With all this done, you should have a `postgres` and `redis` container running, and you should be able to connect to them, using the passwords provided.

## 2) Adding the authentication module
To take advantage of Serverpod's built-in user management and authentication, you will have to install their authentication module, which is not included from the `serverpod create` command. Since all 3 folders communicate between eachother, we have to set it up in all 3 places.

1) ### Authentication module in the server folder
   Add the module as a dependancy in the `pubspeck.yaml` file:
   ```pubspeck.yaml
   dependencies:
     ...
     serverpod_auth_server: ^1.x.x // Check latest version of Serverpod
   ```
   You can also add a nickname to the module in the `config/generator.yaml` file. This nickname will be used as the name of the module in the code. The conventional one is to call it `auth`, but you can use something else if you prefer so.
   ```generator.yaml
   modules:
     serverpod_auth:
       nickname: auth
   ```
3) ### Authentication module in the client folder
   Add the module as a dependancy in the `pubspeck.yaml` file:
   ```pubspeck.yaml
   dependencies:
     ...
     serverpod_auth_client: ^1.x.x // Check latest version of Serverpod
   ```
3) ### Authentication module in the flutter folder
   First, add dependencies to your app's `pubspec.yaml` file. You will also have to add the dependancies for the methods of signing in that you want to support. In this example we will only look into email signup, but all conventional social signings are also available.
   ```pubspeck.yaml
   dependencies:
     flutter:
       sdk: flutter
     serverpod_flutter: ^1.x.x
     auth_example_client:
       path: ../auth_example_client
     serverpod_auth_shared_flutter: ^1.x.x
     serverpod_auth_email_flutter: ^1.x.x // Used for email authentication
   ```

After adding the dependancies, it's time to create the tables needed for Serverpod to handle the authentication. You can find the `pgsql` table definitions [here](https://github.com/serverpod/serverpod/blob/main/modules/serverpod_auth/serverpod_auth_server/generated/tables.pgsql). Either copy or import them in the server's `generated/tables-auth.pgsql` file. Then run the SQL in your database.

>If you don't have much experience in databases, you can download [Postico 2](https://eggerapps.at/postico2/) and manage your database from there.

Now we need to configure our app to actually use the authentication module. To do that you need to set up a `SessionManager`, which keeps track of the user's state. It will also handle the authentication keys passed to the client from the server, upload user profile images, etc.
We also have to set up the Serverpod `Client` in the same pl to use the authentication.

In `my_app_flutter/main.dart`:
```flutter/main.dart
late SessionManager sessionManager;
late Client client;
void main() async {
   ...
   client = Client(
      'http://$ipAddress:8080/',
      authenticationKeyManager: FlutterAuthenticationKeyManager(),
      )..connectivityMonitor = FlutterConnectivityMonitor();

   sessionManager = SessionManager(
     caller: client.modules.auth,
   );
   await sessionManager.initialize();
   ...
}
```


You can see the full example in the repository's `main.dart` file. What this does esentially is that it reads form the tables that we just created and gives us access to the state of the user, without us having to set any of that communication ourselves.

## 3) Configuring the email provider
Since in this example, we are using email for authentication, Serverpod's email authentication has a built-in verification by code. This verification code is usually sent via email. To send emails to your users, you have to modify the `server.dart` file. This is the file from which the server is run.

Start by importing the: `import 'package:serverpod_auth_server/module.dart' as auth;`. Then in the `run` method and just above the `pod.start()`, we can configure the authentication module.
```server.dart
void run(List<String> args) async {
   ...
   auth.AuthConfig.set(auth.AuthConfig(
     sendValidationEmail: (session, email, validationCode) async {
       // Send the validation email to the user.
       // Return `true` if the email was successfully sent, otherwise `false`.
       return true;
     },
     sendPasswordResetEmail: (session, userInfo, validationCode) async {
       // Send the password reset email to the user.
       // Return `true` if the email was successfully sent, otherwise `false`.
       return true;
     },
   ));

   // Start the Serverpod server.
   await pod.start();
}
```

We will be using [`mailer`](https://pub.dev/packages/mailer) with gmail in this example. For `mailer` to work with gmail, you need to create an [App Password](https://support.google.com/accounts/answer/185833?hl=en). Once created, you have to add your email and the app password connected to it in the `passwords.yaml` file. In this example the keys given to those values are `gmailEmail` and `gmailPassword`. We can get those values by calling `session.serverpod.getPassword(key)` after. This is shown in this repository.

## 4) Create login page
Serverpod has a prebuilt signin button widget. It handles both signup and signin, and also the verification. This is used in this example.
```login.dart
SignInWithEmailButton(
  caller: client.modules.auth,
  onSignedIn: () {
    // Optional callback when user successfully signs in
  },
),
```

You can also create a custom login form for your app. The available methods to use are shown [here](https://docs.serverpod.dev/concepts/authentication/providers/email#custom-ui-with-emailauthcontroller).

## 5) Create a custom table and a serializable class to communicate with it.
To create our own custom table, we first have to define its fields in a `.yaml` file inside the `/lib/src/protocol/` folder in the `server`. For this example we have a `todo.yaml` that has 3 fields:
- `user_id` connected to the user that created the todo
- `title`
- `completed` boolean

The fields support all serializable Dart classes with the option to put them in `List`s or `Map`s.
>To learn more about serialization in Serverpod, look [here](https://docs.serverpod.dev/concepts/serialization).

Now, after running `serverpod generate` (which is the CLI command that tells Serverpod to generate code), you will see that the `tables.pgsql` is populated with the table you just defined. Run the SQL in your database.

>If you already have data that you want to use, you can populate the table after creating it.

## 6) Configuring an endpoint
We now should have both the serializable `Todo` class and the `todos` table. Let's configure our endpoint:

1. **Create an Endpoint:**
    - Navigate to the `lib/src/endpoints/` folder.
    - Create a new file for your endpoint, e.g., `todo_endpoint.dart`.

2. **Extend the `Endpoint` Class:**
    - Inside the new file, create a class that extends Serverpod's `Endpoint` class.
    - In this example, name the class `TodoEndpoint`.

3. **Define Operations:**
    - Add methods within `TodoEndpoint` for the specific CRUD operations you intend to perform.
    - The `todo_endpoint.dart` file in this example showcases basic CRUD operations.

Now, you have successfully set up your endpoint for communication with the table in your database.
Just run `serverpod generate` so that the app knows about that endpoint. Yep, it's that easy.

## 7) Calling our endpoint in the app
To call the endpoint on the app, we just need to call it through the `client` that is set up initially. In our case, with the `TodoEndpoint` class, we can call `client.todo.myEndpointMethod`.
>The name of the endpoint is the same as the class but removing "Endpoint" and it is generated in camelCase.

So let's say we want to have a `createTodo` method in that class that accepts a `Todo` (the generated class from the `todo.yaml` file). To call it in the app, we will do `client.todo.createTodo(todo)`. The `Todo.insert` method in the endpoint will create a SQL query in the background and run it in our database. After that we can see that a new record is created in our `todos` table.

All CRUD generated classes' static methods to communicate with the database:
1. **Create**
   - `insert` - inserts a row in the table
2. **Read**
   - `findById` - find a single row that matched the specified id
   - `find` - find multiple rows by specified matcher
   - `findSingleRow` - find the first row by specified matcher
3. **Update**
   - `update` - updates the row given as an argument, matched by id
4. **Delete**
   - `delete` - delete all rows by a given matcher
   - `deleteRow` - deletes the row given as argument, tached by id

## Conclusion
Serverpod is a fantastic tool, especially for crafting MVPs or straightforward applications. However, it's still in the early stages of development and could benefit from the addition of some crucial ORM features necessary for handling larger databases. While they offer the option to execute custom SQL, it's best viewed as a last resort. In the current phase of Serverpod, relying on custom SQL is likely unavoidable for more extensive and intricate databases.

Nontheless the ability to start a server, connect to a DB and configure CRUD operations in about half an hour, is incredibly fast and if they continue to update regularly, it has a lot of potential.
