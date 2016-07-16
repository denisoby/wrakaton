import 'dart:async';
import 'package:embla_trestle/gateway.dart';
import 'package:srv_base/Tools/migrations.dart';

final migrations = [
  CreateUsersTableMigration,
  CreateTemplatesTableMigration
].toSet();

class CreateTemplatesTableMigration extends Migration {

  String table_name = 'templates';

  @override
  Future run(Gateway gateway) async {
    await gateway.create(table_name, (schema) {
      schema.id();
      schema.timestamp('created_at').nullable(false);
      schema.timestamp('updated_at').nullable(false);
      schema.boolean('enabled').nullable(false);
      schema.int('type').nullable(false);
      schema.json('data');
      schema.json('nested');
    });
  }

  @override
  Future rollback(Gateway gateway) async {
    await gateway.drop(table_name);
  }
}
