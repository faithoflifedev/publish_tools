import 'package:publish_tools/publish_tools.dart';

main(args) async {
  PublishTools.addAllTasks();

  grind(args);
}

// @DefaultTask('publish to github and pub.dev')
// @Depends('pt-commit', 'pt-publish')
// build() {
//   log('commit and publish completed');
// }

@DefaultTask('publish to github and pub.dev')
@Depends('pt-commit')
commit() {
  log('commit completed');
}
