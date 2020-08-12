bool isValidPhoneNumber(String phoneNo) {
  final RegExp _matcher = RegExp(r'(^(?:[+0]9)?[0-9]{10,15}$)');
  if (phoneNo == null || phoneNo.isEmpty || !_matcher.hasMatch(phoneNo)) {
    return false;
  } else {
    return true;
  }
}
