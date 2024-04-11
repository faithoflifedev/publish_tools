import 'dart:convert';

import 'package:publish_tools/publish_tools.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

part 'homebrew_config.g.dart';

@JsonSerializable()
class HomebrewConfig {
  @JsonKey(name: 'class_name')
  final String? optionalClassName;
  String? optionalDescription;
  @JsonKey(name: 'home_page')
  String? optionalHomePage;
  @JsonKey(name: 'bin_src_file')
  final String? optionalBinSrc;
  @JsonKey(name: 'executable_name')
  final String? optionalExecutableName;

  HomebrewConfig({
    this.optionalClassName,
    this.optionalDescription,
    this.optionalHomePage,
    this.optionalBinSrc,
    this.optionalExecutableName,
  });

  String get className {
    if (optionalClassName != null) {
      return optionalClassName!;
    }

    return ReCase(basename(binSrc).replaceFirst('.dart', '')).pascalCase;
  }

  String? get description => optionalDescription;

  String? get homePage => optionalHomePage;

  String get binSrc {
    if (optionalBinSrc != null) {
      return optionalBinSrc!;
    }

    final fileSet =
        FileSet.fromDir(joinDir(projectDir, [binFolder]), pattern: '*.dart');

    if (fileSet.files.length != 1) {
      throw Exception('Could not determine executable file name.');
    }

    return basename(fileSet.files.first.path);
  }

  String get executableName {
    if (optionalExecutableName != null) {
      return optionalExecutableName!;
    }

    return binSrc.replaceAll('.dart', '');
  }

  String get binFolder => 'bin';

  factory HomebrewConfig.fromYamlMap(YamlMap config) => HomebrewConfig(
        optionalClassName: config['optionalClassName'],
        optionalDescription: config['optionalDescription'],
        optionalHomePage: config['optionalHomePage'],
        optionalBinSrc: config['optionalBinSrc'],
        optionalExecutableName: config['optionalExecutableName'],
      );

  factory HomebrewConfig.fromJson(Map<String, dynamic> json) =>
      _$HomebrewConfigFromJson(json);

  Map<String, dynamic> toJson() => _$HomebrewConfigToJson(this)
    ..removeWhere((key, value) => value == null)
    ..putIfAbsent('className', () => className)
    ..putIfAbsent('description', () => description)
    ..putIfAbsent('homePage', () => homePage)
    ..putIfAbsent('binSrc', () => binSrc)
    ..putIfAbsent('executableName', () => executableName);

  @override
  String toString() => json.encode(toJson());
}
