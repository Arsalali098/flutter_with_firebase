import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Users");


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUD Operation using Firebase"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Username",
                hintText: "Username",
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                )
              ),
            ),

            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  )
              ),
            ),

            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  )
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Text("Create"),
                    onPressed: () {
                      createData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: dbRef.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                    Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<dynamic> list = [];
                    map.forEach((key, value) {
                      list.add(value);
                    });

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                },
                          ),
                          onTap: () {
                            nameController.text = list[index]['userName'] ?? "";
                            emailController.text = list[index]['userEmail'] ?? "";
                            passwordController.text = list[index]['userPassword'] ?? "";
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No Data Found"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createData() {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      print("Please fill all fields");
      return;
    }

    Map<String, dynamic> users = {
      "userName" : nameController.text,
      "userEmail" : emailController.text,
      "userPassword" : passwordController.text
    };

    dbRef.child(nameController.text).set(users).whenComplete((){
      print("${nameController.text} Created!");
      clearFields();
    });
  }

  void readData() {
    if (nameController.text.isEmpty) {
      print("Please enter a username to read data");
      return;
    }

    dbRef.child(nameController.text).get().then((datasnapshot) {
      if (datasnapshot.exists) {
        Map<dynamic, dynamic>? data = datasnapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          nameController.text = data["userName"] ?? "";
          emailController.text = data["userEmail"] ?? "";
          passwordController.text = data["userPassword"] ?? "";
        }
      } else {
        print("No data found for ${nameController.text}");
      }
    });
  }

  void updateData() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a user to update")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Are you sure you want to update this user's data?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Map<String, dynamic> users = {
                "userName": nameController.text,
                "userEmail": emailController.text,
                "userPassword": passwordController.text
              };

              dbRef.child(nameController.text).update(users).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data Updated Successfully")),
                );
                clearFields();
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update: $error")),
                );
              });
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void deleteData(String name) {
    if (name.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              dbRef.child(name).remove().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data Deleted Successfully")),
                );
                clearFields();
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete: $error")),
                );
              });
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void clearFields() {
      nameController.clear();
      emailController.clear();
      passwordController.clear();
  }
}
