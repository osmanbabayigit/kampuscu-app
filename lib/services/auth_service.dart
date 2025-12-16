import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore eklendi
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore nesnesi

  Stream<AppUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  AppUser? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? 'no-email',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  // KULLANICI PROFİLİNİ GÜNCELLEME/OLUŞTURMA
  Future<void> updateUserData(String uid, String name, String email) async {
    return await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'displayName': name,
      'email': email,
      'photoUrl': '', // Başlangıçta boş
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // KAYIT OLMA
  Future<AppUser?> registerWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Firebase Auth profilini güncelle
      await result.user?.updateDisplayName(name);

      // Firestore'a kullanıcı verisini kaydet
      await updateUserData(result.user!.uid, name, email);

      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}