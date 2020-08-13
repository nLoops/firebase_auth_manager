bool isValidPhoneNumber(String phoneNo) {
  final RegExp _matcher = RegExp(r'(^\+[1-9]\d{1,14}$)');
  if (phoneNo == null || phoneNo.isEmpty || !_matcher.hasMatch(phoneNo)) {
    return false;
  } else {
    return true;
  }
}
