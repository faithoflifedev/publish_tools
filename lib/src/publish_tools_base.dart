import 'dart:convert' show json;
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:git/git.dart';
import 'package:github/github.dart';
import 'package:grinder/grinder.dart';
import 'package:publish_tools/publish_tools.dart';
import 'package:mustache_template/mustache.dart';
import 'package:path/path.dart' as p;
import 'package:publish_tools/src/service/repository_service.dart';
import 'package:universal_io/io.dart';

final projectDir = Directory.current;

/// [PublishTools] has primarily static methods since each method will typically operate individually from the others.
class PublishTools {
  /// The folder that will hold the homebrew tap
  static final buildFolder = '.pt-build';

  /// A parent object holding config info for the various operations of the library
  static final PublishToolsConfig ptConfig =
      PublishToolsConfig.init(projectDir);

  /// Used to check if the `version` of the library has changed since the last commit.
  static final isNewVersion = _git([
        'tag',
        '-l',
        'v${ptConfig.pubSpec.version}',
      ]).trim() !=
      'v${ptConfig.pubSpec.version}';

  static final inBranch = ['main', 'master'].contains(_git([
    'branch',
    '--show-current',
  ]).trim());

  static final hasUncommittedChanges =
      Process.runSync('git', ['status', '--porcelain'])
          .stdout
          .toString()
          .isNotEmpty;

  /// Check if the project .gitignore has an entry for the homebrew tap build folder
  static final bool hasIgnore = joinFile(
    projectDir,
    ['.gitignore'],
  ).readAsLinesSync().contains('$buildFolder/');

  /// Private helper method to start a process that runs the  `git` cli command.
  /// https://pub.dev/documentation/grinder/latest/grinder.tools/run.html
  static String _git(List<String>? args) => run(
        'git',
        arguments: args ?? [],
      );

  /// Enables all `Grinder` tasks available in the `publish_tools` package.
  static void addAllTasks() {
    /// Equivalent to `dart analyze .`
    addTask(GrinderTask(
      'pt-analyze',
      taskFunction: () => Analyzer.analyze('.', fatalWarnings: true),
      description: 'Perform static analysis.',
    ));

    /// Equivalent to `dart format .`
    addTask(GrinderTask(
      'pt-format',
      taskFunction: () => DartFmt.format('.'),
      description: 'Format code that might be auto-generated.',
    ));

    /// Equivalent to `dart doc`
    addTask(GrinderTask(
      'pt-doc',
      taskFunction: () => DartDoc.doc(),
      description: 'Generate the API documentation.',
    ));

    /// Equivalent to `dart test .`
    addTask(GrinderTask(
      'pt-test',
      taskFunction: () => TestRunner().test(),
      description: 'Perform tests.',
    ));

    /// Creates a file `meta.dart` in the folder specified by the config, this file contains a JSON representation of the pubspec.yaml file, giving access to that information to `cli` programs.
    addTask(GrinderTask(
      'pt-meta',
      taskFunction: _meta,
      description: 'Update the pubspec.json to display for the cli command.',
    ));

    /// Processes any `markdown` templates references in the config.  Usually the README.md and the CHANGELOG.md, the templates can use `mustache` syntax to access data from the [PublishToolsConfig] object.
    addTask(GrinderTask(
      'pt-markdown',
      taskFunction: _markdown,
      description: 'Update the markdown templates with pubspec info.',
    ));

    /// Commit the project to github
    addTask(GrinderTask(
      'pt-commit',
      depends: ['pt-doc', 'pt-analyze', 'pt-meta', 'pt-format', 'pt-markdown'],
      taskFunction: _commit,
      description: 'Commit, tag and push to github.',
    ));

    /// Create a `Release` for the current project in `GitHub`
    addTask(GrinderTask(
      'pt-release',
      taskFunction: _release,
      description: 'Update the markdown templates with pubspec info.',
    ));

    /// Create a homebrew tap for the command line executable for this project
    addTask(GrinderTask(
      'pt-homebrew',
      taskFunction: _homebrew,
      depends: ['pt-release'],
      description: 'Update the homebrew repository.',
    ));

    /// Remove build and homebrew repository folders created by this tool.
    addTask(GrinderTask(
      'pt-clean',
      taskFunction: _clean,
      description: 'Remove build folder and homebrew repository.',
    ));

    /// publish the library to pub.dev/packages
    addTask(GrinderTask(
      'pt-publish',
      taskFunction: _publish,
      description: 'Remove build folder and homebrew repository.',
    ));
  }

  /// publish the library to pub.dev/packages
  static void _publish() =>
      run('dart', arguments: ['pub', 'publish', '--force']);

