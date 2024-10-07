import 'package:pubspec_parse/pubspec_parse.dart';

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

extension Json on Pubspec {
  Map<String, dynamic> toJson() => {
        'description': description,
        'homepage': homepage,
        'documentation': documentation,
        'repository': repository,
        'issueTracker': issueTracker,
        // 'authors': authors,
        // 'dependencies': dependencies,
        // 'dev_dependencies': devDependencies,
        'name': name,
        'publish_to': publishTo,
        'version': version.toString(),
      };
}
