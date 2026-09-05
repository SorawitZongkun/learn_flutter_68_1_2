// Step 2: Install loading app screen
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

// Step 3: Check internet connection
import 'package:connectivity_plus/connectivity_plus.dart';
// Step 4: Show toast message
import 'package:fluttertoast/fluttertoast.dart';

// Step 7: Firebase CRUD operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_flutter_68_1_2/services/firestore.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  // อะไรที่อยากจะให้ทำงานตอนเริ่มต้น ให้ใส่ในนี้
  void initState() {
    super.initState();

    // Step 3: Check internet connection
    checkInternetConnection();
  }

  void checkInternetConnection() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity()
        .checkConnectivity());

    // Determines whether any active network connection exists.
    if (connectivityResult.hasConnectivity) {
      // Connectivity available (regardless of the underlying transport).
    }

    // This condition is for demo purposes only to explain every connection type.
    // Use conditions which work for your requirements.
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
      _showToast(context, "Mobile network available.");
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      _showToast(context, "Wi-fi is available.");
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
      _showToast(context, "Ethernet connection available.");
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
      _showToast(context, "Vpn connection active.");
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
      _showToast(context, "Bluetooth connection available.");
    } else if (connectivityResult.contains(ConnectivityResult.satellite)) {
      // Carrier-provided satellite network available
      _showToast(context, "Satellite network available.");
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      // Connected to a network which is not in the above mentioned networks.
      _showToast(context, "Other network available.");
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      // No available network types
      setState(() {
        _showAlertDialog(context, "No Internet", "Please check your internet.");
      });
    }
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepOrange],
          begin: FractionalOffset(0, 0),
          end: FractionalOffset(0.5, 0.6),
          tileMode: TileMode.mirror,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(child: Image.asset("./android/assets/image/app_screen.png")),
          const SizedBox(height: 20),
          const SpinKitSpinningLines(color: Colors.green),
        ],
      ),
    );
  }
}

// class SecondScreen extends StatelessWidget {
//   const SecondScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Second Screen")),
//       body: Center(
//         child: Text(
//           "This is a second page.",
//           style: TextStyle(
//             fontSize: 24,
//             color: Colors.amberAccent,
//             fontWeight: FontWeight.w700,
//             fontFamily: "Alike",
//           ),
//         ),
//       ),
//     );
//   }
// }

// Step 7: Firebase CRUD operations
class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  // make an instance of FirestoreService
  final FirestoreService firestoreService = FirestoreService();

  // text editing controllers for the input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // Open a dialog to add a new person
  void openPersonBox(String? personId) async {
    if (personId != null) {
      // Update Case
      final personData = await firestoreService.getPersonById(personId);
      nameController.text = personData?['personName'] ?? '';
      emailController.text = personData?['personEmail'] ?? '';
      ageController.text = personData?['personAge']?.toString() ?? '';
    } else {
      // Create Case
      nameController.clear();
      emailController.clear();
      ageController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final String name = nameController.text;
              final String email = emailController.text;
              final int age = int.tryParse(ageController.text) ?? 0;

              if (personId != null) {
                // Update existing person
                firestoreService.updatePerson(personId, name, email, age);
              } else {
                // Add new person
                firestoreService.addPerson(name, email, age);
              }

              nameController.clear();
              emailController.clear();
              ageController.clear();

              Navigator.of(context).pop();
            },
            child: Text(personId != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Person List"),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            openPersonBox(null), // Open dialog for adding new person
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPersons(),
        builder: (context, snapshot) {
          // if we have data, get the list of persons and display them in a ListView
          if (snapshot.hasData) {
            final personList = snapshot.data!.docs;

            // Display the list of persons in a ListView
            return ListView.builder(
              itemCount: personList.length,
              itemBuilder: (context, index) {
                // Get each the person document
                DocumentSnapshot personDoc = personList[index];
                String personId = personDoc.id;

                // Get person from the document data
                Map<String, dynamic> personData =
                    personDoc.data() as Map<String, dynamic>;

                String personName = personData['personName'] ?? '';
                String personEmail = personData['personEmail'] ?? '';
                int personAge = personData['personAge'] ?? 0;

                return ListTile(
                  title: Text(personName),
                  subtitle: Text('Email: $personEmail, Age: $personAge'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => openPersonBox(personId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          firestoreService.deletePerson(personId);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            // If we don't have data, show a message indicating that no persons were found
            return const Center(child: Text("No persons found"));
          }
        },
      ),
    );
  }
}

// Step 4: Show toast message
void _timer(BuildContext context) {
  // เมื่อครบ 3 วิ ให้ไปหน้า Second Screen
  Timer(
    const Duration(seconds: 3),
    () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecondScreen()),
    ),
  );
}

void _showToast(BuildContext context, String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.brown,
    textColor: Colors.white,
    fontSize: 24,
  );
  _timer(context);
}

void _showAlertDialog(BuildContext context, String title, String msg) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
            fontFamily: "Alike",
          ),
        ),
        content: Text(msg),
        actions: <Widget>[
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.black45),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                fontSize: 20,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
                fontFamily: "Alike",
              ),
            ),
          ),
        ],
      );
    },
  );
}
