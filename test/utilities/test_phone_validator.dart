import 'package:firebase_auth_manager/src/auth_utilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('When input equals null validator return false', () {
    bool _result = isValidPhoneNumber(null);
    expect(_result, equals(false));
  });

  test('When user enter an empty phone number validator return false', () {
    bool _result = isValidPhoneNumber('');
    expect(_result, equals(false));
  });

  test('When user enter phone number starting with + and shorter than max length validator return false', (){
    bool _result = isValidPhoneNumber('+9665490');
    expect(_result, equals(false));
  });

  test('When user enter valid phone number starting with + validator return true', (){
    bool _result = isValidPhoneNumber('+966549022834');
    expect(_result, equals(true));
  });

  test('When user enter valid phone number starting with 0 validator return true', (){
    bool _result = isValidPhoneNumber('0549022834');
    expect(_result, equals(true));
  });
}