  /// currently used to delete the `.pt-build` folder created by this package
  static Future<void> _clean() async {
    final String homebrewRepoName = 'homebrew-${ptConfig.github.repoName}';

    final github = GitHub(auth: findAuthenticationFromEnvironment());

    final repoService = RepositoryService(github);

    await repoService.update();

    final homebrewSlug =
        RepositorySlug(ptConfig.github.repoUser, homebrewRepoName);

    try {
      if (repoService.exists(homebrewRepoName)) {
        final success =
            await github.repositories.deleteRepository(homebrewSlug);

        if (!success) {
          GrinderException('Could not delete repository - $homebrewSlug');
        } else {
          log('Removed $homebrewSlug repository.');
        }
      } else {
        log('Repository $homebrewSlug could not be found.');
      }
    } catch (exception) {
      log('Problem identifying repository $homebrewSlug.');
    }

    try {
      final tapFolder = joinDir(projectDir, [
        buildFolder,
        homebrewRepoName,
      ]);

      Directory.current = tapFolder;

      hasGitInstalled();

      await runGit(['remote', 'rm', 'origin']);

      if (tapFolder.existsSync()) {
        tapFolder.deleteSync(recursive: true);

        log('"build" folder removed.');
      }
    } catch (exception) {
      log('Problem removing the build folder');
    } finally {
      Directory.current = projectDir;
    }
  }

  /// Create a homebrew tap for the command line executable for this project
  static Future<void> _homebrew() async {
    Repository? repository;

    final String homebrewRepoName = 'homebrew-${ptConfig.github.repoName}';

    final github = GitHub(auth: findAuthenticationFromEnvironment());

    final repoService = RepositoryService(github);

    await repoService.update();

    final homebrewSlug =
        RepositorySlug(ptConfig.github.repoUser, homebrewRepoName);

    final projectSlug =
        RepositorySlug(ptConfig.github.repoUser, ptConfig.github.repoName);

    // create the build folder for the homebrew tap
    final repoDir = joinDir(
      Directory.current,
      [
        buildFolder,
        homebrewRepoName,
      ],
    )..createSync(recursive: true);

    if (repoService.exists(homebrewSlug.name)) {
      repository = repoService.getRepo(homebrewSlug.name);
    }

    // add the folder to the .gitignore
    if (!hasIgnore) {
      joinFile(
        projectDir,
        ['.gitignore'],
      ).writeAsStringSync(
        '$buildFolder/',
        mode: FileMode.append,
      );
    }

    Directory.current = repoDir;

    if (repository == null) {
      log('Repository "${homebrewSlug.toString()}" not found.');

      // No repo, so create one.
      await github.repositories
          .createRepository(CreateRepository(homebrewRepoName));

      await repoService.update();

      repository = repoService.getRepo(homebrewSlug.name);

      if (repository == null) {
        throw GrinderException(
            'Problem creating the new repository - $homebrewRepoName.');
      }

      log('New repository clone url: ${repository.cloneUrl}');

      hasGitInstalled();

      await runGit(['init']);

      await runGit(['branch', '-M', 'main']);

      await runGit(['remote', 'add', 'origin', repository.cloneUrl]);
    } else if (joinDir(repoDir, ['.git']).existsSync()) {
      // Repo exists since we found the .git folder
      log('Updating ${repository.cloneUrl}');

      await runGit(['fetch']);

      await runGit(['checkout', 'main']);
    } else {
      // no .git folder so recreate it
      Directory.current = projectDir;

      delete(repoDir);

      await runGit(['clone', repository.cloneUrl, repoDir.path]);

      await runGit(['config', 'advice.detachedHead', 'false']);
    }

    try {
      final pubSpec = ptConfig.pubSpec;

      final release = await github.repositories.getLatestRelease(projectSlug);

      final digest = await _download(release.tarballUrl!);

      joinFile(
        repoDir,
        ['README.md'],
      ).writeAsStringSync('''# $homebrewRepoName
 A tap for the ${ptConfig.github.repoName} v${pubSpec.version?.canonicalizedVersion} Dart package''',
          mode: FileMode.write);

      final ruby = '''class ${ptConfig.homebrew.className} < Formula
  desc "${pubSpec.description}"
  homepage "${pubSpec.homepage}"
  url "${release.tarballUrl}"
  sha256 "$digest"
  license "MIT"
  
  depends_on "dart-lang/dart/dart" => :build
  
  def install
    system "dart", "pub", "get"
    system "dart", "compile", "exe", "${ptConfig.homebrew.binFolder}/${ptConfig.homebrew.binSrc}", "-o", "${ptConfig.homebrew.executableName}"
    bin.install "${ptConfig.homebrew.executableName}"
  end
  
  test do
    assert_match "obs_websocket v${pubSpec.version?.canonicalizedVersion}", shell_output("${ptConfig.homebrew.binFolder}/${ptConfig.homebrew.executableName} version")
  end
end''';

      joinFile(
        joinDir(repoDir, ['Formula'])..createSync(),
        ['${ptConfig.homebrew.executableName}.rb'],
      ).writeAsStringSync(ruby, mode: FileMode.write);

      // assumes repoDir as current directory
      await runGit(['add', '.']);

      await runGit(
          ['commit', '-m', 'v${pubSpec.version?.canonicalizedVersion}']);

      await runGit(['push', '-u', 'origin', 'main']);
    } catch (exception) {
      throw GrinderException('Problem updating ${homebrewSlug.toString()}');
    } finally {
      Directory.current = projectDir;
    }
  }

