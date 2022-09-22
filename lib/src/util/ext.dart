extension KeyCheck on Map {
  bool mapHasAllKeys(List<String> checkKeys) {
    var checkSize = checkKeys.toSet().difference(keys.toSet()).isEmpty;

    var checkLength = checkKeys.length == keys.length;

    return checkSize && checkLength;
  }

  bool mapContainsKeys(List<String> checkKeys) {
    final keySet = keys.toSet();

    keySet.removeAll(checkKeys);

    return keySet.length == (keys.length - checkKeys.length);
  }
}
