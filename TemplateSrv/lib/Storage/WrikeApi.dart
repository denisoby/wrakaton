library template_srv.storage.api.wrike;
import 'dart:async';
import 'IStorage.dart';

export 'IStorage.dart';

class WrikeStorage implements IStorage {

  @override
  Future<String> createProject(dynamic params) {
    return new Future.value();
  }

  @override
  Future<String> createTask(dynamic params) {
    return new Future.value();
  }

  @override
  Future addSubTaskForProject(String idBase, String idSub) {
    return new Future.value();
  }

  @override
  Future addSubTaskForTask(String idBase, String idSub) {
    return new Future.value();
  }
}