  /// Create a `Release` for the current project in `GitHub`
  static Future<void> _release() async {
    final pubSpec = ptConfig.pubSpec;

    final github = GitHub(auth: findAuthenticationFromEnvironment());

    final slug =
        RepositorySlug(ptConfig.github.repoUser, ptConfig.github.repoName);

    try {
      final release = await github.repositories.getReleaseByTagName(
          slug, 'v${pubSpec.version?.canonicalizedVersion}');

      await github.repositories.deleteRelease(slug, release);

      log('Deleting existing release.');
    } catch (exception) {
      log('Existing release not found.');
    }

    final createRelease =
        CreateRelease('v${pubSpec.version?.canonicalizedVersion}');

    await github.repositories.createRelease(slug, createRelease);

    log('Release v${pubSpec.version?.canonicalizedVersion} created.');
  }

  static Future<void> _commit() async {
    if (!hasUncommittedChanges) {
      log('No changes to commit.');

      return;
    }

    final pubSpec = ptConfig.pubSpec;

    hasGitInstalled();

    await runGit(['add', '.']);

    await runGit(['commit', '-m', ptConfig.commit]);

    if (!inBranch) {
      await runGit(['pull', 'origin', 'main']);

      await runGit(['pull', '--tags']);

      if (isNewVersion) {
        await runGit(['tag', 'v${pubSpec.version}']);

        await runGit(['push', '--tags']);
      }
    }

    await runGit(['push']);
  }

  /// Processes any `markdown` templates references in the config.  Usually the README.md and the CHANGELOG.md, the templates can use `mustache` syntax to access data from the [PublishToolsConfig] object.
  static void _markdown() {
    final templates = ptConfig.templates;

    for (var template in templates) {
      final mustacheTpl = joinFile(Directory.current, ['tool', template.name]);

      final outputFile = File(template.name);

      final markdownTemplate =
          Template(mustacheTpl.readAsStringSync(), name: template.name)
              .renderString({
        'pubspec': ptConfig.pubSpec.toJson(),
        'github': ptConfig.github.toJson(),
        'homebrew': ptConfig.homebrew,
        'meta_path': ptConfig.optionalMetaFilePath,
        'templates': ptConfig.templates,
        'commit': ptConfig.commit,
        'changes': ptConfig.optionalChangeList,
        'o-': '{{',
        '-o': '}}',
      });

      switch (template.type) {
        case 'prepend':
          final currentContent =
              outputFile.existsSync() ? outputFile.readAsStringSync() : '';

          outputFile.writeAsStringSync(markdownTemplate, mode: FileMode.write);

          outputFile.writeAsStringSync(
              currentContent.replaceFirst(RegExp(r'# Changelog\n'), ''),
              mode: FileMode.append);

          break;

        case 'overwrite':
          outputFile.deleteSync();

          outputFile.writeAsStringSync(markdownTemplate);

          break;

        default: //append
          outputFile.writeAsString(markdownTemplate, mode: FileMode.append);
      }
    }
  }

  static void _meta() async {
    final rawJson = json.encode(ptConfig.pubSpec.toJson());

    File(ptConfig.metaFilePath)
      ..create(recursive: true)
      ..writeAsStringSync('''/// app metadata
library meta;
// DO NOT EDIT THIS FILE
// THIS FILE IS AUTOMATICALLY OVER WRITTEN BY PublishTools
import 'dart:convert' show json;

final pubSpec = json.decode('$rawJson');
''');
  }

  static Future<Digest> _download(String url) async {
    final request = await HttpClient().getUrl(Uri.parse(url));

    final response = await request.close();

    return await sha256.bind(response.asBroadcastStream()).first;
  }

  static void hasGitInstalled() {
    if (run('which', arguments: ['git']).split(p.separator).last.trim() !=
        'git') {
      throw GrinderException('The git cli executable could not be located.');
    }
  }
}
