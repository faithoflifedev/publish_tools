import 'package:publish_tools/publish_tools.dart';

Future<void> main(List<String> args) async {
  PublishTools.addAllTasks();

  grind(args);
}

@DefaultTask('publish to github and pub.dev')
@Depends('pt-commit', 'pt-publish')
void build() {
  log('commit and publish completed');
}
