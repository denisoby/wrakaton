library template_srv.storage.api.interface;
import 'dart:async';

abstract class IStorage {
  Future<String> createTask();
  Future<String> createProject();
}
