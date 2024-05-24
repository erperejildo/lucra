import 'package:flutter_translate/flutter_translate.dart';

class Validators {
  static final RegExp regExpDouble = RegExp(r'^\d*([.,]\d*)?$');
  static final RegExp regExpEmail =
      RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');

  static checkDouble(String value) {
    final String replacedValue = value.replaceAll(',', '.');

    if (value.isEmpty || value == ' ' || value == '') {
      return translate('fill_field');
    }

    final doublePrice = double.tryParse(replacedValue);
    if (doublePrice == null) {
      return translate('invalid_number');
    }
    return null;
  }

  static checkInput(String value) {
    value = value.replaceAll(RegExp(' +'), ' ');
    if (value.isEmpty || value == ' ' || value == '') {
      return translate('fill_field');
    }
    return null;
  }

  static checkPassword(String value, [int minLength = 6]) {
    if (value == "" || value.isEmpty) {
      return translate('fill_field');
    }
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    if (!hasLowercase) {
      return translate('sign.need_lowercase');
    }
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    if (!hasUppercase) {
      return translate('sign.need_uppercase');
    }
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    if (!hasDigits) {
      return translate('sign.need_digit');
    }
    bool hasMinLength = value.length > minLength;
    if (!hasMinLength) {
      return translate('sign.need_chars');
    }
  }

  static checkUrl(String value) {
    value = value.replaceAll(RegExp(' +'), ' ');
    if (value.isEmpty || value == ' ' || value == '') {
      return null;
    }
    bool validURL = Uri.parse(value).isAbsolute;
    if (validURL != true) {
      return translate('valid_url');
    }
    return null;
  }
}
