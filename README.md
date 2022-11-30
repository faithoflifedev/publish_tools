# publish_tools

[![pub package](https://img.shields.io/pub/v/publish_tools.svg)](https://pub.dartlang.org/packages/publish_tools)

This package provides a set of [Grinder](https://pub.dev/packages/grinder) tasks that make it easy to release a Dart and Flutter packages.

[![Build Status](https://github.com/faithoflifedev/publish_tools/workflows/Dart/badge.svg)](https://github.com/faithoflifedev/publish_tools/actions) [![github last commit](https://shields.io/github/last-commit/faithoflifedev/publish_tools)](https://shields.io/github/last-commit/faithoflifedev/publish_tools) [![github build](https://shields.io/github/workflow/status/faithoflifedev/publish_tools/Dart)](https://shields.io/github/workflow/status/faithoflifedev/publish_tools/Dart) [![github issues](https://shields.io/github/issues/faithoflifedev/publish_tools)](https://shields.io/github/issues/faithoflifedev/publish_tools)

- [Getting started](#getting-started)
  - [Requirements](#requirements)
  - [pubspec.yaml setup](#pubspecyaml-setup)
  - [publish\_tools.yaml setup](#publish_toolsyaml-setup)
  - [README.md/CHANGELOG.md templates](#readmemdchangelogmd-templates)

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
  grinder: ^0.9.2
  publish_tools: ^0.1.0+7
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

### README.md/CHANGELOG.md templates

`publish_tools` can make it easier for you to keep your README.md and CHANGELOG.md file up to date.  To do this it uses [`mustache` templates](https://mustache.github.io/) to dynamically re-create your README and CHANGELOG when you run the appropriate `grinder` task.  To configure your project to make use of this functionality, you need to have a `README.md` and `CHANGELOG.md` mustache template available to the build tool.

The quickest and simplest way to get your templates in place is to copy your existing `README.md` and `CHANGELOG.md` into the tool folder.  Now you can update these files with dynamic fields that will be replaced when the `pt-markdown` grinder task is run.

For instance, in this README file in the `pubspec.yaml setup` section above, there are instructions and an example of how to update your pubspec.yaml to use this tool.  The `publish_tools` version in the README is set dynamically with a variable.  Here is the section of markup for the same section in the `tool/README.md` mustache template:

````text
```yml
dev_dependencies:
  ...
  grinder: ^0.9.2
  publish_tools: ^0.1.0+7
```
````

The value for `0.1.0+7` is filled in automatically by the `pt-markdown` grinder task.

Or for the `CHANGELOG.md` the following template might be used:

```text
# Changelog

## 0.1.0+7

* readme improvement

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


other packages:

[cli_pkg](https://pub.dev/packages/cli_pkg)