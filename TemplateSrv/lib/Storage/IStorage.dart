library template_srv.storage.api.interface;
import 'dart:async';

abstract class IStorage {
  Future<String> createTask(dynamic params);
  Future<String> createProject(dynamic params);
  Future addSubTaskForTask(String idBase, String idSub);
  Future addSubTaskForProject(String idBase, String idSub);
}
