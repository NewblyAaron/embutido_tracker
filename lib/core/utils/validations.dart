class Validations {
  static String? hasInput(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? "Enter a value";
    }

    return null;
  }
}
