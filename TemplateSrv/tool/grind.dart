
import 'package:grinder/grinder.dart';
import 'package:embla_trestle/gateway.dart';

import '../bin/server.dart';
import 'migrations.dart';

main(args) => grind(args);

final gateway = new Gateway(driver);

String getPostgresUri() {
  final String username = config['username'];
  final String password = config['password'];
  final String database = config['database'];
  final String host = 'localhost';
  final int port = 5432;
  return'postgres://$username:$password@$host:$port/$database';
}

@DefaultTask()
migrate() async {
  await gateway.connect();
  await gateway.migrate(migrations);
  await gateway.disconnect();
}

@Task()
rollback() async {
  await gateway.connect();
  await gateway.rollback(migrations);
  await gateway.disconnect();
}
