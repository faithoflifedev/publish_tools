# publish_tools

[![pub package](https://img.shields.io/pub/v/publish_tools.svg)](https://pub.dartlang.org/packages/publish_tools)

This package provides a set of [Grinder](https://pub.dev/packages/grinder) tasks that make it easy to release a Dart and Flutter packages.

[![Build Status](https://github.com/faithoflifedev/publish_tools/workflows/Dart/badge.svg)](https://github.com/faithoflifedev/publish_tools/actions) [![github last commit](https://shields.io/github/last-commit/faithoflifedev/publish_tools)](https://shields.io/github/last-commit/faithoflifedev/publish_tools) [![github build](https://shields.io/github/workflow/status/faithoflifedev/publish_tools/Dart)](https://shields.io/github/workflow/status/faithoflifedev/publish_tools/Dart) [![github issues](https://shields.io/github/issues/faithoflifedev/publish_tools)](https://shields.io/github/issues/faithoflifedev/publish_tools)

## Getting started

### Requirements

In able to use the `GitHub` publishing features of this package your development setup must meet the following requirements:

* `git` must be available in your command path (most people reading this will have this requirement met, if not see - [Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
* you have a `GitHub` account and have setup a personal access token (see the documentation - [Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token))
* The access token should have `delete_repo`, `public_rep` permissions

__Make sure that you `.gitignore` your `publish_tools.yaml` file to prevent publishing your token to GitHub__

### pubspec.yaml setup

In your `pubspec.yaml` the following to the `dev_dependencies` section:

```yml
dev_dependencies:
  ...
  grinder: ^0.9.2
  publish_tools: ^{{ pubspec.version }}
```

Optionally, provide a non-default path for your configuration .yaml file: (remember to `.gitignore` it)

```yml
publish_tools: tool/config.yaml
``` 

### publish_tools.yaml setup

Create a folder named `tool` (which will already exist if you use the `grinder` package).  In this folder create you `publish_tools` configuration file.

```yml
# this is a minimal config, several fields will be assigned default values

github:
  repoUser: [your github user]
  bearerToken: [bearer token created in GitHub]

# templates:
#   - name: README.md
#     type: overwrite
#   - name: CHANGELOG.md
#     type: prepend

commit: 'sample commit message'
```

Create 

```dart
import 'package:grinder/grinder.dart';
import 'package:publish_tools/publish_tools.dart';

main(args) async {
  PublishTools.addAllTasks();

  grind(args);
}

@DefaultTask('Just keeping it real')
@Depends('pt-commit')
build() {
  log('building...');
}
```

other packages:

[cli_pkg](https://pub.dev/packages/cli_pkg)