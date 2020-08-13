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

  test('When user enter number starting with 0 return false', (){
    bool _result = isValidPhoneNumber('0549022834');
    expect(_result, equals(false));
  });
  
  test('When user enter number without country code according to E.164', (){
    bool _result = isValidPhoneNumber('00966549022834');
    expect(_result, equals(false));
  });

  test('When user enter valid number with country code according to E.164', (){
    bool _result = isValidPhoneNumber('+966549022834');
    expect(_result, equals(true));
  });
}
