import 'package:publish_tools/publish_tools.dart';

// this code is normally placed in the [project]/tool folder
main(args) async {
  PublishTools.addAllTasks();

  grind(args);
}

@DefaultTask('task to run if none specified on the command line')
@Depends('pt-commit', 'pt-publish', 'pt-homebrew')
done() {
  log('commit of main project completed');
  log('publish to pub.dev/packages complete.');
  log('commit of brew tap complete');
}
