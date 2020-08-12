import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_manager/src/auth_constants.dart';
import 'package:firebase_auth_manager/src/auth_utilities.dart';
import 'package:firebase_auth_manager/src/data/providers/base_provider.dart';

class AuthProvider extends BaseProvider {
  AuthProvider({FirebaseAuth firebaseAuth})
      : auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth auth;
  String verID = "";

  Future<bool> isUserSigned() async {
    return await auth.currentUser() != null;
  }

  Future<FirebaseUser> getCurrentUser() => auth.currentUser();

  Future<void> signOut() => auth.signOut();

  Stream<int> verifyPhoneNumber(String phoneNo) async* {
    StreamController<int> verifyStream = StreamController();
    // first check if the user entered a valid phone number
    bool isValidPhone = isValidPhoneNumber(phoneNo);

    // if not method yield a not valid phone.
    if (!isValidPhone) {
      verifyStream.add(kNotValidPhoneNo);
      verifyStream.close();
    }

    // In case phone verification completed required
    final phoneVerificationCompleted = (AuthCredential authCredential) async {
      bool authResult = await authWithCredential(authCredential);

      if (authResult) {
        verifyStream.add(kVComplete);
      } else {
        verifyStream.add(kVFailed);
      }
      verifyStream.close();
    };

    // In case phone verification failed
    final phoneVerificationFailed = (AuthException exception) {
      print('== Auth failed with exception \n ${exception.message}');
      verifyStream.add(kVFailed);
      verifyStream.close();
    };

    // When OTP sent to the user device
    final otpSent = (String verId, [int forceResent]) {
      this.verID = verId;
      verifyStream.add(kVCodeSent);
    };

    // When the timeout reached without receiving OTP
    final phoneCodeAutoRetrievalTimeout = (String verId) {
      this.verID = verId;
      verifyStream.close();
    };

    // Calling verifyPhoneNumber
    await auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 1),
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: otpSent,
        codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout);

    yield* verifyStream.stream;
  }

  Future<bool> authByPhoneNumber(String otp) async {
    // Create auth credential
    AuthCredential authCredential =
        PhoneAuthProvider.getCredential(verificationId: verID, smsCode: otp);

    return authWithCredential(authCredential);
  }

  Future<bool> authWithCredential(AuthCredential credential) async {
    try {
      AuthResult result = await auth.signInWithCredential(credential);
      if (result.user != null) {
        return true;
      } else {
        print('Auth with credential failed.');
        return false;
      }
    } catch (e) {
      print('== Auth with credential failed with error\n$e');
      return false;
    }
  }

  @override
  void dispose() {
    // dispose
  }
}
