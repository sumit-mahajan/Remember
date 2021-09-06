import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:remember/models/birthday_model.dart';

class FirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore store;

  FirebaseService({required this.auth, required this.store});

  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future<void> login() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await auth.signInWithCredential(credential);
    } catch (err) {
      print('Error at FirebaseService->login(): ' + err.toString());
      throw err.toString();
    }
  }

  Future<void> logout() async {
    try {
      await googleSignIn.disconnect();
      auth.signOut();
    } catch (err) {
      print('Error at FirebaseService->logout(): ' + err.toString());
      throw err.toString();
    }
  }

  Future<List<BirthdayModel>> getBirthList() async {
    try {
      final QuerySnapshot data = await store.collection('users/${auth.currentUser!.uid}/birthdays').get();
      if (data.docs.isEmpty) {
        return [];
      }
      return data.docs.map((doc) => BirthdayModel.fromMap(doc.data() as Map)).toList();
    } catch (err) {
      print('Error at FirebaseDbService->getBirthList(): ' + err.toString());
      throw err.toString();
    }
  }

  Future<void> addBirthday(BirthdayModel birthday) async {
    try {
      await store.doc('users/${auth.currentUser!.uid}/birthdays/${birthday.id}').set(birthday.toMap());
    } catch (err) {
      print('Error at FirebaseDbService->addBirthday(): ' + err.toString());
      throw err.toString();
    }
  }

  Future<void> deleteBirthday(BirthdayModel birthday) async {
    try {
      await store.doc('users/${auth.currentUser!.uid}/birthdays/${birthday.id}').delete();
    } catch (err) {
      print('Error at FirebaseDbService->deleteBirthday(): ' + err.toString());
      throw err.toString();
    }
  }

  Future<void> deleteAllBirthdays() async {
    try {
      final QuerySnapshot allBirthdays = await store.collection('users/${auth.currentUser!.uid}/birthdays/').get();

      for (final DocumentSnapshot birthday in allBirthdays.docs) {
        birthday.reference.delete();
      }
    } catch (err) {
      print('Error at FirebaseDbService->deleteAllBirthdays(): ' + err.toString());
      throw err.toString();
    }
  }
}
