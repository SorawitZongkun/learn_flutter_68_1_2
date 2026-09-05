import 'package:flutter/material.dart';

// Step 2: Install loading app screen
import 'package:learn_flutter_68_1_2/first_screen.dart';

// Step 5: Connect to Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Step 5: Connect to Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Step 7: Firebase CRUD operations
  runApp(MaterialApp(home: FirstScreen(), debugShowCheckedModeBanner: false));
}
