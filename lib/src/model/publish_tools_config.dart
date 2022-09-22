import 'dart:convert';

import 'package:grinder/grinder.dart';
import 'package:publish_tools/src/util/ext.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec/pubspec.dart';
import 'package:universal_io/io.dart';
import 'package:yaml/yaml.dart';

import 'github_config.dart';
import 'homebrew_config.dart';
import 'markdown_template.dart';

class PublishToolsConfig {
  final PubSpec pubSpec;
  final GithubConfig github;
  final HomebrewConfig homebrew;
  final String? optionalMetaFilePath;
  final List<MarkdownTemplate> templates;
  final String commit;
  final String? optionalChangeList;

  PublishToolsConfig({
    required this.pubSpec,
    required this.github,
    required this.homebrew,
    this.optionalMetaFilePath,
    required this.templates,
    required this.commit,
    this.optionalChangeList,
  });

  String get metaFilePath =>
      optionalMetaFilePath ?? ['lib', 'meta.dart'].join(p.separator);

  String get changeList => optionalChangeList ?? commit;

  factory PublishToolsConfig.init(Directory projectDir) {
    final pubSpec = PubSpec.fromYamlString(
      joinFile(
        projectDir,
        ['pubspec.yaml'],
      ).readAsStringSync(),
    );

    final pubSpecOtherYaml = pubSpec.unParsedYaml ?? {};

    final grinderConfigFile = pubSpecOtherYaml.containsKey('publish_tools')
        ? pubSpecOtherYaml['publish_tools']
        : joinFile(
            projectDir,
            ['tool', 'publish_tools.yaml'],
          ).path;

    return PublishToolsConfig.fromYamlFile(grinderConfigFile);
  }

  factory PublishToolsConfig.fromYamlFile(String filePath) {
    final pubSpec = PubSpec.fromYamlString(joinFile(
      Directory.current,
      ['pubspec.yaml'],
    ).readAsStringSync());

    final YamlMap config = loadYaml(File(filePath).readAsStringSync());

    final checkKeys = <String>[
      'github',
      'templates',
      'commit',
    ];

    if (!config.mapContainsKeys(checkKeys)) {
      throw Exception('The config file is missing a top level key.');
    }

    return PublishToolsConfig(
      pubSpec: pubSpec,
      github: GithubConfig.fromYamlMap(config['github'], pubSpec),
      homebrew: HomebrewConfig.fromYamlMap(config['homebrew'] ?? YamlMap()),
      optionalMetaFilePath: config['meta_path'],
      templates: config.containsKey('templates')
          ? (config['templates'] as List)
              .map((template) => MarkdownTemplate.fromYamlMap(template))
              .toList()
          : [
              YamlMap.wrap({'name': 'README.md', 'type': 'overwrite'}),
              YamlMap.wrap({'name': 'CHANGELOG.md', 'type': 'prepend'}),
            ]
              .map((template) => MarkdownTemplate.fromYamlMap(template))
              .toList(),
      commit: config['commit'],
      optionalChangeList: config['changes'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'pubspec': pubSpec.toJson(),
        'github': github.toJson(),
        'homebrew': homebrew,
        'meta_path': optionalMetaFilePath,
        'templates': templates,
        'commit': commit,
        'change_list': optionalChangeList,
      }
        ..removeWhere((key, value) => value == null)
        ..putIfAbsent('metaFilePath', () => metaFilePath)
        ..putIfAbsent('changeList', () => changeList);

  @override
  String toString() => json.encode(toJson());
}
