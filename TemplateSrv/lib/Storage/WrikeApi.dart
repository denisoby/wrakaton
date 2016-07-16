library template_srv.storage.api.wrike;
import 'dart:async';
import 'package:logging/logging.dart';
import 'IStorage.dart';

export 'IStorage.dart';

class WrikeStorage implements IStorage {
  final Logger log = new Logger('template_srv.WrikeApi');
  @override
  Future<String> createProject(dynamic params) {
    log.info('Wrike: Create Project');
    return new Future.value('wrike_proj_1');
  }

  @override
  Future<String> createTask(dynamic params) {
    log.info('Wrike: Create Task');
    return new Future.value('wrike_task_1');
  }

  @override
  Future addSubTaskForProject(String idBase, String idSub) {
    log.info('Wrike: Add subtask[$idSub] to project[$idBase]');
    return new Future.value();
  }

  @override
  Future addSubTaskForTask(String idBase, String idSub) {
    log.info('Wrike: Add subtask[$idSub] to task[$idBase]');
    return new Future.value();
  }
}
