import 'package:github/github.dart';

class RepositoryService {
  final GitHub github;

  final Map<String, Repository> _repoMap = {};

  Iterable<String> get repoList => _repoMap.keys;

  RepositoryService(this.github) {
    update();
  }

  Future<void> update() async {
    final repositoryStream = github.repositories.listRepositories();

    await repositoryStream
        .forEach((repository) => _repoMap[repository.name] = repository);
  }

  bool exists(String repoName) => repoList.contains(repoName);

  Repository? getRepo(String repoName) => _repoMap[repoName];
}
