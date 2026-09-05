// Step 6: Make a firestore.dart file in the services folder
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference persons = FirebaseFirestore.instance.collection(
    'persons',
  );

  // Create a new person
  Future<void> addPerson(String personName, String personEmail, int personAge) {
    return persons.add({
      'personName': personName,
      'personEmail': personEmail,
      'personAge': personAge,
      'createdAt': Timestamp.now(),
    });
  }

  // Read all persons
  Stream<QuerySnapshot> getPersons() {
    return persons.orderBy('createdAt', descending: true).snapshots();
  }

  // Get a single person by ID
  Future<Map<String, dynamic>?> getPersonById(String personId) async {
    DocumentSnapshot doc = await persons.doc(personId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  // Update a person by ID
  Future<void> updatePerson(
    String personId,
    String personName,
    String personEmail,
    int personAge,
  ) {
    return persons.doc(personId).update({
      'personName': personName,
      'personEmail': personEmail,
      'personAge': personAge,
    });
  }

  // Delete a person by ID
  Future<void> deletePerson(String personId) {
    return persons.doc(personId).delete();
  }
}
