import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements FirebaseUser {
  @override
  String get displayName => 'Ahmed ibrahim';
}

class MockAuthCredential extends Mock implements AuthCredential {}

class MockAuthResult extends Mock implements AuthResult {
  @override
  FirebaseUser get user => MockFirebaseUser();
}
