library template_srv.storage.api.interface;
import 'dart:async';

abstract class IStorage {
  Future<String> createTask(dynamic params);
  Future<String> createProject(dynamic params);
}
