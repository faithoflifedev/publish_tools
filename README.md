# Simple Publish Tools

![SDK version](https://flat.badgen.net/pub/sdk-version/publish_tools?style=for-the-badge)
![Supported platforms](https://flat.badgen.net/pub/flutter-platform/publish_tools?style=for-the-badge)
![Supported SDKs](https://flat.badgen.net/pub/dart-platform/publish_tools?style=for-the-badge)

This package provides a set of [Grinder](https://pub.dev/packages/grinder) tasks that make it easy to release a Dart and Flutter packages.

[![Build Status](https://img.shields.io/github/actions/workflow/status/faithoflifedev/publish_tools/dart.yml?branch=main&logo=github-actions&logoColor=white&style=for-the-badge)](https://github.com/faithoflifedev/publish_tools/actions)
[![Pull Requests](https://img.shields.io/github/issues-pr/faithoflifedev/publish_tools?logo=github&logoColor=white&style=for-the-badge)](https://github.com/faithoflifedev/publish_tools/pulls)
[![Issues](https://img.shields.io/github/issues/faithoflifedev/publish_tools?logo=github&logoColor=white&style=for-the-badge)](https://github.com/faithoflifedev/publish_tools/issues)
[![github last commit](https://shields.io/github/last-commit/faithoflifedev/google_vision?logo=github&logoColor=white&style=for-the-badge)](https://shields.io/github/last-commit/faithoflifedev/publish_tools)
[![Pub Score](https://img.shields.io/pub/points/google_vision_flutter?logo=dart&logoColor=00b9fc&style=for-the-badge)](https://pub.dev/packages/publish_tools/score)

## Table of contents
- [Getting started](#getting-started)
  - [Requirements](#requirements)
  - [pubspec.yaml setup](#pubspecyaml-setup)
  - [publish\_tools.yaml setup](#publish_toolsyaml-setup)
  - [README.md/CHANGELOG.md templates](#readmemdchangelogmd-templates)
- [Grinder Tasks](#grinder-tasks)
- [In the next major release](#in-the-next-major-release)

[![Buy me a coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-1.svg)](https://www.buymeacoffee.com/faithoflif2)

[![Pub Package](https://img.shields.io/pub/v/publish_tools.svg?logo=dart&logoColor=00b9fc&color=blue&style=for-the-badge)](https://pub.dartlang.org/packages/publish_tools)
[![Code Size](https://img.shields.io/github/languages/code-size/faithoflifedev/publish_tools?logo=github&logoColor=white&style=for-the-badge)](https://github.com/faithoflifedev/publish_tools)
[![Publisher](https://img.shields.io/pub/publisher/publish_tools?style=for-the-badge)](https://pub.dev/publishers/muayid.com)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

## Getting started

### Requirements

In able to use the `GitHub` publishing features of this package your development setup must meet the following requirements:

* `git` must be available in your command path (most people reading this will have this requirement met, if not see - [Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
* you have a `GitHub` account and have setup a personal access token (see the documentation - [Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token))
* A fine grain token requires the following permissions:
  *  `Read and write` - Administration - for the Homebrew `tap` repository creation
  *  `Read and write` - Contents - to update repository content and crete the `release` for the `tap`
  *  `Read-only` - Metadata - mandatory for all fine-grained personal access tokens

__Make sure that you `.gitignore` your `publish_tools.yaml` file to prevent publishing your token to GitHub__

### pubspec.yaml setup

In your `pubspec.yaml` the following to the `dev_dependencies` section:

```yml
dev_dependencies:
  ...
  grinder: ^0.9.5
  publish_tools: ^1.0.0+11
```

Optionally, provide a non-default path for your configuration .yaml file: (remember to `.gitignore` it)

```yml
publish_tools: tool/config.yaml
``` 

### publish_tools.yaml setup

Create a folder named `tool` (which will already exist if you use the `grinder` package).  In this folder create you `publish_tools` configuration file.

```yml
## this is a minimal config, several fields will be assigned default values

## If the github key is present, it will override the default (grab values from .git folder)
# github:
#   repoUser: [your github user]
#   repoName: [defaults to 'name' from pubspec.yaml]

## If the templates key is present, defaults are overridden.  Below matches the default config.
# templates:
#   - name: README.md
#     type: overwrite
#   - name: CHANGELOG.md
#     type: prepend

commit: 'sample commit message'
```

Create 

```dart
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

### README.md/CHANGELOG.md templates

`publish_tools` can make it easier for you to keep your README.md and CHANGELOG.md file up to date.  To do this it uses [`mustache` templates](https://mustache.github.io/) to dynamically re-create your README and CHANGELOG when you run the appropriate `grinder` task.  To configure your project to make use of this functionality, you need to have a `README.md` and `CHANGELOG.md` mustache template available to the build tool.

The quickest and simplest way to get your templates in place is to copy your existing `README.md` and `CHANGELOG.md` into the tool folder.  Now you can update these files with dynamic fields that will be replaced when the `pt-markdown` grinder task is run.

For instance, in this README file in the `pubspec.yaml setup` section above, there are instructions and an example of how to update your pubspec.yaml to use this tool.  The `publish_tools` version in the README is set dynamically with a variable.  Here is the section of markup for the same section in the `tool/README.md` mustache template:


````text
```yml
dev_dependencies:
  ...
  grinder: ^0.9.2
  publish_tools: ^{{ pubspec.version }}
```
````


The value for `{{ pubspec.version }}` is filled in automatically by the `pt-markdown` grinder task.

Or for the `CHANGELOG.md` the following template might be used:

```text
# Changelog

## {{ pubspec.version }}

{{ changes }}
```

By default the `README.md` file is overwritten each time the `pt-markdown` task runs.  However thee `CHANGELOG.md` file is **prepended** by default.  This means that the supplied template will be added to the start of the existing CHANGELOG.md file.

Other available values that can be used dynamically are:

| object    | attribute     | description |
| --------- | --------------- | ----------- |
| pubspec   |                 | Information contained within the project `pubspec.yaml` file. |
|           | name            | Project name. |
|           | version         | Project version. |
|           | homepage        | URL pointing to the package’s homepage (or source code repository). |
|           | documentation   | URL pointing to documentation for the package.
|           | description     | Project short description. |
|           | publishTo       | Specifies where to publish a package. |
| github    |                 | Values from the `publish_tools` config file related to GitHub. |
|           | repoUser        | The GitHub username associated with this project. |
|           | repoName        | The GitHub repository name for this project. |
| homebrew  |                 | Values from the `publish_tools` config file related to HomeBrew.
|           | className       | The name of the class created for the HomeBrew `ruby` file for the `tap` repository that will be created and published to GutHub |
|           | description     | The description given in the `ruby` tap repository |
|           | homePage        | The description given in the `ruby` tap repository.  By default this is the same as **pubspec.homepage**. |
|           | binSrc          | The file name of the source code for the command line binary of the project.  The file is expected to be found in the **homebrew.binFolder** and by default the expected file name is **\[pubspec.name].dart**. |
|           | executableName  | The name of the compiled executable for the command line binary to be used by end-users, defaults to **pubspec.name**. |
|           | binFolder       | The folder that contains the binary source for the command line executeable, defaults to **bin** |
| meta_path |                 | The location to write the `meta.dart` file that is used to supply `pubspec` info to the cli binary executable, defaults to **lib/meta.dart**. |
| commit    |                 | The `commit` message supplied in the `publish_tools` config file. |
| changes   |                 | The `changes` (for the CHANGELOG.md) supplied in the `publish_tools` config file. |

## Grinder Tasks

Here is the list of [grinder](https://pub.dev/packages/grinder) tasks available in this package:

| Task name   | Description |
| ----------- | ----------- |
| pt-analyze  | Analyze Dart code in a directory - `dart analyze .` |
| pt-format   | Idiomatically format Dart source code - `dart format .` |
| pt-doc      | Generate API documentation for Dart projects - `dart doc .` |
| pt-test     | Generate API documentation for Dart projects - `dart test .` |
| pt-meta     | Creates a file `meta.dart` in the folder specified by the config (defaults to src/util/), this file contains a JSON representation of the pubspec.yaml file, giving access to that information to `cli` programs. |
| pt-markdown | Processes any `markdown` templates references in the config.  Usually the README.md and the CHANGELOG.md, the templates can use `mustache` syntax to access data from the `ptConfig` object. |
| pt-pana     | [pana](https://pub.dev/packages/pana) will perform a local package analysis that matches that performed by the pub.dev server when you run `dart pub publish`.  It's useful for finding any deficiencies in your package before it's published. |
| pt-commit   | Commit the project to github [`git add .`, `git commit {{ ptConfig.commit }}`, `git pull --tags`, `git tag v${pubSpec.version}`, `git push --tags`, `git push`].  Only if {{ pubSpec.version }} has changed, will a new tag be created. |
| pt-release  | Create a `Release` for the current project in `GitHub` |
| pt-homebrew | Create a HomeBrew `tap` for the command line executable for this project |
| pt-clean    | Remove build and homebrew repository folders created by this tool. |
| pt-publish  | Publish the current package to pub.dev. |

## In the next major release

* Chocolatey support
* NPM support