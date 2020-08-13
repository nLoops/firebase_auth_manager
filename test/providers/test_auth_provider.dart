import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_manager/src/auth_constants.dart';
import 'package:firebase_auth_manager/src/data/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

void main() {
  final FirebaseAuth auth = MockFirebaseAuth();
  final AuthProvider provider = AuthProvider(firebaseAuth: auth);

  group('Check user auth state', () {
    test('When there\'s no logged in user auth return false', () async {
      when(auth.currentUser()).thenReturn(null);

      bool result = await provider.isUserSigned();

      expect(result, equals(false));
    });

    test('When there\'s logged in user auth return true', () async {
      when(auth.currentUser())
          .thenAnswer((_) => Future.value(MockFirebaseUser()));

      bool result = await provider.isUserSigned();

      expect(result, equals(true));
    });
  });

  group('Get current authed user', () {
    test('When no logged in user auth return null', () async {
      when(auth.currentUser()).thenAnswer((_) => null);
      FirebaseUser user = await provider.getCurrentUser();

      expect(user, equals(null));
    });

    test('When there\'s logged in user auth return firebase user with info',
        () async {
      when(auth.currentUser())
          .thenAnswer((_) => Future.value(MockFirebaseUser()));
      FirebaseUser user = await provider.getCurrentUser();

      expect(user.displayName, equals('Ahmed ibrahim'));
    });
  });

  group('Auth with credential', () {
    final AuthCredential authCredential = MockAuthCredential();
    test('When auth result has no user return false', () async {
      when(auth.signInWithCredential(authCredential))
          .thenAnswer((_) => Future.value(null));

      var result = await provider.authWithCredential(authCredential);

      expect(result, equals(false));
    });

    test(
        'When auth with credential throw an error return false and print error message',
        () async {
      when(auth.signInWithCredential(authCredential)).thenThrow(Exception());

      var result = await provider.authWithCredential(authCredential);

      expect(result, equals(false));
    });

    test('When auth with credential success then return true', () async {
      when(auth.signInWithCredential(authCredential))
          .thenAnswer((_) => Future.value(MockAuthResult()));

      var result = await provider.authWithCredential(authCredential);

      expect(result, equals(true));
    });
  });
}
